import h5py
import matplotlib.pyplot as plt
import numpy as np
import os
import argparse
import sys
import re

# natural sorting of list
def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

#user input from matplotlib figure
user_input = None
def press(event):
    global user_input
    user_input = event.key

def main():
    #user input
    plt.ion()
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--data-path')
    args = parser.parse_args()

    root_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotating"

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
        if 'ClassAnnotations' in h5_keys:
            del f_read_write['ClassAnnotations']
        f_read_write.create_group('ClassAnnotations')

        rotated_fields = list(f_read_write['MVCenterRotatedVolumes'].keys())
        rotated_fields.sort(key=natural_keys)

        idx = 0

        # iterate through all rotations
        #for rotated_field in cycle(rotated_fields):
        while True:
            rotated_field = rotated_fields[idx]
            tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])

            imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[2]))

            print(rotated_field)
            print("\n")

            plt.imshow(np.transpose(tissue[frame,:,:]), cmap='gray')

            plt.gcf().canvas.mpl_connect('key_press_event', press)

            print("4C = 1, 2C = 2, ALAX = 3\n")

            while not plt.waitforbuttonpress(100000): pass

            plt.clf()

            if user_input == "1" or user_input == "2" or user_input == "3":
                # get the hdf key
                h5_keys = f_read_write['ClassAnnotations'].keys()

                # create group in hdf5 file for annotations
                if rotated_field in h5_keys:
                    del f_read_write['ClassAnnotations'][rotated_field]
                f_read_write['ClassAnnotations'].create_group(rotated_field)

                # get the hdf keys
                h5_keys = f_read_write['ClassAnnotations'][rotated_field].keys()

                if 'reference' in h5_keys:
                    del f_read_write['ClassAnnotations'][rotated_field]['reference']
                f_read_write['ClassAnnotations'][rotated_field].create_dataset('reference', data=user_input)

                print("Annotated ", rotated_field, " as ", user_input, ". \n")

            elif user_input == "c":
                print("Saving and closing file\n")
                break
            elif user_input == "left":
                if idx == 0:
                    idx = len(rotated_fields)-1
                else:
                    idx -= 1
            else:
                if idx == len(rotated_fields)-1:
                    idx = 0
                else:
                    idx += 1
                continue

        f_read_write.close()

main()