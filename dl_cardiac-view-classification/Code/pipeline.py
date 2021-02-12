import os
import h5py
import numpy as np
import torch
import torch.nn.functional as F

from Models import models
from preProcessor import PreProcessor

def main():

    model_name = 'ResNext' # 'CNN' - 'VGG16' - 'ResNext'

    # Use cpu as processing unit
    device = torch.device("cpu")

    # folder path to US data
    # model weights from different training data - from floydhub
    # load the model
    if model_name == 'CNN':
        file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/CNN"
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_CNN/best_weights.pth"
        model = models.CNN()
    elif model_name == 'VGG16':
        file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/VGG16"
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_VGG16/best_weights.pth"
        model = models.VGG16()
    elif model_name == 'ResNext':
        file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/ResNext"
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_ResNext/best_weights.pth"
        model = models.ResNext()
    else:
        print('Please set correct model name.')

    # Load model parameters from state dictionary
    model.load_state_dict(torch.load(model_path, map_location='cpu')['model_state_dict'])

    # Set processing unit
    model = model.to(device)

    # Turn off layers specific for training, since evaluating here
    model.eval()
    torch.set_grad_enabled(False)

    # initialize the pipeline
    preprocess = PreProcessor()

    # get the .h5 files in the directory
    processFiles = []
    for root, dirs, files in os.walk(file_dir):
        for file in files:
            if file.lower().endswith('.h5'):
                processFiles.append(file)
        break
    processFiles.sort()
    print(processFiles)

    #iterate through .h5 files in dir
    for i, file in enumerate(processFiles):
        print("File {}/{}".format(i+1, len(processFiles)))
        file_path = os.path.join(file_dir, file)

        print(file)
        raw_file = h5py.File(file_path, 'r+')

        #read the tissue images and transpose the coordinates

        # old image data formate
        # sequence = np.array(raw_file['tissue']['data'])
        # sequence = np.transpose(sequence, (2,1,0))

        # new image data format
        frame = 1

        #sequence = np.array(raw_file['tissue']['data'])
        sequence = np.array(raw_file['images'])
        #sequence = sequence.transpose(2,0,1)
        sequence, scale_correction, width = preprocess(sequence)

        frame = 0

        model_input = sequence[frame, :, :]
        model_input = model_input.unsqueeze(0).unsqueeze(0)

        #run the pipeline
        model_output = model(model_input)
        model_output = F.softmax(model_output, dim=1)
        model_output = model_output[0,:].numpy()

        #write out the detected landmarks and their movement

        #get the hdf keys
        h5_keys = raw_file.keys()

        if 'cardiac_view_probabilities' in h5_keys:
            del raw_file['cardiac_view_probabilities']
        raw_file.create_dataset('cardiac_view_probabilities', data=model_output)

        raw_file.close()

main()