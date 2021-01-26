import torch
import torch.nn as nn
import torch.nn.functional as F

class Convolution(nn.module):
    """ Custom Convolution layer """

    def __init__(self, size_in, size_out, size_kernel):
        super().__init__()
        self.conv1 = nn.Conv2d(size_in, size_out, size_kernel)
        self.bn1 = nn.BatchNorm2d(size_out, affine=False)
        self.relu = nn.PReLU()

    def forward(self, x):
        x = self.conv1(x)
        x = self.bn1(x)
        x = self.relu(x)
        return x

class Inception1(nn.module):
    """ Custom layer with parallel convolution blocks """

    def __init__(self, size_in, size_out):
        super().__init__()
        self.conv1 = nn.Conv2d(size_in, size_out, 1)

        self.conv2 = nn.Conv2d(size_in, size_out, 1)
        self.conv3 = nn.Conv2d(size_out, size_out, 3)

        self.conv4 = nn.Conv2d(size_in, size_out, 1)
        self.conv5 = nn.Conv2d(size_out, size_out, 5)

    def forward(self, x):
        x1 = self.conv1(x)

        x2 = self.conv2(x)
        x2 = self.conv3(x2)

        x3 = self.conv4(x)
        x3 = self.conv5(x3)
        return torch.cat((x1, x2, x3), 0)


class Inception2(nn.module):

    def __init__(self, size_in, size_out):
        super().__init__()
        self.conv1 = nn.Conv2d(size_in, size_out, 1)

        self.conv2 = nn.Conv2d(size_in, size_out, 1)
        self.conv3 = nn.Conv2d(size_out, size_out, 3)

    def forward(self, x):
        x1 = self.conv1(x)

        x2 = self.conv2(x)
        x2 = self.conv3(x2)

        return torch.cat((x1, x2), 0)

class CNN(nn.module):
    """ Neural Network classifying cardiac US views """

    def __init__(self):
        super(CNN, self).__init__()
        # 1 input image channel, 6 output channels, 3x3 square convolution
        # kernel
        self.conv1 = Convolution(1, 16, 3)
        self.pool1 = nn.MaxPool2d(2)
        self.conv2 = Convolution(16, 32, 3)
        self.pool2 = nn.MaxPool2d(2)
        self.inception1 = Inception1(32, 32)
        self.conv3 = Convolution(32, 32, 1)
        self.pool3 = nn.MaxPool2d(2)
        self.inception2 = Inception1(32, 32)
        self.conv4 = Convolution(32, 32, 1)
        self.pool4 = nn.MaxPool2d(2)
        self.inception3 = Inception1(32, 32)
        self.conv5 = Convolution(32, 32, 1)
        self.pool5 = nn.MaxPool2d(2)
        self.inception4 = Inception2(32, 32)
        self.inception5 = Inception2(32, 32)
        self.conv6 = nn.Conv2d(32, 32, 1)
        self.relu1 = nn.PReLU()
        self.pool6 = nn.AvgPool2d(2)
        self.relu2 = nn.PReLU()



    def forward(self, x):
        x = self.conv1(x)
        x = self.pool1(x)
        x = self.conv2(x)
        x = self.pool2(x)
        x = torch.cat((x, self.inception1(x)), 0)
        x = self.conv3(x)
        x = self.pool3(x)
        x = torch.cat((x, self.inception2(x)), 0)
        x = self.conv4(x)
        x = self.pool4(x)
        x = torch.cat((x, self.inception3(x)), 0)
        x = self.conv5(x)
        x = self.pool5(x)
        x = torch.cat((x, self.inception4(x)), 0)
        x = torch.cat((x, self.inception5(x)), 0)
        x = self.conv6(x)
        x = self.relu1(x)
        x = self.pool6(x)
        return self.relu2(x)