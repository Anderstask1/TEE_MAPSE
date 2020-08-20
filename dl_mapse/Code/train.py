import time
import math
import copy
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.nn.modules.utils import _pair, _quadruple
import torchvision
from torchvision import datasets, models, transforms
from torch.utils.data import Dataset, DataLoader
import matplotlib.pyplot as plt
import scipy.ndimage as nd
import numpy as np

import dataset
import loss

def train_model(model, device, dataloaders, criterion, optimizer, seq_type, num_epochs=25):

    since = time.time()

    best_model_wts = copy.deepcopy(model.state_dict())

    train_info = {'epoch':[], 'loss':[], 'all_loss':[], 'detect_acc':[],
                  'noise_tp':[], 'noise_tn':[], 'noise_fp':[], 'noise_fn':[], 'true_acc':[]}
    val_info = {'epoch':[], 'loss':[], 'detect_acc':[],
                'noise_tp':[], 'noise_tn':[], 'noise_fp':[], 'noise_fn':[], 'true_acc':[]}
    eps = 1e-10
    best_loss = 1e10
    best_acc = 1e10
    best_true_acc = 1e10

    for epoch in range(num_epochs):

        print("Epoch {}/{}".format(epoch+1, num_epochs))
        print("-" * 40)

        for phase in ['train', 'val']:

            print("Phase: ", phase)
            if phase == 'train':
                model.train()
            else:
                model.eval()

            running_loss = 0.0
            running_detect_acc = 0.0
            running_noise_tp = 0.0
            running_noise_tn = 0.0
            running_noise_fp = 0.0
            running_noise_fn = 0.0
            running_true_acc = 0.0

            for i, sample_batch in enumerate(dataloaders[phase]):

                sample_batch['images'] = sample_batch['images'].to(device)
                sample_batch['masks'] = sample_batch['masks'].to(device)

                optimizer.zero_grad()

                with torch.set_grad_enabled(phase=='train'):

                    out = model(sample_batch['images'])
                    loss = criterion(out,sample_batch['masks'])

                    out = F.sigmoid(out.detach())
                    out_n = (out - out.min())/(out.max() - out.min() + eps)
                    masks = out.ge(0.5)
                    masks_n = out_n.ge(0.5)

                    all_loss = loss.item()
                    running_loss += all_loss

                    detect_acc, noise_tp, noise_tn, noise_fp, noise_fn, true_detect_acc = accuracy(masks, masks_n, sample_batch['landmarks'])

                    running_detect_acc += detect_acc
                    running_noise_tp += noise_tp
                    running_noise_tn += noise_tn
                    running_noise_fp += noise_fp
                    running_noise_fn += noise_fn
                    running_true_acc += true_detect_acc

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()
                        train_info['all_loss'].append(all_loss)

                    if (i+1)%(int(0.1*len(dataloaders[phase].dataset)/sample_batch['landmarks'].shape[0]))==0:

                        print("Loss: {:.3f}".format(running_loss/((i+1) * sample_batch['landmarks'].shape[0])))
                        print("Detection accuracy: {:.3f}".format((running_detect_acc*2.0)/(running_noise_tn+running_noise_fn+eps)))
                        print("Noise (tp, tn, fp, fn): {}, {}, {}, {}".format(running_noise_tp,
                                                                           running_noise_tn,
                                                                           running_noise_fp,
                                                                           running_noise_fn))



            epoch_loss = running_loss/len(dataloaders[phase].dataset)
            epoch_detect_acc = (running_detect_acc*2.0)/(running_noise_tn+running_noise_fn+eps)
            epoch_true_acc = (running_true_acc*2.0)/(running_noise_tn+eps)
            if phase=='train':
                train_info['epoch'].append(epoch + 1)
                train_info['loss'].append(epoch_loss)
                train_info['detect_acc'].append(epoch_detect_acc)
                train_info['noise_tp'].append(running_noise_tp)
                train_info['noise_tn'].append(running_noise_tn)
                train_info['noise_fp'].append(running_noise_fp)
                train_info['noise_fn'].append(running_noise_fn)
                train_info['true_acc'].append(epoch_true_acc)
            else:
                val_info['epoch'].append(epoch + 1)
                val_info['loss'].append(epoch_loss)
                val_info['detect_acc'].append(epoch_detect_acc)
                val_info['noise_tp'].append(running_noise_tp)
                val_info['noise_tn'].append(running_noise_tn)
                val_info['noise_fp'].append(running_noise_fp)
                val_info['noise_fn'].append(running_noise_fn)
                val_info['true_acc'].append(epoch_true_acc)

            torch.save({
                'epoch':epoch,
                'train_info':train_info,
                'val_info':val_info}, "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/training_info.pth")
            if phase == 'val' and epoch_true_acc<=best_true_acc and epoch_true_acc>0.0:
                torch.save({
                    'epoch':epoch,
                    'model_state_dict':model.state_dict(),
                    # Edit this path
                    'optimizer_state_dict':optimizer.state_dict()}, "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights.pth")
                best_true_acc = epoch_true_acc
                print("True weights saved")
            if phase == 'val' and epoch_detect_acc<=best_acc:
                torch.save({
                    'epoch':epoch,
                    'model_state_dict':model.state_dict(),
                    # Edit this path
                    'optimizer_state_dict':optimizer.state_dict()}, "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_weights.pth")
                best_acc = epoch_detect_acc
                print("Weights saved")
    print()



def centroid(masks, dimensions=2):
    centroids = torch.empty((dimensions))

    for axis in range(dimensions):
        ind = torch.nonzero(masks)
        if ind.dim() < dimensions:
            centroids[axis] = float('nan')
        else:
            coordinate = torch.mean(ind[:,axis].float())
            centroids[axis] = coordinate

    return centroids


def accuracy(masks, masks_n, reference_landmarks):
    detect_acc = 0.0
    noise_tp = 0.0
    noise_tn = 0.0
    noise_fp = 0.0
    noise_fn = 0.0
    true_detect_acc = 0.0

    reference_landmarks = reference_landmarks.view(masks.shape[0],masks.shape[1],masks.shape[1])
    pred = torch.empty((2))
    for img in range(masks.shape[0]):
        point_distances = torch.empty((0)).float()
        tn_flag = False
        for point in range(masks.shape[1]):
            pred = centroid(masks[img,point,...])
            pred_n = centroid(masks_n[img,point,...])
            if torch.isnan(pred).any() and reference_landmarks[img,point,0] <= 0.0:
                noise_tp += 1.0
                point_distances = torch.zeros((2)).float()
            elif torch.isnan(pred).any() and reference_landmarks[img,point,0] > 0.0:
                if not torch.isnan(pred_n).any():
                    pred_tensor = torch.tensor([pred_n[1], pred_n[0]])
                    point_distances = torch.cat((point_distances,
                                                 torch.sqrt(torch.sum(torch.pow(reference_landmarks[img,point,:] - pred_tensor, 2), dim=0, keepdim=True))))
                else:
                    point_distances = torch.zeros((2)).float()
                noise_fn += 1.0
            elif not torch.isnan(pred).any() and reference_landmarks[img,point,0] <= 0.0:
                noise_fp += 1.0
                point_distances = torch.zeros((2)).float()
            else:
                pred_tensor = torch.tensor([pred[1], pred[0]])
                point_distances = torch.cat((point_distances, torch.sqrt(torch.sum(torch.pow(reference_landmarks[img,point,:] - pred_tensor, 2), dim=0, keepdim=True))))
                noise_tn += 1.0
                tn_flag = True
        detect_acc += torch.sqrt(torch.mean(torch.pow(point_distances, 2)))
        if tn_flag:
            true_detect_acc += torch.sqrt(torch.mean(torch.pow(point_distances, 2)))

    return detect_acc, noise_tp, noise_tn, noise_fp, noise_fn, true_detect_acc
