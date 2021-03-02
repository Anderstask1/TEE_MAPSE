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
    annotated_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated"

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

        file_path = os.path.join(annotated_dir, file)
        f_annotated = h5py.File(file_path, 'r')

        h5_keys = f_dest.keys()

        if 'ClassAnnotations' in h5_keys:
            del f_dest['ClassAnnotations']
        f_dest.create_group('ClassAnnotations')

        h5_keys = f_annotated['ClassAnnotations'].keys()

        for classAnnotation in h5_keys:

            class_idx = f_annotated['ClassAnnotations'][classAnnotation]['reference'].value

            h5_keys = f_dest['ClassAnnotations'].keys()

            if classAnnotation in h5_keys:
                del f_dest['ClassAnnotations'][classAnnotation]
            f_dest['ClassAnnotations'].create_group(classAnnotation)

            h5_keys = f_dest['ClassAnnotations'][classAnnotation].keys()

            if 'reference' in h5_keys:
                del f_dest['ClassAnnotations'][classAnnotation]['reference']
            f_dest['ClassAnnotations'][classAnnotation].create_dataset('reference', data=class_idx)

        f_dest.close()


main()