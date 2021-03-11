import h5py
import numpy as np
import os

def main():
    file_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotating"
    delete_group_name = 'ClassAnnotations'

    # get the .h5 files in the directory
    processFiles = []
    for root, dirs, files in os.walk(file_dir):
        for file in files:
            if file.lower().endswith('.h5'):
                processFiles.append(file)
        break
    processFiles.sort()
    print(processFiles)

    # iterate through .h5 files in dir
    for i, file in enumerate(processFiles):
        print("File {}/{}".format(i + 1, len(processFiles)))

        file_path = os.path.join(file_dir, file)
        f = h5py.File(file_path, 'r+')

        h5_keys = f.keys()

        if delete_group_name in h5_keys:
            del f[delete_group_name]

        f.close()

main()