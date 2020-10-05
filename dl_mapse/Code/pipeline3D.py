import os
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

            print("Processing frame: " + str(frame))

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
    # Toggle run locally - run on FloydHub
    isRunningLocally = True

    if isRunningLocally:
        ## Run locally
        file_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated"
        model_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_length1.pth"
        pal_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/pal.txt"
    else:
        ## Run on FloydHub
        file_dir = "/testing_data"
        model_path = "/pytorch_models/best_true_weights_Mapse_length1.pth"
        pal_path = "/pal_text_file/pal.txt"

    # Field name in h5 file, RotatedVolumes = rotated y axis, MVCenterRotatedVolumes = rotated around MV center
    #field_name = "RotatedVolumes"
    field_name = "MVCenterRotatedVolumes"

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
        raw_file = h5py.File(file_path, 'r')

        #read the tissue images and transpose the coordinates

        # old image data formate
        # sequence = np.array(raw_file['tissue']['data'])
        # sequence = np.transpose(sequence, (2,1,0))

        #iterate through all rotations
        for rotated_field in raw_file[field_name]:
            raw_file.close()
            raw_file = h5py.File(file_path, 'r')

            print(rotated_field)

            # new image data format
            sequence = np.array(raw_file[field_name][rotated_field]['images'])

            if usePal == True:
                sequence = pal[sequence.astype(int)]

            #run the pipeline
            ret_cor, left_movement, right_movement = pipeline(sequence)

            raw_file.close()

            #write out the detected landmarks and their movement
            raw_file = h5py.File(file_path, 'a')

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
