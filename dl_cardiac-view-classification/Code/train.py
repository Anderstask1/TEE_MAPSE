import torch
import copy
import time
import torch.nn as nn
import torch.nn.functional as F


def train_model(model, device, dataloaders, loss, optimizer, num_epochs=25):
    criterion = nn.CrossEntropyLoss()

    train_info = {'epoch': [], 'loss': [], 'all_loss': []}
    val_info = {'epoch': [], 'loss': [], 'all_loss': []}
    best_loss = 1e10

    for epoch in range(num_epochs):

        print("Epoch {}/{}".format(epoch + 1, num_epochs))
        print("-" * 40)

        for phase in ['train', 'val']:

            print("Phase: ", phase)
            if phase == 'train':
                model.train()
            else:
                model.eval()

            running_loss = 0.0

            for i, sample_batch in enumerate(dataloaders[phase]):

                sample_batch['image'] = sample_batch['image'].to(device)

                optimizer.zero_grad()

                with torch.set_grad_enabled(phase == 'train'):

                    out = model(sample_batch['image'])
                    #target = [int(a) for a in sample_batch['cardiac_view']]
                    target = torch.cuda.LongTensor(sample_batch['cardiac_view'].long().cuda())
                    loss = criterion(out, target)

                    all_loss = loss.item()
                    running_loss += all_loss

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()
                        train_info['all_loss'].append(all_loss)

                    if i % 2000 == 1999:

                        if phase == 'train':
                            print('{{"metric": "loss", "value": {}, "epoch": {}}}'.format(
                                running_loss / 2000, epoch + 1))
                        else:
                            print('{{"metric": "Validation loss", "value": {}, "epoch": {}}}'.format(
                                running_loss / 2000, epoch + 1))

                        print("Loss: {:.3f}".format(running_loss / 2000))

            epoch_loss = running_loss / len(dataloaders[phase].dataset)

            if phase == 'train':
                train_info['epoch'].append(epoch + 1)
                train_info['loss'].append(epoch_loss)
            else:
                val_info['epoch'].append(epoch + 1)
                val_info['loss'].append(epoch_loss)

            torch.save({
                'epoch': epoch,
                'train_info': train_info,
                'val_info':val_info}, "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data/training_info.pth")
                #'val_info': val_info}, "/output/training_info.pth")
            if phase == 'val' and epoch_loss <= best_loss:
                torch.save({
                    'epoch': epoch,
                    'model_state_dict': model.state_dict(),
                    # Edit this path
                    'optimizer_state_dict':optimizer.state_dict()}, "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data/best_weights.pth")
                    #'optimizer_state_dict': optimizer.state_dict()}, "/output/best_weights.pth")
                best_loss = epoch_loss
                print("Weights saved")
    print()