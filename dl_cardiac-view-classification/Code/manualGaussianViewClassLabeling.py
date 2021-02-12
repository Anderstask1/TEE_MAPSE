import h5py
import matplotlib.pyplot as plt
import numpy as np
import os
import argparse
import sys
import re

from itertools import cycle

# natural sorting of list
def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

#user input
plt.ion()
parser = argparse.ArgumentParser()
parser.add_argument('-d', '--data-path')
args = parser.parse_args()

#or hard coded
root_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data"

# Frame in sequence to visualize and evaluate
frame = 0

# User input file path (in order to mach matlab script from command line)
if len(sys.argv) > 1:
    root_dir = str(sys.argv[2])

print('File path is: ', root_dir)
print(sys.argv)

#get the .h5 files in the directory
processFiles = []
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.lower().endswith('.h5'):
                processFiles.append(file)
    break
processFiles.sort()
print(processFiles)

#iterate through .h5 files in dir
for i, file in enumerate(processFiles):
    print("File {}/{}".format(i+1, len(processFiles)))
    file_path = os.path.join(root_dir, file)

    print(file)

    f_read_write = h5py.File(file_path, 'r+')

    # get the hdf keys
    h5_keys = f_read_write.keys()

    # create group in hdf5 file for annotations
    if 'Annotations' in h5_keys:
        del f_read_write['Annotations']
    f_read_write.create_group('Annotations')

    rotated_fields = list(f_read_write['MVCenterRotatedVolumes'].keys())
    rotated_fields.sort(key=natural_keys)

    # iterate through all rotations
    for rotated_field in cycle(rotated_fields):

        tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])

        imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[2]))

        print(rotated_field)
        print("\n")

        plt.imshow(np.transpose(tissue[frame,:,:]), cmap='gray')

        user_input = plt.waitforbuttonpress(timeout= 10)

        if user_input:
            class_idx = input(
                "Please enter a class index for the view (same for all frames in sequence):\n" \
                +"4C = 0, 2C = 1, ALAX = 2\n" \
                +"Enter c if you wish to exit\n")
            plt.clf()

            if class_idx == "0":
                print("View marked ass 4C - Four Chamber\n")
            elif class_idx == "1":
                print("View marked ass 2C - Two Chamber\n")
            elif class_idx == "2":
                print("View marked ass ALAX - Apical Long Axis\n")
            elif class_idx == "":
                print("View skipped\n")
            elif class_idx == "c":
                print("Saving and closing file\n")
                break
            else:
                print("Marked class not valid, please redo annotation of this view\n")
        else:
            plt.clf()
            continue

        # get the hdf ke
        h5_keys = f_read_write['Annotations'].keys()

        #create group in hdf5 file for annotations
        if rotated_field in h5_keys:
            del f_read_write['Annotations'][rotated_field]
        f_read_write['Annotations'].create_group(rotated_field)

        # get the hdf keys
        h5_keys = f_read_write['Annotations'][rotated_field].keys()

        if 'reference' in h5_keys:
            del f_read_write['Annotations'][rotated_field]['reference']
        f_read_write['Annotations'][rotated_field].create_dataset('reference', data=class_idx)

    f_read_write.close()
