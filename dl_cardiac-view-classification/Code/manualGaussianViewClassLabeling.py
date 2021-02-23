import h5py
import matplotlib.pyplot as plt
import numpy as np
import os
import argparse
import sys
import re
import scipy.stats

from itertools import cycle

# natural sorting of list
def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

def gaussianViewClassWeighting(root_dir, processFiles, rotated_fields):
    # iterate through .h5 files in dir
    for i, file in enumerate(processFiles):
        print("File {}/{}".format(i + 1, len(processFiles)))
        file_path = os.path.join(root_dir, file)

        print(file)

        f_read_write = h5py.File(file_path, 'r+')

        # get the hdf keys
        h5_keys = f_read_write.keys()

        #check if class annotated
        if 'ClassAnnotations' in h5_keys:

            # create group in hdf5 file for annotations
            if 'Annotations' in h5_keys:
                del f_read_write['Annotations']
            f_read_write.create_group('Annotations')

            rotation_4C, rotation_2C, rotation_ALAX = -1, -1, -1

            # iterate through all annotations
            for annotated_field in f_read_write['ClassAnnotations']:
                field_value = f_read_write['ClassAnnotations'][annotated_field]['reference'].value
                if field_value:
                    class_idx = int(field_value) #get field value
                    rotation_angle = int(annotated_field.split('_')[2]) #parse field name
                    if class_idx == 1:
                        rotation_4C = rotation_angle
                    elif class_idx == 2:
                        rotation_2C = rotation_angle
                    elif class_idx == 3:
                        rotation_ALAX = rotation_angle
                    else:
                        print('Error reading annotation.')

            #set gaussian annotation weighting for images based on dist from 2c, 4c and alax
            # iterate through all rotations
            for rotated_field in rotated_fields:
                #parse rotation angle
                rotation_angle = int(rotated_field.split('_')[2])

                #find angular distance to closest annotated view
                frac_dist_4C = (rotation_angle - rotation_4C + 180) % 360 - 180
                frac_dist_2C = (rotation_angle - rotation_2C + 180) % 360 - 180
                frac_dist_ALAX = (rotation_angle - rotation_ALAX + 180) % 360 - 180
                peak_dist = min(frac_dist_4C, frac_dist_2C, frac_dist_ALAX, key=abs)

                #set annotation weight by gaussian dist
                if frac_dist_4C == peak_dist:
                    if frac_dist_4C > 0:
                        sd = abs((rotation_4C - rotation_2C + 180) % 360 - 180)/3
                    else:
                        sd = abs((rotation_4C - rotation_ALAX + 180) % 360 - 180) / 3
                elif frac_dist_2C == peak_dist:
                    if frac_dist_2C > 0:
                        sd = abs((rotation_2C - rotation_ALAX + 180) % 360 - 180) / 3
                    else:
                        sd = abs((rotation_2C - rotation_4C + 180) % 360 - 180) / 3
                elif frac_dist_ALAX == peak_dist:
                    if frac_dist_ALAX > 0:
                        sd = abs((rotation_ALAX - rotation_4C + 180) % 360 - 180) / 3
                    else:
                        sd = abs((rotation_ALAX - rotation_2C + 180) % 360 - 180) / 3

                gaussian_tail = np.exp(-(peak_dist / (np.sqrt(2) * sd)) ** 2)
                annotation_weight = 3 - (1 - gaussian_tail)

                #save annotation
                # get the hdf key
                h5_keys = f_read_write['Annotations'].keys()

                # create group in hdf5 file for annotations
                if rotated_field in h5_keys:
                    del f_read_write['Annotations'][rotated_field]
                f_read_write['Annotations'].create_group(rotated_field)

                # get the hdf keys
                h5_keys = f_read_write['Annotations'][rotated_field].keys()

                if 'reference' in h5_keys:
                    del f_read_write['Annotations'][rotated_field]['reference']
                f_read_write['Annotations'][rotated_field].create_dataset('reference', data=annotation_weight)

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

        temp = cycle(rotated_fields)

        # iterate through all rotations
        for rotated_field in cycle(rotated_fields):

            tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])

            imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[2]))

            print(rotated_field)
            print("\n")

            plt.imshow(np.transpose(tissue[frame,:,:]), cmap='gray')

            plt.gcf().canvas.mpl_connect('key_press_event', press)

            print("4C = 1, 2C = 2, ALAX = 3\n")

            while not plt.waitforbuttonpress(100000): pass

            if user_input == "1" or user_input == "2" or user_input == "3":
                plt.clf()

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
            else:
                plt.clf()
                continue

        f_read_write.close()

    # set Gaussian weighting for rotations close to 2C, 4C and ALAX views
    gaussianViewClassWeighting(root_dir, processFiles, rotated_fields)
main()


