import os
import sys
import cv2
import h5py
import numpy as np
import torch
import matplotlib.pyplot as plt
from scipy import stats
import scipy.ndimage as nd
import cv2

from Models import models
from preProcessor import PreProcessor
from postProcessor import PostProcessor


class Pipeline(object):

    def __init__(self, preprocess, landmarkDetect, postprocess):
        self.preprocess = preprocess
        self.landmarkDetect = landmarkDetect
        self.postprocess = postprocess

    def __call__(self, sequence):
        seq, scale_correction, width = self.preprocess(sequence)
        predicted_sequence = self.landmarkDetect(seq)
        ret_cor, left_movement, right_movement = self.postprocess(predicted_sequence, width, scale_correction)

        #fourcc = cv2.VideoWriter_fourcc(*'XVID')
        #video = cv2.VideoWriter(video_filename, fourcc, 60, (640, 476))

        # for i in range(sequence.shape[0]):
        #     plt.clf()
        #     img = sequence[i,:,:]
        #     #cv2.circle(img,(100,100),200,(255),-1)
        #     plt.imshow(img, cmap='gray')
        #     #plt.imshow(sequence[i,:,:], cmap='gray')
        #     plt.scatter(ret_cor[i,0], ret_cor[i,1],c='r')
        #     plt.scatter(ret_cor[i,2], ret_cor[i,3],c='r')
        #     plt.pause(0.1)

        #     #save the plot as a png
        #     #img_name = "C:/temp/img%03d.png" % i
        #     #plt.savefig(img_name)
        #     # convert canvas to image
        #     ax = plt.gca()
        #     canvas = ax.figure.canvas
        #     img = np.fromstring(canvas.tostring_rgb(), dtype=np.uint8, sep='')
        #     img  = img.reshape(canvas.get_width_height()[::-1] + (3,))

        #     # img is rgb, convert to opencv's default bgr
        #     img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
        #     video.write(img)

        # #release the video file
        # video.release()

        return ret_cor, left_movement, right_movement


class LandmarkDetector(object):

    def __init__(self, model, model_seq_len):
        self.model = model
        self.model_seq_len = model_seq_len

    def __call__(self, sequence):
        predicted_sequence = torch.empty((sequence.shape[0]-(self.model_seq_len-1),2,sequence.shape[-2],sequence.shape[-1])).float()

        for frame in range(sequence.shape[0]-(self.model_seq_len-1)):
            model_input = self.fetch_input(sequence, frame)
            prediction_masks = torch.sigmoid(self.model(model_input))
            predicted_sequence[frame,:,:,:] = prediction_masks[0,:,:,:]

            #print("Processing frame: " + str(frame))

            #plt.clf()
            #plt.imshow(predicted_sequence[frame,0,:,:], cmap='gray')
            #plt.show()

            #plt.clf()
            #plt.imshow(predicted_sequence[frame,1,:,:], cmap='gray')
            #plt.show()

            #plt.clf()
            #plt.imshow(model_input[0,0,1,:,:], cmap='gray')
            #plt.show()

        return predicted_sequence

    def fetch_input(self, sequence, frame):
        if self.model_seq_len > 1:
            model_input = sequence[frame:frame+self.model_seq_len,:,:]
            model_input = model_input.unsqueeze(0).unsqueeze(0)
        else:
            model_input = sequence[frame,:,:]
            model_input = model_input.unsqueeze(0).unsqueeze(0).unsqueeze(0)

        return model_input


def main():

    file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentAnnotatingData"
    #model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_length1.pth" #trym pre-trained

    #model weights from different training data - from floydhub
    #model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_old.pth"
    model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_new.pth"
    #model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_mix1.pth"
    #model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_mix2.pth"

    pal_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/pal.txt"

    # Field name in h5 file, RotatedVolumes = rotated y axis, MVCenterRotatedVolumes = rotated around MV center
    # Default value
    field_name = "RotatedVolumes"
    #field_name = "MVCenterRotatedVolumes"

    ## User input field name ("RotatedVolumes" or "MVCenterRotatedVolumes")
    # Only use first input argument (second element, after pipeline3d.py)
    if len(sys.argv) > 1:
        user_input = str(sys.argv[1])
        #if user_input == "RotatedVolumes" or user_input == "MVCenterRotatedVolumes":
        field_name = user_input

    # User input file path (in order to mach matlab script from command line)
    if len(sys.argv) > 2:
        user_input = str(sys.argv[2])
        file_dir = user_input

    threshold = None
    if len(sys.argv) > 3:
        user_input = str(sys.argv[3])
        threshold = float(user_input)

    if len(sys.argv) > 4:
        user_input = str(sys.argv[4])
        model_path = user_input

    print('Fieldname is: ', field_name)
    print('File path is: ', file_dir)
    print('Model path is: ', model_path)

    model_seq_len = 1
    usePal = False

    eps = 1e-10

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
    model = models.Model(model_seq_len)

    # Load model parameters from state dictionary
    model.load_state_dict(torch.load(model_path, map_location='cpu')['model_state_dict'])

    # Set processing unit
    model = model.to(device)

    # Turn off layers specific for training, since evaluating here
    model.eval()
    torch.set_grad_enabled(False)

    #initialize the pipeline
    preprocess = PreProcessor(model_seq_len)
    landmark_detector = LandmarkDetector(model, model_seq_len)

    if threshold is not None:
        postprocess = PostProcessor(None, None, None, threshold)
    else:
        postprocess = PostProcessor()

    pipeline = Pipeline(preprocess,landmark_detector,postprocess)

    #read pal
    pal_txt = open(pal_path)
    line = pal_txt.readline()[:-1]
    pal = np.array([float(val) for val in line.split(',')])

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

        # check if file is rotated around mv center, skip if not
        keys = raw_file.keys()
        if not field_name in keys:
            print("Skipped file ", file, "since it is not rotated around mv center.")
            continue

        #iterate through all rotations
        for rotated_field in raw_file[field_name]:

            print(rotated_field)
            if usePal == True:
                sequence = pal[sequence.astype(int)]
            # new image data format
            sequence = np.array(raw_file[field_name][rotated_field]['images'])

            if usePal == True:
                sequence = pal[sequence.astype(int)]

            #run the pipeline
            ret_cor, left_movement, right_movement = pipeline(sequence)

            #write out the detected landmarks and their movement

            #get the hdf keys
            h5_keys = raw_file[field_name][rotated_field].keys()

            #update the MAPSE related fields
            if 'MAPSE_detected_landmarks' in h5_keys:
                del raw_file[field_name][rotated_field]['MAPSE_detected_landmarks']
            raw_file[field_name][rotated_field].create_dataset('MAPSE_detected_landmarks', data=ret_cor)

            if 'MAPSE_left_movement' in h5_keys:
                del raw_file[field_name][rotated_field]['MAPSE_left_movement']
            raw_file[field_name][rotated_field].create_dataset(
                'MAPSE_left_movement', data=left_movement['y_complete'])

            if 'MAPSE_right_movement' in h5_keys:
                del raw_file[field_name][rotated_field]['MAPSE_right_movement']
            raw_file[field_name][rotated_field].create_dataset(
                'MAPSE_right_movement', data=right_movement['y_complete'])

        raw_file.close()

main()
