import h5py
import matplotlib.pyplot as plt
import numpy as np
import os
import argparse
import sys

#user input
plt.ion()
parser = argparse.ArgumentParser()
parser.add_argument('-d', '--data-path')
args = parser.parse_args()

#or hard coded
root_dir = "/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotateProcessingFiles"

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

    # iterate through all rotations
    for counter, rotated_field in enumerate(f_read_write['MVCenterRotatedVolumes']):

        tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])

        ref_coord = np.empty(shape=(0,4))
        imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[2]))
        print(rotated_field)
        print('File: ', counter, '/', len(f_read_write['MVCenterRotatedVolumes']))

        coordinates = [(0,0),(0,0),(0,0)]

        for i in range(tissue.shape[0]):
            plt.imshow(np.transpose(tissue[i,:,:]), cmap='gray')
            plt.pause(0.01)
            plt.clf()

        for i in range(tissue.shape[0]):
            plt.imshow(np.transpose(tissue[i,:,:]), cmap='gray')

            fig = plt.gcf()
            fig.set_size_inches(10,10)

            coordinates = plt.ginput(n=2, timeout=0, show_clicks=True)
            plt.clf()
            plt.scatter(coordinates[0][0], coordinates[0][1], color='b', marker='*', alpha=0.2)
            plt.scatter(coordinates[1][0], coordinates[1][1], color='b', marker='*', alpha=0.2)

            ref_coord = np.append(ref_coord, np.array([[coordinates[0][0],
                                                        coordinates[0][1],
                                                        coordinates[1][0],
                                                        coordinates[1][1]]]), axis=0)

        # get the hdf keys
        h5_keys = f_read_write['Annotations'].keys()

        #create group in hdf5 file for annotations
        if rotated_field in h5_keys:
            del f_read_write['Annotations'][rotated_field]
        f_read_write['Annotations'].create_group(rotated_field)

        # get the hdf keys
        h5_keys = f_read_write['Annotations'][rotated_field].keys()

        if 'ref_coord' in h5_keys:
            del f_read_write['Annotations'][rotated_field]['ref_coord']
        f_read_write['Annotations'][rotated_field].create_dataset('ref_coord', data=ref_coord)

    f_read_write.close()