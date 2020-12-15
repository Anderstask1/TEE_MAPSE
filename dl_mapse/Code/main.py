import configparser as cparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms

import dataset
import train
from Models import models
from Models import resnet3d

seq_type = "short"
#seq_len = 3
seq_len = 1 #best on nordal
batch_size = 32 #used by nordal
sigma = 3 #best on nordal

print()
print(" + Sequence length:\t{}".format(seq_len))
print(" + Batch size:\t\t{}".format(batch_size))
print(" + Sigma:\t\t{}".format(sigma))
print()

data_transforms = {
    'train':transforms.Compose([dataset.Rescale(280),
                        dataset.RandomRotation(10),
                        dataset.RandomCrop(256),
                        dataset.ToTensor(sigma)]),
    'val':transforms.Compose([dataset.Rescale(280),
                        dataset.Crop(256),
                        dataset.ToTensor(sigma)])}
"""
datasets = {
    'train':dataset.UltrasoundData("Project/Data/train/", seq_type, seq_len, transform=data_transforms['train']),
    'val':dataset.UltrasoundData("Project/Data/val/", seq_type, seq_len, transform=data_transforms['val'])}
"""

datasets = {
    'train':dataset.UltrasoundData("/train/", seq_type, seq_len, transform=data_transforms['train']),
    'val':dataset.UltrasoundData("/val/", seq_type, seq_len, transform=data_transforms['val'])}
"""
datasets = {
    'train':dataset.UltrasoundData("/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/train/", seq_type, seq_len, transform=data_transforms['train']),
    'val':dataset.UltrasoundData("/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/val/", seq_type, seq_len, transform=data_transforms['val'])}
"""
dataloaders = {
    'train':DataLoader(datasets['train'], batch_size=batch_size, shuffle=True, num_workers=4),
    'val':DataLoader(datasets['val'], batch_size=1, shuffle=False, num_workers=4)}

torch.backends.cudnn.benchmark = True
#device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
#device = torch.device("cpu")

model = models.Model(seq_len)
model = model.to(device)

optimizer = optim.Adam(model.parameters())

loss = nn.BCEWithLogitsLoss(reduction='mean')


train.train_model(model, device, dataloaders, loss, optimizer, seq_type)
