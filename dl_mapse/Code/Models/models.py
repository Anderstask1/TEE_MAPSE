from __future__ import print_function, division
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import numpy as np
import torchvision
from torchvision import datasets, models, transforms
import matplotlib.pyplot as plt
import h5py
import time
import os
import copy

from Models import resnet3d
from Models import tcn


class Identity(nn.Module):
    def __init__(self):
        super(Identity, self).__init__()

    def forward(self, x):
        return x

class Model(nn.Module):

    def __init__(self, seq_len):
        super(Model, self).__init__()

        print("---- Initializing model ----")

        network = EncoderDecoder(seq_len)
        self.network = network

    def forward(self, x):
        x = self.network(x)
        return x

class CNN3D(nn.Module):

    def __init__(self, seq_type, seq_len):
        super(CNN3D, self).__init__()

        self.seq_type = seq_type
        self.seq_len = seq_len

        resnet_3d = resnet3d.resnet34(shortcut_type='B', sample_size=224, sample_duration=seq_len)
        #resnet_weights = torch.load("../Weights/resnet-50-kinetics.pth", map_location='cpu')

        #resnet_3d = nn.DataParallel(resnet_3d)
        #resnet_3d.load_state_dict(resnet_weights['state_dict'], strict=False)
        resnet_3d.conv1 = nn.Conv3d(1, 64,
                                                 kernel_size=(5,7,7),
                                                 stride=(1, 2, 2),
                                                 padding=(1, 3, 3),
                                                 bias=False)
        resnet_3d.fc = Identity()

        self.upconv1 = nn.ConvTranspose2d(512, 256, kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        #self.conv1 = nn.Conv2d(256, 256, kernel_size=3, padding=2, dilation=2)
        self.bn1 = nn.BatchNorm2d(256)
        self.upconv2 = nn.ConvTranspose2d(256, 128, kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        #self.conv2 = nn.Conv2d(128, 128, kernel_size=3, padding=2, dilation=2)
        self.bn2 = nn.BatchNorm2d(128)
        self.upconv3 = nn.ConvTranspose2d(128, 64, kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        #self.conv3 = nn.Conv2d(64, 64, kernel_size=3, padding=2, dilation=2)
        self.bn3 = nn.BatchNorm2d(64)
        self.upconv4 = nn.ConvTranspose2d(64, 32, kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        #self.conv4 = nn.Conv2d(32, 32, kernel_size=3, padding=2, dilation=2)
        self.bn4 = nn.BatchNorm2d(32)
        self.bn5 = nn.BatchNorm2d(16)
        self.upconv5 = nn.ConvTranspose2d(32, 16, kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        self.conv5 = nn.Conv2d(16, 2, kernel_size=3, padding=1)

        self.cnn = resnet_3d
        """

        if self.seq_type == "short":
            self.fc_vis = nn.Linear(2048, 4)
            self.fc_land = nn.Linear(2048, 4)
        elif self.seq_type == "long":
            self.fc_vis = nn.Linear(2048, 4*seq_len)
            self.fc_land = nn.Linear(2048, 4*seq_len)
        """

    def forward(self, up):
        up = (self.cnn(up))
        up = up.view(up.shape[0],up.shape[1],up.shape[3],up.shape[4])
        #x = F.relu(x)

        up = F.relu(self.bn1(self.upconv1(up)))
        up = F.relu(self.bn2(self.upconv2(up)))
        up = F.relu(self.bn3(self.upconv3(up)))
        up = F.relu(self.bn4(self.upconv4(up)))
        up = F.relu(self.bn5(self.upconv5(up)))
        up = self.conv5(up)


        #x = x.view(x.size(0), -1)
        #visibility = self.fc_vis(x)

        #coordinates = self.fc_land(x)

        #if self.seq_type == "long":
        #    coordinates = coordinates.view(-1,self.seq_len,4)
            #visibility = visibility.view(-1,self.seq_len,4)

        return up


class EncoderDecoder(nn.Module):
    def __init__(self, seq_len=1):
        super(EncoderDecoder, self).__init__()

        self.three_dim = False if seq_len==1 else True

        resnet = models.resnet50(pretrained=False)
        resnet.avgpool = Identity()
        resnet.fc = Identity()

        if self.three_dim:
            resnet.conv1 = nn.Conv3d(1, 64, kernel_size=(seq_len, 7, 7),
                                     stride=(1, 2, 2), padding=(0, 3, 3), bias=False)
            self.conv1 = list(resnet.children())[0]
            self.resnet = nn.Sequential(*list(resnet.children()))[1:]
        else:
            resnet.conv1 = nn.Conv2d(1, 64, kernel_size=(7, 7), stride=(2, 2), padding=(3, 3), bias=False)
            self.resnet = nn.Sequential(*list(resnet.children()))[:]

        self.bn5 = nn.BatchNorm2d(64)
        self.bn4 = nn.BatchNorm2d(128)
        self.bn3 = nn.BatchNorm2d(256)
        self.bn2 = nn.BatchNorm2d(512)
        self.bn1 = nn.BatchNorm2d(1024)

        self.upconv1 = nn.ConvTranspose2d(2048,1024,kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        self.upconv2 = nn.ConvTranspose2d(1024,512,kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        self.upconv3 = nn.ConvTranspose2d(512,256,kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        self.upconv4 = nn.ConvTranspose2d(256,128,kernel_size=(3,3), stride=2, padding=1, output_padding=1)
        self.upconv5 = nn.ConvTranspose2d(128,64,kernel_size=(3,3), stride=2, padding=1, output_padding=1)

        self.outconv = nn.Conv2d(64,2,3,padding=1)

    def forward(self, x):

        if self.three_dim:
            x = self.conv1(x)
        x = x.view(x.shape[0],x.shape[1],x.shape[3],x.shape[4])
        x = self.resnet(x)

        x = F.relu(self.bn1(self.upconv1(x)))
        x = F.relu(self.bn2(self.upconv2(x)))
        x = F.relu(self.bn3(self.upconv3(x)))
        x = F.relu(self.bn4(self.upconv4(x)))
        x = F.relu(self.bn5(self.upconv5(x)))

        x = self.outconv(x)

        return x

class CNNLSTM(nn.Module):

    def __init__(self, seq_type, seq_len, batch_size, cnn_output_size=16, lstm_hidden_size=16, lstm_num_layers=2):

        super(CNNLSTM, self).__init__()
        resnet = models.resnet50(pretrained=True)

        self.batch_size = batch_size
        self.seq_len = seq_len
        self.seq_type = seq_type

        resnet.conv1 = nn.Conv2d(1, 64, kernel_size=(7, 7), stride=(2, 2), padding=(3, 3), bias=False)
        resnet.fc = nn.Linear(2048, cnn_output_size)

        self.cnn = resnet
        self.lstm = nn.LSTM(cnn_output_size,
                            hidden_size=lstm_hidden_size,
                            num_layers=lstm_num_layers,
                            batch_first=True)
        self.visibility_fc = nn.Linear(cnn_output_size, 4)
        self.landmark_fc = nn.Linear(lstm_hidden_size, 4)

    def forward(self, x):

        x = F.relu(self.cnn(x))

        visibility = self.visibility_fc(x)

        x = x.view(self.batch_size,self.seq_len,-1)
        x, _ = self.lstm(x)

        x = x[:,-1,:] if self.seq_type == "short" else x

        coordinates = 224*self.landmark_fc(x)

        return coordinates, visibility
