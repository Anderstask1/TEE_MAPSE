import os
import numpy as np
import h5py

file_dir = "../../../master-project/Project/Data/final-data/train"

files = []
for root, dirs, file in os.walk(file_dir):
    files.extend(file)
    break

tot = 0
fc_tot = 0
tc_tot = 0
fc_noise = 0
tc_noise = 0
anterior = 0
inferior = 0
lateral = 0
septal = 0

print(len(files))

for file in files:
    raw_file = h5py.File(os.path.join(file_dir, file), 'r')

    ref = np.array(raw_file['reference'])

    tot += ref.shape[0]

    if file[-5:-3] == "4c":
        fc_tot += ref.shape[0]
        fc_noise += len(np.where(ref==1.)[0])/2
        lateral += len(np.where(ref[:,0:2]==1.)[0])/2
        septal += len(np.where(ref[:,2:4]==1.)[0])/2
    else:
        tc_tot += ref.shape[0]
        tc_noise += len(np.where(ref==1.)[0])/2
        anterior += len(np.where(ref[:,0:2]==1.)[0])/2
        inferior += len(np.where(ref[:,2:4]==1.)[0])/2

print(tot)
print(fc_tot, tc_tot)
print(fc_noise, tc_noise)
print(lateral, septal)
print(anterior, inferior)


