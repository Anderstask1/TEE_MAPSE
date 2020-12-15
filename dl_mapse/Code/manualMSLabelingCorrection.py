import h5py
import matplotlib.pyplot as plt
import numpy as np
import os

# path to file
root_dir = "/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotateProcessingFiles/AnnotatedCorrectionFiles"

#get the .h5 files in the directory
processFiles = []
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.lower().endswith('.h5'):
                processFiles.append(file)
    break
processFiles.sort()

plt.ion()

#iterate through .h5 files in dir
for i, file in enumerate(processFiles):
    print("File {}/{}".format(i+1, len(processFiles)))
    file_path = os.path.join(root_dir, file)

    f_read_write = h5py.File(file_path, 'r+')

    # get the hdf keys
    h5_keys = f_read_write.keys()

    tissue = np.array(f_read_write['images'])

    ref_coord = np.empty(shape=(0,4))

    coordinates = [(0, 0), (0, 0)]

    for i in range(tissue.shape[0]):
        plt.imshow(np.transpose(tissue[i, :, :]), cmap='gray')
        plt.pause(0.01)
        plt.clf()

    for i in range(tissue.shape[0]):
        plt.imshow(np.transpose(tissue[i, :, :]), cmap='gray')

        fig = plt.gcf()
        fig.set_size_inches(10, 10)

        coordinates = plt.ginput(n=2, timeout=0, show_clicks=True)
        plt.clf()
        plt.scatter(coordinates[0][0], coordinates[0][1], color='b', marker='*', alpha=0.2)
        plt.scatter(coordinates[1][0], coordinates[1][1], color='b', marker='*', alpha=0.2)

        ref_coord = np.append(ref_coord, np.array([[coordinates[0][0],
                                                    coordinates[0][1],
                                                    coordinates[1][0],
                                                    coordinates[1][1]]]), axis=0)

    if 'reference' in h5_keys:
        del f_read_write['reference']
    f_read_write.create_dataset('reference', data=ref_coord)

    f_read_write.close()
