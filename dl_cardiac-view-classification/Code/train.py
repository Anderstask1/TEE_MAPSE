import torch
import copy
import time
import torch.nn as nn
import torch.nn.functional as F


def train_model(model, device, dataloaders, loss, optimizer, training_info_path: str, weights_path: str, label_encoding: str, loss_weights, num_epochs=25):

    print("Training info path: ", training_info_path)
    print("Weights path: ", weights_path)

    if label_encoding == 'binary':
        #Classification
        #weight each class to prioritize cardiac views over noise (due to imbalance in annotation dataset)
        #Noise = 0, 4C = 1, 2C = 2, LAX = 3
        class_weights = torch.FloatTensor(loss_weights).to(device)
        criterion = nn.CrossEntropyLoss(weight=class_weights)
    elif label_encoding == 'gaussian':
        #Regression
        criterion = nn.MSELoss()

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

                    if label_encoding == 'binary':
                        target = torch.LongTensor(sample_batch['cardiac_view']).to(device)
                    elif label_encoding == 'gaussian':
                        target = torch.DoubleTensor(sample_batch['cardiac_view']).to(device)

                    loss = criterion(out, target)

                    all_loss = loss.item()
                    running_loss += all_loss

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()
                        train_info['all_loss'].append(all_loss)
                        if i % 2000 == 1999:
                            print('{{"metric": "loss", "value": {}, "epoch": {}}}'.format(
                                running_loss / (i + 1), epoch + 1))

                    if i % 2000 == 1999:

                        if phase == 'train':
                            print('{{"metric": "loss", "value": {}, "epoch": {}}}'.format(
                                running_loss / 2000, epoch + 1))
                        else:
                            print('{{"metric": "Validation loss", "value": {}, "epoch": {}}}'.format(
                                running_loss / 2000, epoch + 1))

                        print("Loss: {:.3f}".format(running_loss / 2000))
                        running_loss = 0.0

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
                'val_info': val_info}, training_info_path)
            if phase == 'val' and epoch_loss <= best_loss:
                torch.save({
                    'epoch': epoch,
                    'model_state_dict': model.state_dict(),
                    # Edit this path
                    'optimizer_state_dict': optimizer.state_dict()}, weights_path)
                best_loss = epoch_loss
                print("Weights saved")
    print()