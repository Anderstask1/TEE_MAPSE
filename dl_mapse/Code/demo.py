import os
import h5py
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from skimage import transform
from scipy import misc
import scipy.ndimage as nd
import matplotlib.pyplot as plt

from Models import models

root_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/val/"

files = []
for root, dirs, file in os.walk(root_dir):
    files.extend(file)
    break

def rescale(images, landmarks, out_size):
    h, w = images[0,:,:].shape[:2]
    if h > w:
        new_h, new_w = out_size * h / w, out_size
    else:
        new_h, new_w = out_size, out_size * w / h


    new_h_i = int(new_h)
    new_w_i = int(new_w)

    imgs = np.empty([0,new_h_i,new_w_i])

    for i in range(images.shape[0]):
        landmarks[i,:] = landmarks[i,:] * [new_w / w, new_h / h, new_w / w, new_h / h]
        img = transform.resize(images[i,:,:], (new_h_i, new_w_i))
        img = img[np.newaxis, ...]
        imgs = np.append(imgs, img, axis=0)

    return imgs, landmarks

def crop(images, landmarks, out_size):
    h, w = images[0,:,:].shape[:2]

    top = 0
    left = int((w - out_size)/2)

    new_h = int(out_size)
    new_w = int(out_size)

    imgs = np.empty([0,new_h,new_w])

    for i in range(images.shape[0]):
        landmarks[i,:] = landmarks[i,:] - [left, top, left, top]
        img = images[i,top:top+new_h,left:left+new_w]
        img = img[np.newaxis, ...]
        imgs = np.append(imgs, img, axis=0)

    return imgs, landmarks

model = models.Model({'arch':"CNN3D",
                      'seq_type':"short",
                      'seq_len':3,
                      'batch_size':4})
model.load_state_dict(torch.load("/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/output/best_true_weights.pth", map_location='cpu')['model_state_dict'])
device = torch.device("cpu")
model = model.to(device)
model.eval()
torch.set_grad_enabled(False)

a1 = torch.load("Project/Weights/training_info_sig2_3d5.pth", map_location='cpu')['val_info']
a2 = torch.load("Project/Weights/training_info_sig3_3d5.pth", map_location='cpu')['val_info']
a3 = torch.load("Project/Weights/training_info_sig2_3d3.pth", map_location='cpu')['val_info']
a4 = torch.load("Project/Weights/training_info_sig3_3d3.pth", map_location='cpu')['val_info']
a5 = torch.load("Project/Weights/training_info_sig2_2d.pth", map_location='cpu')['val_info']
a6 = torch.load("Project/Weights/training_info_sig3_2d.pth", map_location='cpu')['val_info']

plt.clf()
plt.plot(a1['detect_acc'][:], 'b')
plt.plot(a2['detect_acc'][:], 'r')
plt.plot(a3['detect_acc'][:], 'g')
plt.plot(a4['detect_acc'][:], 'y')
plt.plot(a5['detect_acc'][:], 'c')
plt.plot(a6['detect_acc'][:], 'm')
plt.grid(b=True, which='both')
plt.show()
"""
#plt.yscale('log')
plt.show()
plt.clf()
plt.plot(np.array(c['noise_tn'])/(np.array(c['noise_tn'])+np.array(c['noise_fp'])+1e-10), 'b')
plt.plot(np.array(d['noise_tn'])/(np.array(d['noise_tn'])+np.array(d['noise_fp'])+1e-10), 'r')
plt.grid(b=True, which='both')
plt.show()
plt.clf()
plt.plot((np.array(c['noise_tp']) + np.array(c['noise_tn']))/(np.array(c['noise_tp'])+np.array(c['noise_tn'])+np.array(c['noise_fp'])+np.array(c['noise_fn'])), 'b')
plt.plot((np.array(d['noise_tp']) + np.array(d['noise_tn']))/(np.array(d['noise_tp'])+np.array(d['noise_tn'])+np.array(d['noise_fp'])+np.array(d['noise_fn'])), 'r')
plt.show()
plt.clf()
plt.plot(2*np.array(c['noise_tp'])/(2*np.array(c['noise_tp'])+np.array(c['noise_fp'])+np.array(c['noise_fn'])), 'b')
plt.plot(2*np.array(d['noise_tp'])/(2*np.array(d['noise_tp'])+np.array(d['noise_fp'])+np.array(d['noise_fn'])), 'r')
plt.show()
"""
#plt.ion()
import cv2
import skimage.draw
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter

for k, file in enumerate(files):
    if k<4:
        continue
    #if k==3:
    #    break

    file_path = os.path.join(root_dir, file)
    raw_file = h5py.File(file_path, 'r')
    images = np.array(raw_file['images'])
    landmarks = np.array(raw_file['reference'])

    images, landmarks = rescale(images, landmarks, 240)
    images, landmarks = crop(images, landmarks, 224)


    images = torch.from_numpy(images).float()
    images /= 255
    padding = torch.zeros((1,224,224)).float()
    #images = torch.cat((padding,images,padding), dim=0)

    coord = np.empty((images.shape[0],4))

    film_l = np.zeros((images.shape[0],224,224))
    film_r = np.zeros((images.shape[0],224,224))
    for i in range(images.shape[0]):
        out = model(images[i,:,:].unsqueeze(0).unsqueeze(0).unsqueeze(0))
        out = torch.sigmoid(out)#.numpy()
        #Z = out[0,0,:,:].numpy() + out[0,1,:,:].numpy()
        #film_l[i,:,:] = out[0,0,:,:].numpy()
        #film_r[i,:,:] = out[0,1,:,:].numpy()
        out = out.ge(0.2)
        #out = (out - out.min())/(out.max() - out.min() + 1e-10)

        #fig = plt.figure()
        #ax = fig.gca(projection='3d')
        X = np.arange(0,224,1)
        Y = np.arange(0,224,1)
        X, Y = np.meshgrid(X, Y)

        #surf = ax.plot_surface(Y, X, Z, rstride=2, cstride=2, cmap=cm.coolwarm, linewidth=0)

        #ax.set_zlim(-0.01, 1.01)
        #ax.zaxis.set_major_locator(LinearLocator(5))
        #ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))


        #left = nd.median_filter(out[0,0,:,:], size=10)
        #right = nd.median_filter(out[0,1,:,:], size=10)
        left = np.array(out[0,0,:,:])
        right = np.array(out[0,1,:,:])


        left_c = nd.measurements.center_of_mass(left)
        right_c = nd.measurements.center_of_mass(right)

        plt.clf()
        #plt.imshow(Z, cmap=cm.coolwarm)
        #plt.imshow(Z, cmap='hot')
        plt.imshow(images[i,:,:], cmap="gray")
        plt.scatter(left_c[1], left_c[0], c='r')
        plt.scatter(right_c[1], right_c[0], c='r')
        plt.scatter(landmarks[i,0], landmarks[i,1], c='b')
        plt.scatter(landmarks[i,2], landmarks[i,3], c='b')
        plt.pause(0.05)

        coord[i, 0] = left_c[1]
        coord[i, 1] = left_c[0]
        coord[i, 2] = right_c[1]
        coord[i, 3] = right_c[0]

    """
    film_fl = nd.maximum_filter(film_l, size=3)
    film_fr = nd.maximum_filter(film_r, size=3)
    lol_fl = []
    lol_fr = []
    lol_l = []
    lol_r = []
    for k in range(film_l.shape[0]-2):
        l_c = nd.measurements.center_of_mass(film_l[k,:,:])
        r_c = nd.measurements.center_of_mass(film_r[k,:,:])
        fl_c = nd.measurements.center_of_mass(film_fl[k,:,:])
        fr_c = nd.measurements.center_of_mass(film_fr[k,:,:])
        plt.clf()
        #plt.imshow(film_f[k,:,:], cmap='hot')
        plt.imshow(images[k+1,:,:], alpha=1, cmap='gray')
        plt.scatter(l_c[1], l_c[0], c='r')
        plt.scatter(r_c[1], r_c[0], c='r')
        plt.scatter(fl_c[1], l_c[0], c='b')
        plt.scatter(fr_c[1], r_c[0], c='b')
        plt.pause(0.5)
        lol_l.append(l_c[0])
        lol_r.append(r_c[0])
        lol_fl.append(fl_c[0])
        lol_fr.append(fr_c[0])

    plt.clf()
    plt.plot(lol_l, 'r')
    plt.plot(lol_fl, 'b')
    plt.show()
    plt.clf()
    plt.plot(lol_r, 'r')
    plt.plot(lol_fr, 'b')
    plt.show()
    plt.clf()
    plt.plot(coord[:,1], 'b')
    plt.plot(landmarks[:,1], 'r')
    plt.show()
    plt.clf()
    plt.plot(coord[:,3], 'b')
    plt.plot(landmarks[:,3], 'r')
    plt.show()

    print(coord)
    print(images.shape)
    """
