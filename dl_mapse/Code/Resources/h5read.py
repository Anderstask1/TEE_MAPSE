import h5py
import matplotlib.pyplot as plt
import numpy as np
import os

plt.ion()

root_dir = "../../Data/"
root_dir_data = "../../../../project-data/project-h5/"
file_name_path = "p3"
file_name = "I599GGOE.h5"
fname_read = os.path.join(root_dir_data, "{}/{}".format(file_name_path,file_name))

f_read = h5py.File(fname_read, 'r')

tissue = np.array(f_read['tissue']['data'])

ref_coord = np.empty(shape=(0,4))
imgs = np.empty(shape=(0,tissue.shape[1],tissue.shape[0]))
print(imgs.shape)

coordinates = [(0,0),(0,0),(0,0)]

for i in range(tissue.shape[2]):
    plt.imshow(np.transpose(tissue[:,:,i]), cmap='gray')
    plt.pause(0.01)
    plt.clf()
    print(i)

for i in range(tissue.shape[2]):
    plt.imshow(np.transpose(tissue[:,:,i]), cmap='gray')
    imgs = np.append(imgs, [np.transpose(tissue[:,:,i])], axis=0)

    fig = plt.gcf()
    fig.set_size_inches(10,10)

    coordinates = plt.ginput(n=3, timeout=0, show_clicks=True)
    plt.clf()
    plt.scatter(coordinates[0][0], coordinates[0][1], color='b', marker='*', alpha=0.2)
    plt.scatter(coordinates[1][0], coordinates[1][1], color='b', marker='*', alpha=0.2)

    ref_coord = np.append(ref_coord, np.array([[coordinates[0][0],
                                                coordinates[0][1],
                                                coordinates[1][0],
                                                coordinates[1][1]]]), axis=0)
    print(ref_coord)

fname_write = os.path.join(root_dir, "RefData/p03_2c2.h5")
f_write = h5py.File(fname_write, 'w')

imgs = f_write.create_dataset("images", data=imgs)
ref_coord = f_write.create_dataset("reference", data=ref_coord)

fpath_write_t = os.path.join(root_dir, "RefData/torjus/{}".format(file_name_path))
if not os.path.exists(fpath_write_t):
    os.mkdir(fpath_write_t)
fname_write_t = os.path.join(root_dir, "RefData/torjus/{}/{}".format(file_name_path,file_name))
f_write_t = h5py.File(fname_write_t, 'w')

imgs = f_write_t.create_dataset("images", data=imgs)
ref_coord = f_write_t.create_dataset("reference", data=ref_coord)
