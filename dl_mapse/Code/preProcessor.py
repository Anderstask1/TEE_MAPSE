import numpy as np
import torch
from skimage import transform


class PreProcessor(object):

    def __init__(self, model_seq_len, rescale=None, crop=None):
        if rescale:
            self.rescale = rescale
        else:
            self.rescale = Rescale(280)
        if crop:
            self.crop = crop
        else:
            self.crop = Crop(256)

        self.pads = int(model_seq_len/2)

    def __call__(self, sequence):
        sequence, scale_correction = self.rescale(sequence)
        sequence, left = self.crop(sequence)

        sequence = torch.from_numpy(sequence).float()
        sequence /= 255

        if self.pads>0:
            padding = torch.zeros((self.pads,sequence.shape[-2],sequence.shape[-1])).float()
            sequence = torch.cat((padding,sequence,padding), dim=0)

        return sequence, scale_correction, left


class Rescale(object):

    def __init__(self, out_size):
        self.out_size = out_size

    def __call__(self, sequence):
        h, w = sequence[0,:,:].shape[:2]
        if h > w:
            new_h, new_w = self.out_size * h / w, self.out_size
        else:
            new_h, new_w = self.out_size, self.out_size * w / h

        scale_correction = np.array([[w / new_w, h / new_h],[w / new_w, h / new_h]])

        new_h_i = int(new_h)
        new_w_i = int(new_w)

        imgs = np.empty([0,new_h_i,new_w_i])

        for i in range(sequence.shape[0]):
            img = transform.resize(sequence[i,:,:], (new_h_i, new_w_i))
            img = img[np.newaxis, ...]
            imgs = np.append(imgs, img, axis=0)

        return imgs, scale_correction


class Crop(object):

    def __init__(self, out_size):
        self.out_size = out_size

    def __call__(self, sequence):
        h, w = sequence.shape[-2:]

        top = 0
        left = int((w - self.out_size)/2)

        new_h = int(self.out_size)
        new_w = int(self.out_size)

        imgs = np.empty([0,new_h,new_w])

        for i in range(sequence.shape[0]):
            img = sequence[i,top:top+new_h,left:left+new_w]
            img = img[np.newaxis, ...]
            imgs = np.append(imgs, img, axis=0)

        return imgs, left
