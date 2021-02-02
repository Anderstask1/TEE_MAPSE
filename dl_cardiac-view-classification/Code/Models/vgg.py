import torch
import torch.nn as nn

from torchvision import models

class VGG16(nn.Module):

    def __init__(self):
        super(VGG16, self).__init__()
        vgg16 = models.vgg16_bn(pretrained=False, progress=True)
        num_features = vgg16.classifier[6].in_features
        features = list(vgg16.classifier.children())[:-1]  # Remove last layer
        features.extend([nn.Linear(num_features, 4)])  # Add our layer with 4 outputs
        vgg16.classifier = nn.Sequential(*features)
        self.vgg = vgg16

    def forward(self, x):
        return self.vgg(x)