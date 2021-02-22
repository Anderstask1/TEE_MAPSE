import h5py
import matplotlib.pyplot as plt
import numpy as np
import os

from itertools import cycle

#or hard coded
root_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotated_landmarks_3d_mv-center_rotated_data/Annotating"

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

    # iterate through all rotations
    for counter, rotated_field in enumerate(f_read_write['MVCenterRotatedVolumes']):

        tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])

        ref_coord = np.empty(shape=(0,4))
        imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[2]))
        print(rotated_field)
        print('File: ', counter, '/', len(f_read_write['MVCenterRotatedVolumes']))

        coordinates = np.array(f_read_write['Annotations'][rotated_field]['ref_coord'])

        for i in range(tissue.shape[0]):
            plt.imshow(np.transpose(tissue[i,:,:]), cmap='gray')
            plt.scatter(coordinates[i][0], coordinates[i][1], color='b', marker='*', alpha=0.9)
            plt.scatter(coordinates[i][2], coordinates[i][3], color='r', marker='*', alpha=0.9)
            plt.pause(0.1)
            plt.clf()

        print("Press mouse for next image. Press key to exit.\n")
        user_input = plt.waitforbuttonpress(timeout=10000)

        if user_input:
            user_key = input("Enter s to skip, or c if you wish to exit\n")
            if user_key == "s":
                continue
            if user_key == "c":
                break

        for i in cycle(range(tissue.shape[0])):
            print(i, '/', tissue.shape[0])

            plt.imshow(np.transpose(tissue[i,:,:]), cmap='gray')

            plt.scatter(coordinates[i][0], coordinates[i][1], color='b', marker='*', alpha=0.9)
            plt.scatter(coordinates[i][2], coordinates[i][3], color='r', marker='*', alpha=0.9)

            plt.pause(0.01)


            print("Press mouse for next image. Press key to mark image as noise, or to skip frames.\n")
            user_input = plt.waitforbuttonpress(timeout=10000)

            if user_input:
                user_key = input(
                    "Enter n to mark frame as noise.\n"\
                    "Enter l to re-annotate landmarks on frame.\n"\
                    "Enter s if you wish to skip frames\n")
                if user_key == "n":
                    print('Frame ', i, ' marked as noise.')
                    coordinates[i][:] = [-1, -1, -1, -1]
                elif user_key == "l":
                    print("Please annotate image with landmarks. First click = top landmark. \n")
                    user_landmarks = plt.ginput(n=2, timeout=0, show_clicks=True)
                    coordinates[i] = [user_landmarks[0][0], user_landmarks[0][1], user_landmarks[1][0], user_landmarks[1][1]]
                elif user_key == "s":
                    plt.clf()
                    break

            plt.clf()

        # get the hdf keys
        h5_keys = f_read_write['Annotations'].keys()

        # get the hdf keys
        h5_keys = f_read_write['Annotations'][rotated_field].keys()

        if 'ref_coord' in h5_keys:

            del f_read_write['Annotations'][rotated_field]['ref_coord']
        f_read_write['Annotations'][rotated_field].create_dataset('ref_coord', data=coordinates)

    f_read_write.close()