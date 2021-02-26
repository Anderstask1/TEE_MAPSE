import torch
import torch.nn as nn
import torch.nn.functional as F

from torchvision import models

class Inception1(nn.Module):
    """ Custom layer with parallel convolution blocks """

    def __init__(self, c_in, c_red : dict, c_out : dict):
        super().__init__()

        """
        Inputs:
            c_in - Number of input feature maps from the previous layers
            c_red - Dictionary with keys "3x3" and "5x5" specifying the output of the dimensionality reducing 1x1 convolutions
            c_out - Dictionary with keys "1x1", "3x3", "5x5"
        """

        # 1x1 convolution branch
        self.conv_1x1 = nn.Sequential(
            nn.Conv2d(c_in, c_out["1x1"], kernel_size=1, padding=0, stride=1),
            nn.BatchNorm2d(c_out["1x1"]),
            nn.PReLU()
        )

        # 3x3 convolution branch
        self.conv_3x3 = nn.Sequential(
            nn.Conv2d(c_in, c_red["3x3"], kernel_size=1, padding=0, stride=1),
            nn.BatchNorm2d(c_red["3x3"]),
            nn.PReLU(),
            nn.Conv2d(c_red["3x3"], c_out["3x3"], kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(c_out["3x3"]),
            nn.PReLU()
        )

        # 5x5 convolution branch
        self.conv_5x5 = nn.Sequential(
            nn.Conv2d(c_in, c_red["5x5"], kernel_size=1, padding=0, stride=1),
            nn.BatchNorm2d(c_red["5x5"]),
            nn.PReLU(),
            nn.Conv2d(c_red["5x5"], c_out["5x5"], kernel_size=5, padding=2, stride=1),
            nn.BatchNorm2d(c_out["5x5"]),
            nn.PReLU()
        )

    def forward(self, x):
        x_1x1 = self.conv_1x1(x)
        x_3x3 = self.conv_3x3(x)
        x_5x5 = self.conv_5x5(x)
        return torch.cat([x_1x1, x_3x3, x_5x5], dim=1)


class Inception2(nn.Module):

    def __init__(self, c_in, c_red : dict, c_out : dict):
        super().__init__()
        """
                Inputs:
                    c_in - Number of input feature maps from the previous layers
                    c_red - Dictionary with key "3x3" specifying the output of the dimensionality reducing 1x1 convolutions
                    c_out - Dictionary with keys "1x1", "3x3"
                """

        # 1x1 convolution branch
        self.conv_1x1 = nn.Sequential(
            nn.Conv2d(c_in, c_out["1x1"], kernel_size=1, padding=0, stride=1),
            nn.BatchNorm2d(c_out["1x1"]),
            nn.PReLU()
        )

        # 3x3 convolution branch
        self.conv_3x3 = nn.Sequential(
            nn.Conv2d(c_in, c_red["3x3"], kernel_size=1, padding=0, stride=1),
            nn.BatchNorm2d(c_red["3x3"]),
            nn.PReLU(),
            nn.Conv2d(c_red["3x3"], c_out["3x3"], kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(c_out["3x3"]),
            nn.PReLU()
        )

    def forward(self, x):
        x_1x1 = self.conv_1x1(x)
        x_3x3 = self.conv_3x3(x)
        return torch.cat([x_1x1, x_3x3], dim=1)

class CNN_classification(nn.Module):
    """ Neural Network classifying cardiac US views based on architecture designed by ISB """

    def __init__(self):
        super(CNN_classification, self).__init__()
        self.conv1 = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(32),
            nn.PReLU()
        )
        self.pool1 = nn.MaxPool2d(kernel_size=2)
        self.conv2 = nn.Sequential(
            nn.Conv2d(32, 64, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(64),
            nn.PReLU()
        )
        self.pool2 = nn.MaxPool2d(kernel_size=2)
        self.inception1 = Inception1(64, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 16, "3x3": 32, "5x5": 16})
        self.conv3 = nn.Sequential(
            nn.Conv2d(128, 128, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(128),
            nn.PReLU()
        )
        self.pool3 = nn.MaxPool2d(kernel_size=2)
        self.inception2 = Inception1(128, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 32, "3x3": 64, "5x5": 32})
        self.conv4 = nn.Sequential(
            nn.Conv2d(256, 256, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(256),
            nn.PReLU()
        )
        self.pool4 = nn.MaxPool2d(kernel_size=2)
        self.inception3 = Inception1(256, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 64, "3x3": 128, "5x5": 64})
        self.conv5 = nn.Sequential(
            nn.Conv2d(512, 512, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(512),
            nn.PReLU()
        )
        self.pool5 = nn.MaxPool2d(kernel_size=2)
        self.inception4 = Inception2(512, c_red={"3x3": 48}, c_out={"1x1": 256, "3x3": 256})
        self.inception5 = Inception2(1024, c_red={"3x3": 48}, c_out={"1x1": 512, "3x3": 512})
        self.conv6 = nn.Conv2d(2048, 4, kernel_size=1, padding=1, stride=1)
        self.relu = nn.PReLU()
        self.pool6 = nn.AvgPool2d(kernel_size=10)



    def forward(self, x):
        #x = x.view(x.shape[0], x.shape[1], x.shape[2], x.shape[3])
        x = self.conv1(x)
        x = self.pool1(x)
        x = self.conv2(x)
        x = self.pool2(x)
        x = torch.cat((x, self.inception1(x)), dim=1)
        x = self.conv3(x)
        x = self.pool3(x)
        x = torch.cat((x, self.inception2(x)), dim=1)
        x = self.conv4(x)
        x = self.pool4(x)
        x = torch.cat((x, self.inception3(x)), dim=1)
        x = self.conv5(x)
        x = self.pool5(x)
        x = torch.cat((x, self.inception4(x)), dim=1)
        x = torch.cat((x, self.inception5(x)), dim=1)
        x = self.conv6(x)
        x = self.relu(x)
        x = self.pool6(x)
        return x.view(x.size(0), -1)

class CNN_regression(nn.Module):
    """ Neural Network classifying cardiac US views based on architecture designed by ISB """

    def __init__(self):
        super(CNN_regression, self).__init__()
        self.conv1 = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(32),
            nn.PReLU()
        )
        self.pool1 = nn.MaxPool2d(kernel_size=2)
        self.conv2 = nn.Sequential(
            nn.Conv2d(32, 64, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(64),
            nn.PReLU()
        )
        self.pool2 = nn.MaxPool2d(kernel_size=2)
        self.inception1 = Inception1(64, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 16, "3x3": 32, "5x5": 16})
        self.conv3 = nn.Sequential(
            nn.Conv2d(128, 128, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(128),
            nn.PReLU()
        )
        self.pool3 = nn.MaxPool2d(kernel_size=2)
        self.inception2 = Inception1(128, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 32, "3x3": 64, "5x5": 32})
        self.conv4 = nn.Sequential(
            nn.Conv2d(256, 256, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(256),
            nn.PReLU()
        )
        self.pool4 = nn.MaxPool2d(kernel_size=2)
        self.inception3 = Inception1(256, c_red={"3x3": 32, "5x5": 16}, c_out={"1x1": 64, "3x3": 128, "5x5": 64})
        self.conv5 = nn.Sequential(
            nn.Conv2d(512, 512, kernel_size=3, padding=1, stride=1),
            nn.BatchNorm2d(512),
            nn.PReLU()
        )
        self.pool5 = nn.MaxPool2d(kernel_size=2)
        self.inception4 = Inception2(512, c_red={"3x3": 48}, c_out={"1x1": 256, "3x3": 256})
        self.inception5 = Inception2(1024, c_red={"3x3": 48}, c_out={"1x1": 512, "3x3": 512})
        self.conv6 = nn.Conv2d(2048, 3, kernel_size=1, padding=1, stride=1)
        self.relu = nn.PReLU()
        self.pool6 = nn.AvgPool2d(kernel_size=10)



    def forward(self, x):
        #x = x.view(x.shape[0], x.shape[1], x.shape[2], x.shape[3])
        x = self.conv1(x)
        x = self.pool1(x)
        x = self.conv2(x)
        x = self.pool2(x)
        x = torch.cat((x, self.inception1(x)), dim=1)
        x = self.conv3(x)
        x = self.pool3(x)
        x = torch.cat((x, self.inception2(x)), dim=1)
        x = self.conv4(x)
        x = self.pool4(x)
        x = torch.cat((x, self.inception3(x)), dim=1)
        x = self.conv5(x)
        x = self.pool5(x)
        x = torch.cat((x, self.inception4(x)), dim=1)
        x = torch.cat((x, self.inception5(x)), dim=1)
        x = self.conv6(x)
        x = self.relu(x)
        x = self.pool6(x)
        x = F.softmax(x, dim=1)
        return x.view(x.size(0), -1)


class VGG16(nn.Module):
    """ Neural Network classifying cardiac US views based on VGG16 architecture"""

    def __init__(self):
        super(VGG16, self).__init__()
        self.conv = nn.Conv2d(1, 3, kernel_size=3, stride=1, padding=1, dilation=1, groups=1, bias=True) # 3 channel input

        vgg16 = models.vgg16_bn(pretrained=True, progress=False) # import vgg16 model
        num_features = vgg16.classifier[6].in_features
        features = list(vgg16.classifier.children())[:-1]  # Remove last layer
        features.extend([nn.Linear(num_features, 4)])  # Add our layer with 4 outputs
        vgg16.classifier = nn.Sequential(*features) # Add modified classifier to model
        self.vgg = vgg16

    def forward(self, x):
        x = self.conv(x)
        return self.vgg(x)

class ResNext(nn.Module):

    def __init__(self):
        super(ResNext, self).__init__()
        self.conv = nn.Conv2d(1, 3, kernel_size=3, stride=1, padding=1, dilation=1, groups=1, bias=True) # 3 channel input

        resnext = models.resnext50_32x4d(pretrained=True, progress=False)
        #resnext = models.resnext101_32x8d(pretrained=True, progress=False)

        # Freeze training for layers
        for param in resnext.layer1.parameters():
            param.require_grad = False
        for param in resnext.layer2.parameters():
            param.require_grad = False
        for param in resnext.layer3.parameters():
            param.require_grad = False
        for param in resnext.layer4.parameters():
            param.require_grad = False

        resnext.fc = nn.Linear(resnext.fc.in_features, 4) # Add our layer with 4 outputs
        self.resnext = resnext

    def forward(self, x):
        x = self.conv(x)
        return self.resnext(x)