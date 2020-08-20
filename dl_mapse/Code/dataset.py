from __future__ import print_function, division
import os
import h5py
import torch
import torch.nn as nn
from skimage import io, transform
import numpy as np
import matplotlib.pyplot as plt
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
import scipy.ndimage as nd

# Ignore warnings
import warnings
warnings.filterwarnings("ignore")

class UltrasoundData(Dataset):

    def __init__(self, root_dir, seq_type, seq_len, transform=None):

        print("---- Initializing dataset ----")

        self.transform = transform
        self.root_dir = root_dir
        self.seq_type = seq_type
        self.seq_len = seq_len

        files = []
        for root, dirs, file in os.walk(self.root_dir):
            files.extend(file)
            break

        sequences = []
        for file in files:
            file_path = os.path.join(self.root_dir, file)
            raw_file = h5py.File(file_path, 'r')
            frames = np.array(raw_file['images'])

            if self.seq_type == "short":
                for i in range(frames.shape[0]):
                    sequences.append("{}_{:0>3d}".format(file, i))
            elif self.seq_type == "long":
                residue = int(frames.shape[0]/self.seq_len)
                for i in range(residue+1):
                    sequences.append("{}_{:0>3d}".format(file, i))

        self.sequences = sequences

    def __len__(self):
        return len(self.sequences)

    def __getitem__(self, idx):
        file_name = self.sequences[idx][:-4]
        file_number = int(self.sequences[idx][-3:])
        file_path = os.path.join(self.root_dir, file_name)
        file = h5py.File(file_path, 'r')

        images = np.array(file['images'])
        
        #apply pal to the images
        #pal_txt = open('/home/gkiss/dl/pal.txt')
        #line = pal_txt.readline()[:-1]
        #pal = np.array([float(val) for val in line.split(',')])      
        #images = pal[images.astype(int)]
        

        landmarks = np.array(file['reference'])

        images, landmarks = self.slice(images, landmarks, file_number)
        landmarks = self.cleanLandmarks(landmarks)

        sample = {'images':images, 'landmarks':landmarks}

        if self.transform:
            sample = self.transform(sample)

        return sample

    def slice(self, images, landmarks, file_number):
        if self.seq_type == "short":
            if file_number<int(self.seq_len/2):
                img_padding = np.zeros((int(self.seq_len/2)-file_number, images.shape[1], images.shape[2]))
                land_padding = np.zeros((int(self.seq_len/2)-file_number, landmarks.shape[1]))
                images = np.concatenate((img_padding,
                                         images[:file_number+int(self.seq_len/2)+1,:,:]), axis=0)
                landmarks = landmarks[file_number,:]
            elif file_number>=images.shape[0]-int(self.seq_len/2):
                img_padding = np.zeros((int(self.seq_len/2)-((images.shape[0]-1)-file_number),
                                    images.shape[1], images.shape[2]))
                land_padding = np.zeros((int(self.seq_len/2)-((images.shape[0]-1)-file_number),
                                    landmarks.shape[1]))
                images = np.concatenate((images[file_number-int(self.seq_len/2):,:,:], img_padding), axis=0)
                landmarks = landmarks[file_number,:]
            else:
                images = images[file_number-int(self.seq_len/2):file_number+int(self.seq_len/2)+1,:,:]
                landmarks = landmarks[file_number,:]
        elif self.seq_type == "long":
            if (images.shape[0]-file_number*self.seq_len)<self.seq_len:
                img_padding = np.zeros((self.seq_len-(images.shape[0]-file_number*self.seq_len),
                                    images.shape[1], images.shape[2]))
                land_padding = np.zeros((self.seq_len-(images.shape[0]-file_number*self.seq_len),
                                    landmarks.shape[1]))
                images = np.concatenate((images[file_number*self.seq_len:,:,:], img_padding), axis=0)
                landmarks = np.concatenate((landmarks[file_number*self.seq_len:,:], land_padding), axis=0)
            else:
                images = images[file_number*self.seq_len:file_number*self.seq_len+self.seq_len,:,:]
                landmarks = landmarks[file_number*self.seq_len:file_number*self.seq_len+self.seq_len,:]
        return images, landmarks

    def cleanLandmarks(self, landmarks):
        if self.seq_type=="short":
            if (landmarks[0] == 1.0 and landmarks[1] == 1.0):
                landmarks[0], landmarks[1] = -1.0, -1.0
            if (landmarks[2] == 1.0 and landmarks[3] == 1.0):
                landmarks[2], landmarks[3] = -1.0, -1.0

        else:
            for i in range(self.seq_len):
                if (landmarks[i,0] == 1.0 and landmarks[i,1] == 1.0):
                    landmarks[i,0], landmarks[i,1] = -1.0, -1.0
                if (landmarks[i,2] == 1.0 and landmarks[i,3] == 1.0):
                    landmarks[i,2], landmarks[i,3] = -1.0, -1.0
        return landmarks



class Rescale(object):
    """Rescale the image in a sample to a given size.

    Args:
        output_size (tuple or int): Desired output size. If tuple, output is
            matched to output_size. If int, smaller of image edges is matched
            to output_size keeping aspect ratio the same.
    """

    def __init__(self, output_size):
        assert isinstance(output_size, (int, tuple))
        self.output_size = output_size

    def __call__(self, sample):
        image, landmarks = sample['images'], sample['landmarks']

        h, w = image[0,:,:].shape[:2]
        if isinstance(self.output_size, int):
            if h > w:
                new_h, new_w = self.output_size * h / w, self.output_size
            else:
                new_h, new_w = self.output_size, self.output_size * w / h
        else:
            new_h, new_w = self.output_size

        new_h_i, new_w_i = int(new_h), int(new_w)
        imgs = np.empty([0,new_h_i,new_w_i])

        if landmarks.ndim < 2:
            landmarks[:] = landmarks[:] * [new_w / w, new_h / h,new_w / w, new_h / h]

        for i in range(image.shape[0]):

            img = transform.resize(image[i,:,:], (new_h_i, new_w_i))
            img = img[np.newaxis,...]
            imgs = np.append(imgs, img, axis=0)

            if landmarks.ndim >= 2:
                landmarks[i,:] = landmarks[i,:] * [new_w / w, new_h / h,new_w / w, new_h / h]

        return {'images': imgs, 'landmarks': landmarks}

class Crop(object):

    def __init__(self, output_size):
        self.output_size = output_size

    def __call__(self, sample):
        images, landmarks = sample['images'], sample['landmarks']

        h, w = images[0,:,:].shape[:2]

        new_h, new_w = int(self.output_size), int(self.output_size)

        top = 0
        left = int((w - self.output_size)/2)

        imgs = np.empty([0, new_h, new_w])

        if landmarks.ndim < 2:
            landmarks[:] = landmarks[:] - [left, top, left, top]

        for i in range(images.shape[0]):

            img = images[i,top:top+new_h,left:left+new_w]
            img = img[np.newaxis,...]
            imgs = np.append(imgs, img, axis=0)

            if landmarks.ndim >= 2:
                landmarks[i,:] = landmarks[i,:] - [left, top, left, top]

        return {'images':imgs, 'landmarks':landmarks}

class RandomCrop(object):

    def __init__(self, output_size):
        self.output_size = output_size

    def __call__(self, sample):
        images, landmarks = sample['images'], sample['landmarks']

        h, w = images[0,:,:].shape[:2]

        new_h, new_w = int(self.output_size), int(self.output_size)

        random_top = np.random.randint(0, h-new_h)
        random_left = np.random.randint(0, w-new_w)

        imgs = np.empty([0, new_h, new_w])

        if landmarks.ndim < 2:
            landmarks[:] = landmarks[:] - [random_left, random_top, random_left, random_top]

        for i in range(images.shape[0]):

            img = images[i,random_top:random_top+new_h,random_left:random_left+new_w]
            img = img[np.newaxis,...]
            imgs = np.append(imgs, img, axis=0)

            if landmarks.ndim >= 2:
                landmarks[i,:] = landmarks[i,:] - [random_left, random_top, random_left, random_top]

        return {'images':imgs, 'landmarks':landmarks}

class RandomRotation(object):

    def __init__(self, degrees):
        self.degrees = degrees

    def __call__(self, sample):
        images, landmarks = sample['images'], sample['landmarks']

        deg = np.random.randint(-self.degrees, self.degrees)
        h, w = images[0,:,:].shape[:2]
        origin = [w/2-0.5, h/2-0.5]

        imgs = np.empty([0, h, w])

        if landmarks.ndim < 2:
            landmarks[0], landmarks[1] = self.rotate(origin,
                                                         [landmarks[0], landmarks[1]], np.radians(-deg))
            landmarks[2], landmarks[3] = self.rotate(origin,
                                                         [landmarks[2], landmarks[3]], np.radians(-deg))

        for i in range(images.shape[0]):
            img = transform.rotate(images[i,:,:], deg)
            img = img[np.newaxis,...]
            imgs = np.append(imgs, img, axis=0)

            if landmarks.ndim >= 2:
                landmarks[i,0], landmarks[i,1] = self.rotate(origin,
                                                             [landmarks[i,0], landmarks[i,1]], np.radians(-deg))
                landmarks[i,2], landmarks[i,3] = self.rotate(origin,
                                                             [landmarks[i,2], landmarks[i,3]], np.radians(-deg))



        return {'images':imgs, 'landmarks':landmarks}

    def rotate(self, origin, point, angle):

        ox, oy = origin
        px, py = point

        qx = ox + np.cos(angle) * (px-ox) - np.sin(angle) * (py-oy)
        qy = oy + np.sin(angle) * (px-ox) + np.cos(angle) * (py-oy)

        return qx, qy

class ToTensor(object):

    def __init__(self, sigma):
        self.sigma = sigma

    def __call__(self, sample):
        images, landmarks = sample['images'], sample['landmarks']

        images /= 255

        masks = np.zeros((2,images.shape[1],images.shape[2]), dtype=float)

        x_l = int(round(landmarks[0]))
        y_l = int(round(landmarks[1]))
        x_r = int(round(landmarks[2]))
        y_r = int(round(landmarks[3]))

        if x_l>0.0 and y_l>0.0 and x_l<images.shape[2] and y_l<images.shape[1]:
            masks[0,y_l,x_l] = 1.0
            masks[0,:,:] = nd.gaussian_filter(masks[0,:,:], sigma=self.sigma, mode='constant')
            masks[0,:,:] = masks[0,:,:]/masks[0,:,:].max()
        if x_r>0.0 and y_r>0.0 and x_r<images.shape[2] and y_r<images.shape[1]:
            masks[1,y_r,x_r] = 1.0
            masks[1,:,:] = nd.gaussian_filter(masks[1,:,:], sigma=self.sigma, mode='constant')
            masks[1,:,:] = masks[1,:,:]/masks[1,:,:].max()

        sample = {'images':torch.from_numpy(images).unsqueeze(0).float(),
                  'landmarks':torch.from_numpy(landmarks).float(),
                  'masks':torch.from_numpy(masks).float()}

        return sample

