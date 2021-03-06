import os
import h5py
import numpy as np
import torch
import torch.nn.functional as F
import sys

from Models import models
from preProcessor import PreProcessor

def main():
    # 'CNN_classification' - 'CNN_regression' - 'VGG16_classification' - 'VGG16_regression' - 'ResNext_classification' - 'ResNext_regression'
    model_name = 'CNN_regression'

    if len(sys.argv) > 1:
        model_name = str(sys.argv[1])

    # Use cpu as processing unit
    device = torch.device("cpu")

    # folder path to US data
    #file_dir = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData'
    file_dir = '/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated/'

    # model weights from different training data - from floydhub
    # load the model
    if model_name == 'CNN_classification':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_CNN_mix/best_weights.pth"
        model = models.CNN_classification()
    if model_name == 'CNN_regression':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_CNN_gaussian_new_1degree/best_weights.pth"
        model = models.CNN_regression()
    elif model_name == 'VGG16_classification':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_VGG16/best_weights.pth"
        model = models.VGG16_classification()
    elif model_name == 'VGG16_regression':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_VGG16_new_1degree/best_weights.pth"
        model = models.VGG16_regression()
    elif model_name == 'ResNext_classification':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_ResNext_new/best_weights.pth"
        model = models.ResNext_classification()
    elif model_name == 'ResNext_regression':
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_ResNext_new_1degree/best_weights.pth"
        model = models.ResNext_regression()
    else:
        print('Please set correct model name.')

    print()
    print("File path: " + file_dir + "\n")
    print("Running pipeline with model: " + model_name + "\n")
    print("Model path: " + model_path + "\n")
    print()

    if torch.cuda.is_available():
        print("Using cuda for gpu-accelerated computations")
    else:
        print("Using cpu for computations")

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

        # get the hdf keys for rotated volumes
        h5_keys = raw_file['MVCenterRotatedVolumes'].keys()

        for fn in h5_keys:
            print('Classifying cardiac view on image: ', fn)

            sequence = np.array(raw_file['MVCenterRotatedVolumes'][fn]['images'])
            #sequence = sequence.transpose(2,0,1)
            sequence, scale_correction, width = preprocess(sequence)

            frame = 0

            model_input = sequence[frame, :, :]
            model_input = model_input.unsqueeze(0).unsqueeze(0)

            #run the pipeline
            model_output = model(model_input)
            model_output = F.softmax(model_output, dim=1)
            model_output = model_output[0,:].numpy()

            #get the hdf keys
            h5_keys = raw_file['MVCenterRotatedVolumes'][fn].keys()

            if 'cardiac_view_probabilities' in h5_keys:
                del raw_file['MVCenterRotatedVolumes'][fn]['cardiac_view_probabilities']
            raw_file['MVCenterRotatedVolumes'][fn].create_dataset('cardiac_view_probabilities', data=model_output)

        raw_file.close()

main()