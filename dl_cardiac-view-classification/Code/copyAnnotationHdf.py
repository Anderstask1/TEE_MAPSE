import h5py
import numpy as np
import os
import re

# natural sorting of list
def atoi(text):
    return int(text) if text.isdigit() else text


def natural_keys(text):
    return [atoi(c) for c in re.split(r'(\d+)', text)]

def main():
    root_dir = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentAnnotatingData"
    annotated_dir = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/binary/test"

    # get the .h5 files in the directory
    processFiles = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.lower().endswith('.h5'):
                processFiles.append(file)
        break
    processFiles.sort()
    print(processFiles)

    # iterate through .h5 files in dir
    for i, file in enumerate(processFiles):
        print("File {}/{}".format(i + 1, len(processFiles)))

        file_path = os.path.join(root_dir, file)
        f_dest = h5py.File(file_path, 'r+')

        # get the hdf keys
        h5_keys = f_dest.keys()

        rotated_fields = list(f_dest['MVCenterRotatedVolumes'].keys())
        rotated_fields.sort(key=natural_keys)

        # iterate through all rotations
        for rotated_field in rotated_fields:
            file_name = file.replace('.h5','_') + rotated_field + '.h5'
            file_path = os.path.join(annotated_dir, file_name)
            f_annotated = h5py.File(file_path, 'r')

            class_idx = f_annotated['reference'].value

            h5_keys = f_dest['MVCenterRotatedVolumes'][rotated_field].keys()

            if 'reference' in h5_keys:
                del f_dest['MVCenterRotatedVolumes'][rotated_field]['reference']
            f_dest['MVCenterRotatedVolumes'][rotated_field].create_dataset('reference', data=class_idx)

            f_annotated.close()

        f_dest.close()


main()