import torch
import torch.nn as nn
import numpy as np

class WingLoss(nn.Module):
    def __init__(self, width=10, curvature=2):
        super(WingLoss, self).__init__()
        self.width = width
        self.curvature = curvature
        self.C = self.width - self.width*np.log(1 + self.width / self.curvature)

    def forward(self, coordinates_pred, coordinates_target, visibility_target):
        print(visibility_target.shape, coordinates_target.shape, coordinates_pred.shape)
        diff = visibility_target * (coordinates_target - coordinates_pred)
        diff_abs = diff.abs()
        print(diff_abs)
        loss = diff_abs.clone()

        idx_smaller = diff_abs < self.width
        idx_bigger = diff_abs >= self.width

        loss[idx_smaller] = self.width * torch.log(1 + diff_abs[idx_smaller] / self.curvature)
        loss[idx_bigger] = diff_abs[idx_bigger] - self.C

        loss = loss.mean()

        return loss
