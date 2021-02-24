import torch
import torch.nn as nn
import torch.optim as optim
import train
import dataset
import sys

from Models import models
from torch.utils.data import DataLoader
from torchvision import transforms

batch_size = 32
num_epochs = 25

run_loc = 'running_locally'
model_type = 'CNN'
label_encoding = 'binary'

if len(sys.argv) > 1:
    run_loc = str(sys.argv[1])

if len(sys.argv) > 2:
    model_type = str(sys.argv[2])

if len(sys.argv) > 3:
    label_encoding = str(sys.argv[3])

print()
print(" + Batch size:\t\t\t{}".format(batch_size))
print(" + Number of epochs:\t\t{}".format(num_epochs))
print(run_loc + "\n")
print(model_type + "\n")
print(label_encoding + "\n")
print()

if run_loc == "running_locally":
    print("Running the code locally")
    training_info_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_local_training/training_info.pth"
    weights_path = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_local_training/best_weights.pth"

    if label_encoding == 'binary':
        #dataset_train_path = "/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/train"
        #dataset_val_path = "/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/val"
        dataset_train_path = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/binary/train"
        dataset_val_path = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/binary/val"

    elif label_encoding == 'gaussian':
        ataset_train_path = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/gaussian/train"
        dataset_val_path = "/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/gaussian/val"

elif run_loc == "running_ssh":
    print("Running the code remotely with ssh")
    training_info_path = "/home/atasken/Documents/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_local_training/training_info.pth"
    weights_path = "/home/atasken/Documents/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_local_training/best_weights.pth"

    if label_encoding == 'binary':
        # dataset_train_path = "/home/atasken/Documents/Thesis/Trym_data_annotated/train"
        # dataset_val_path = "/home/atasken/Documents/Thesis/Trym_data_annotated/val"
        dataset_train_path = "/home/atasken/Documents/Thesis/3d_data_annotated/binary/train"
        dataset_val_path = "/home/atasken/Documents/Thesis/3d_data_annotated/binary/val"
    elif label_encoding == 'gaussian':
        dataset_train_path = "/home/atasken/Documents/Thesis/3d_data_annotated/gaussian/train"
        dataset_val_path = "/home/atasken/Documents/Thesis/3d_data_annotated/gaussian/val"
else:
    print("Running the code remote")
    training_info_path = "/output/training_info.pth"
    weights_path = "/output/best_weights.pth"

    dataset_train_path = "/train/"
    dataset_val_path = "/val/"

print("Dataset training path: ", dataset_train_path)
print("Dataset validation path: ", dataset_val_path)

data_transforms = {
    'train':transforms.Compose([dataset.Rescale((280, 280)),
                        dataset.RandomRotation(10),
                        dataset.RandomCrop(256),
                        dataset.ToTensor()]),
    'val':transforms.Compose([dataset.Rescale(280),
                        dataset.Crop(256),
                        dataset.ToTensor()])}

datasets = {
    'train':dataset.UltrasoundData(dataset_train_path, transform=data_transforms['train']),
    'val':dataset.UltrasoundData(dataset_val_path, transform=data_transforms['val'])}

dataloaders = {
    'train':DataLoader(datasets['train'], batch_size=batch_size, shuffle=True, num_workers=4),
    'val':DataLoader(datasets['val'], batch_size=1, shuffle=False, num_workers=4)}

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

if torch.cuda.is_available():
    print("Using cuda for gpu-accelerated computations")
else:
    print("Using cpu for computations")

if model_type == "CNN":
    model = models.CNN()
    print("Model architecture: CNN")
elif model_type == "VGG16":
    model = models.VGG16()
    print("Model architecture: VGG16")
elif model_type == "ResNext":
    model = models.ResNext()
    print("Model architecture: ResNext")
else:
    print("User input don't match a model name. Please input another network architecture name.")
    sys.exit()

model = model.to(device)

optimizer = optim.Adam(model.parameters())

loss = nn.L1Loss()

print("Train model...")

train.train_model(model, device, dataloaders, loss, optimizer, training_info_path, weights_path, label_encoding, num_epochs)