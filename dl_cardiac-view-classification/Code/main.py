import torch
import torch.nn as nn
import torch.optim as optim
import train
import dataset

from Models import models
from torch.utils.data import DataLoader

datasets = {
    'train':dataset.UltrasoundData("/train/", seq_type, seq_len, transform=data_transforms['train']),
    'val':dataset.UltrasoundData("/val/", seq_type, seq_len, transform=data_transforms['val'])}

dataloaders = {
    'train':DataLoader(datasets['train'], batch_size=batch_size, shuffle=True, num_workers=4),
    'val':DataLoader(datasets['val'], batch_size=1, shuffle=False, num_workers=4)}

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

model = models.CNN()

optimizer = optim.Adam(model.parameters())

loss = nn.L1Loss()

train.train_model(model, device, dataloaders, loss, optimizer)