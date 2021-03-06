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
    root_dir = "/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated"
    out_dir = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/"

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

        print(file)

        f_read_write = h5py.File(file_path, 'r')

        # get the hdf keys
        h5_keys = f_read_write.keys()

        # check if class annotated
        if 'ClassAnnotations' in h5_keys:

            # # create group in hdf5 file for annotations
            # if 'Annotations' in h5_keys:
            #     del f_read_write['Annotations']
            # f_read_write.create_group('Annotations')

            rotated_fields = list(f_read_write['MVCenterRotatedVolumes'].keys())
            rotated_fields.sort(key=natural_keys)

            rotation_4C, rotation_2C, rotation_ALAX = -1, -1, -1

            # iterate through all annotations
            for annotated_field in f_read_write['ClassAnnotations']:
                field_value = f_read_write['ClassAnnotations'][annotated_field]['reference'].value
                if field_value:
                    class_idx = int(field_value)  # get field value
                    rotation_angle = int(annotated_field.split('_')[2])  # parse field name
                    if class_idx == 1:
                        rotation_4C = rotation_angle
                    elif class_idx == 2:
                        rotation_2C = rotation_angle
                    elif class_idx == 3:
                        rotation_ALAX = rotation_angle
                    else:
                        print('Error reading annotation.')

            # set gaussian annotation weighting for images based on dist from 2c, 4c and alax
            # iterate through all rotations
            for rotated_field in rotated_fields:
                # parse rotation angle
                rotation_angle = int(rotated_field.split('_')[2])

                # find angular distance to closest annotated view
                frac_dist_4C = (rotation_angle - rotation_4C + 90) % 180 - 90
                frac_dist_2C = (rotation_angle - rotation_2C + 90) % 180 - 90
                frac_dist_ALAX = (rotation_angle - rotation_ALAX + 90) % 180 - 90
                peak_dist = min(frac_dist_4C, frac_dist_2C, frac_dist_ALAX, key=abs)

                # set annotation weight by gaussian dist
                annotation_weight = 0
                if abs(peak_dist) <= 10:
                    if frac_dist_4C == peak_dist:
                        annotation_weight = 1
                    elif frac_dist_2C == peak_dist:
                        annotation_weight = 2
                    elif frac_dist_ALAX == peak_dist:
                        annotation_weight = 3

                # save annotation in new file
                images = f_read_write['MVCenterRotatedVolumes'][rotated_field]['images'].value
                references = np.full((images.shape[0]), annotation_weight)

                # creating a file
                with h5py.File(out_dir + file.replace('.h5','_') + rotated_field + '.h5', 'w') as f:
                    f.create_dataset("images", data=images)
                    f.create_dataset('reference', data=references)
                    f.close()



main()