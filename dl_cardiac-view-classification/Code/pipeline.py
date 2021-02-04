import os
import h5py
import numpy as np
import torch

from Models import models
from preProcessor import PreProcessor

def main():

    file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData"

    #model weights from different training data - from floydhub
    model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_CNN/best_weights.pth"

    #get the .h5 files in the directory
    processFiles = []
    for root, dirs, files in os.walk(file_dir):
        for file in files:
            if file.lower().endswith('.h5'):
                    processFiles.append(file)
        break
    processFiles.sort()
    print(processFiles)

    # Use cpu as processing unit
    device = torch.device("cpu")

    #load the model
    model = models.CNN()

    # Load model parameters from state dictionary
    model.load_state_dict(torch.load(model_path, map_location='cpu')['model_state_dict'])

    # Set processing unit
    model = model.to(device)

    # Turn off layers specific for training, since evaluating here
    model.eval()
    torch.set_grad_enabled(False)

    # initialize the pipeline
    preprocess = PreProcessor()

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
        sequence = np.array(raw_file['tissue']['data'])
        sequence = sequence.transpose(2,0,1)
        sequence, scale_correction, width = preprocess(sequence)
        model_input = sequence[frame, :, :]
        model_input = model_input.unsqueeze(0).unsqueeze(0)

        #run the pipeline
        model_output = model(model_input)
        model_output = model_output[0,:].numpy()
        image_view_class = max(range(len(model_output)), key=model_output.__getitem__) # get index of max element

        #write out the detected landmarks and their movement

        #get the hdf keys
        h5_keys = raw_file.keys()

        #update the MAPSE related fields
        if 'detected_cardiac_view' in h5_keys:
            del raw_file['detected_cardiac_view']
        raw_file.create_dataset('detected_cardiac_view', data=image_view_class)

        raw_file.close()

main()