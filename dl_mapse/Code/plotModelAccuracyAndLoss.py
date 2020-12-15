import torch
import matplotlib.pyplot as plt

#Data_old
#Data_new
#Data_mix1
infoPathOld = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data_old/training_info.pth"
infoPathNew = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data_new/training_info.pth"
infoPathMix1 = "/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data_mix1/training_info.pth"

infoOld = torch.load(infoPathOld)
infoNew = torch.load(infoPathNew)
infoMix1 = torch.load(infoPathMix1)

plt.plot(infoOld["train_info"]["true_acc"], label='Dataset Configuration 1')
plt.plot(infoNew["train_info"]["true_acc"], label='Dataset Configuration 2')
plt.plot(infoMix1["train_info"]["true_acc"], label='Dataset Configuration 3')

plt.xlabel('Epoch Number')
plt.ylabel('Mean Error')
plt.legend(loc="upper right")
plt.title('Training Error')

plt.show()

plt.plot(infoOld["val_info"]["true_acc"], label='Dataset Configuration 1')
plt.plot(infoNew["val_info"]["true_acc"], label='Dataset Configuration 2')
plt.plot(infoMix1["val_info"]["true_acc"], label='Dataset Configuration 3')

plt.xlabel('Epoch Number')
plt.ylabel('Mean Error')
plt.legend(loc="upper right")
plt.title('Validation Error')

#plt.yscale('log')

plt.show()

plt.plot(infoOld["train_info"]["loss"], label='Dataset Configuration 1')
plt.plot(infoNew["train_info"]["loss"], label='Dataset Configuration 2')
plt.plot(infoMix1["train_info"]["loss"], label='Dataset Configuration 3')

plt.xlabel('Epoch Number')
plt.ylabel('Loss')
plt.legend(loc="upper right")
plt.title('Training Loss')

plt.show()

plt.plot(infoOld["val_info"]["loss"], label='Dataset Configuration 1')
plt.plot(infoNew["val_info"]["loss"], label='Dataset Configuration 2')
plt.plot(infoMix1["val_info"]["loss"], label='Dataset Configuration 3')

plt.xlabel('Epoch Number')
plt.ylabel('Loss')
plt.legend(loc="upper right")
plt.title('Validation Loss')

plt.show()