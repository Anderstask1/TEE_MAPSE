import h5py
import matplotlib.pyplot as plt
import numpy as np
import os
from PIL import Image
import re

# natural sorting of list
def atoi(text):
    return int(text) if text.isdigit() else text

def natural_keys(text):
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

def main():

    root_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated"

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

        f_read_write = h5py.File(file_path, 'r')

        rotated_fields = list(f_read_write['ClassAnnotations'].keys())
        rotated_fields.sort(key=natural_keys)

        # iterate through all rotations
        for rotated_field in rotated_fields:
            tissue = np.array(f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'])
            class_idx = np.array(f_read_write['ClassAnnotations'][rotated_field]['reference'])
            class_idx = int(class_idx)

            imgs = np.transpose(tissue[0,:,:])

            im = Image.fromarray(imgs.astype(np.uint8))

            class_name = 'unknown'

            if class_idx == 1:
                class_name = '4C'
            elif class_idx == 2:
                class_name = '2C'
            elif class_idx == 3:
                class_name = 'LAX'

            im.save(root_dir + '/Images/' + file.replace('.h5', '') + '_' + class_name +'_image.jpeg')

        f_read_write.close()
main()


