import torch
import matplotlib.pyplot as plt

#Data_old
#Data_new
#Data_mix1
infoPath = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_CNN/training_info.pth"
#infoPath = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_VGG16/training_info.pth"
#infoPath = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Data_ResNext/training_info.pth"

info = torch.load(infoPath)

plt.plot(info["train_info"]["loss"])

plt.xlabel('Epoch Number')
plt.ylabel('Loss')
plt.legend(loc="upper right")
plt.title('Training Loss')

plt.show()

plt.plot(info["val_info"]["loss"])

plt.xlabel('Epoch Number')
plt.ylabel('Loss')
plt.legend(loc="upper right")
plt.title('Validation Loss')

plt.show()