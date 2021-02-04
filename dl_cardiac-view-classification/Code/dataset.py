from __future__ import print_function, division
import os
import h5py
import torch
from skimage import transform
import numpy as np
from torch.utils.data import Dataset
import scipy.ndimage as nd

# Ignore warnings
import warnings

warnings.filterwarnings("ignore")

class UltrasoundData(Dataset):

    def __init__(self, root_dir, transform=None):

        print("---- Initializing dataset ----")

        self.transform = transform
        self.root_dir = root_dir

        files = []
        for root, dirs, file in os.walk(self.root_dir):
            files.extend(file)
            break

        sequences = []
        for file in files:
            if ".h5" in file:
                file_path = os.path.join(self.root_dir, file)
                raw_file = h5py.File(file_path, 'r')
                frames = np.array(raw_file['images'])

                for i in range(frames.shape[0]):
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

        # apply pal to the images
        # pal_txt = open('/home/gkiss/dl/pal.txt')
        # line = pal_txt.readline()[:-1]
        # pal = np.array([float(val) for val in line.split(',')])
        # images = pal[images.astype(int)]

        cardiac_views = np.array(file['reference'])

        image, cardiac_view = self.slice(images, cardiac_views, file_number)

        sample = {'image': image, 'cardiac_view': cardiac_view}

        if self.transform:
            sample = self.transform(sample)

        return sample

    def slice(self, images, cardiac_views, file_number):
        image = images[file_number, :, :]
        cardiac_view = cardiac_views[file_number]

        return image, cardiac_view


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
        image, cardiac_view = sample['image'], sample['cardiac_view']

        h, w = image[:, :].shape[:2]
        if isinstance(self.output_size, int):
            if h > w:
                new_h, new_w = self.output_size * h / w, self.output_size
            else:
                new_h, new_w = self.output_size, self.output_size * w / h
        else:
            new_h, new_w = self.output_size

        new_h_i, new_w_i = int(new_h), int(new_w)

        img = transform.resize(image[:, :], (new_h_i, new_w_i))
        #img = img[np.newaxis, ...]

        return {'image': img, 'cardiac_view': cardiac_view}


class Crop(object):

    def __init__(self, output_size):
        self.output_size = output_size

    def __call__(self, sample):
        image, cardiac_view = sample['image'], sample['cardiac_view']

        h, w = image[:, :].shape[:2]

        new_h, new_w = int(self.output_size), int(self.output_size)

        top = 0
        left = int((w - self.output_size) / 2)

        img = image[top:top + new_h, left:left + new_w]
        #img = img[np.newaxis, ...]

        return {'image': img, 'cardiac_view': cardiac_view}


class RandomCrop(object):

    def __init__(self, output_size):
        self.output_size = output_size

    def __call__(self, sample):
        image, cardiac_view = sample['image'], sample['cardiac_view']

        h, w = image[:, :].shape[:2]

        new_h, new_w = int(self.output_size), int(self.output_size)

        random_top = np.random.randint(h - new_h)
        random_left = np.random.randint(w - new_w)

        img = image[random_top:random_top + new_h, random_left:random_left + new_w]
        #img = img[np.newaxis, ...]

        return {'image': img, 'cardiac_view': cardiac_view}


class RandomRotation(object):

    def __init__(self, degrees):
        self.degrees = degrees

    def __call__(self, sample):
        image, cardiac_view = sample['image'], sample['cardiac_view']

        h, w = image[:, :].shape[:2]

        deg = np.random.randint(-self.degrees, self.degrees)

        img = transform.rotate(image[:, :], deg)
        #img = img[np.newaxis, ...]

        return {'image': img, 'cardiac_view': cardiac_view}

    def rotate(self, origin, point, angle):

        ox, oy = origin
        px, py = point

        qx = ox + np.cos(angle) * (px - ox) - np.sin(angle) * (py - oy)
        qy = oy + np.sin(angle) * (px - ox) + np.cos(angle) * (py - oy)

        return qx, qy


class ToTensor(object):
    def __call__(self, sample):
        image, cardiac_view = sample['image'], sample['cardiac_view']

        image /= 255

        sample = {'image': torch.from_numpy(image).unsqueeze(0).float(),
                  'cardiac_view': torch.tensor(cardiac_view)}

        return sample

