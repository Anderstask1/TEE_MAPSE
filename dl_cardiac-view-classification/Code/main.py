import torch
import torch.nn as nn
import torch.optim as optim
import train
import dataset

from Models import models
from torch.utils.data import DataLoader
from torchvision import transforms

batch_size = 16
sigma = 3

print()
print(" + Batch size:\t\t{}".format(batch_size))
print(" + Sigma:\t\t{}".format(sigma))
print()

data_transforms = {
    'train':transforms.Compose([dataset.Rescale((280, 280)),
                        dataset.RandomRotation(10),
                        dataset.RandomCrop(256),
                        dataset.ToTensor(sigma)]),
    'val':transforms.Compose([dataset.Rescale(280),
                        dataset.Crop(256),
                        dataset.ToTensor(sigma)])}

datasets = {
    'train':dataset.UltrasoundData("/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/train/", transform=data_transforms['train']),
    'val':dataset.UltrasoundData("/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/val/", transform=data_transforms['val'])}

dataloaders = {
    'train':DataLoader(datasets['train'], batch_size=batch_size, shuffle=True, num_workers=4),
    'val':DataLoader(datasets['val'], batch_size=1, shuffle=False, num_workers=4)}

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

model = models.CNN()
model = model.to(device)

optimizer = optim.Adam(model.parameters())

loss = nn.L1Loss()

train.train_model(model, device, dataloaders, loss, optimizer)