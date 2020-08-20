import numpy as np
import matplotlib.pyplot as plt
import math
import torch
import torch.nn as nn
import torch.nn.functional as F

pi = math.pi
n = 16

class cnnlstm(nn.Module):
    def __init__(self):
        super(cnnlstm, self).__init__()
        self.cnn1 = nn.Conv2d(1,8,3)
        self.pool = nn.MaxPool2d(2,2)
        self.cnn2 = nn.Conv2d(8,16,3)

        self.lstm1 = nn.LSTM(input_size=576,hidden_size=64,num_layers=2,batch_first=True)

        self.linear0 = nn.Linear(576,64)
        self.linear = nn.Linear(64,2)

    def forward(self, x):
            x = self.pool(F.relu(self.cnn1(x)))
            x = self.pool(F.relu(self.cnn2(x)))
            x = x.view(2,16,-1)
            x, (n, c) = self.lstm1(x)
            #x = self.linear0(x)
            x = self.linear(x)
            return x

model = cnnlstm().double()

import torch.optim as optim

#criterion = nn.SmoothL1Loss()
criterion = nn.MSELoss()
#optimizer = optim.SGD(model.parameters(), lr=0.001, momentum=0.9)
optimizer = optim.Adam(model.parameters())

def train():
    for epoch in range(20):  # loop over the dataset multiple times

        running_loss = 0.0
        for i in range(1000):
            data, labels = genData()

            # zero the parameter gradients
            optimizer.zero_grad()

            # forward + backward + optimize
            outputs = model(data)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            # print statistics
            running_loss += loss.item()
            if i % 20 == 0:    # print every 2000 mini-batches
                print('[%d, %5d] loss: %.3f' %
                      (epoch + 1, i + 1, loss.item() ))
                running_loss = 0.0

print('Finished Training')

plt.ion()

def genData():

    data = torch.empty(1,1,32,32, dtype=torch.double)
    labels = torch.empty(1,16,2, dtype=torch.double)

    for l in range(2):
        ran = np.random.randint(low=4, high=11)
        r = 15-ran
        points = [((math.cos(2*pi/n*x)*r+16),(math.sin(2*pi/n*x)*r)+16) for x in range(0,n+1)]
        lab = torch.empty(1,1,2, dtype=torch.double)
        for j in range(n):

            img = np.random.rand(32,32)*0.5
            img[round(points[j][0]), round(points[j][1])] = 1

            label = np.array([points[j][0], points[j][1]])
            label = torch.from_numpy(label).double()

            img_torch = torch.from_numpy(img).double()
            img_torch.unsqueeze_(0)
            img_torch.unsqueeze_(0)

            label.unsqueeze_(0)
            label.unsqueeze_(0)

            data = torch.cat((data, img_torch), dim=0)
            lab = torch.cat((lab, label), dim=1)

        lab = lab[:,1:17,:]
        labels = torch.cat((labels, lab), dim=0)

    data = data[1:33,:,:,:]

    labels = labels[1:3,:,:]

    """
    for tk in range(32):
        plt.clf()
        plt.imshow(data.numpy()[tk,0,:,:], cmap='gray')
        plt.show()
        plt.pause(0.2)
    """
    return data, labels

train()

dat, labb = genData()
print(labb)
out = model(dat)
print(out)

for rk in range(16):
    plt.clf()
    plt.imshow(dat.numpy()[rk,0,:,:], cmap='gray')
    plt.show()
    plt.pause(0.5)

    pred = out.detach().numpy()[0,rk,:]
    tr = labb.detach().numpy()[0,rk,:]
    img = np.zeros((32,32))
    img[int(abs(round(pred[0]))), int(abs(round(pred[1])))] = 1
    img[int(abs(round(tr[0]))), int(abs(round(tr[1])))] = 1
    plt.clf()
    plt.imshow(img, cmap='gray')
    plt.show()
    plt.pause(0.5)
