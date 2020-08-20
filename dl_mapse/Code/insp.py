import torch
import numpy as np
import matplotlib.pyplot as plt


s1 = torch.load("Project/Weights/training_info_sig3.pth", map_location='cpu')['val_info']
#s2 = torch.load("Project/Weights/training_info_3len.pth", map_location='cpu')['val_info']
s2 = torch.load("Project/Weights/training_info_3len0.pth", map_location='cpu')['val_info']
#s1 = torch.load("Project/Weights/training_info_sig1.pth", map_location='cpu')['val_info']
#s2 = torch.load("Project/Weights/training_info_sig2.pth", map_location='cpu')['val_info']
s3 = torch.load("Project/Weights/training_info_5len.pth", map_location='cpu')['val_info']
s4 = torch.load("Project/Weights/training_info_7len.pth", map_location='cpu')['val_info']
#s5 = torch.load("Project/Weights/training_info_sig5.pth", map_location='cpu')['val_info']

plt.subplot(2,1,1)
plt.plot(s1['detect_acc'][:], 'r')
plt.plot(s2['detect_acc'][:], 'b')
plt.plot(s3['detect_acc'][:], 'g')
plt.plot(s4['detect_acc'][:], 'y')
#plt.plot(s5['detect_acc'][:], 'c')
plt.grid(b=True, which='both')
plt.subplot(2,1,2)
plt.plot(s1['true_acc'][:], 'r')
plt.plot(s2['true_acc'][:], 'b')
plt.plot(s3['true_acc'][:], 'g')
plt.plot(s4['true_acc'][:], 'y')
#plt.plot(s5['true_acc'][:], 'c')
plt.grid(b=True, which='both')
plt.show()

print(min(s1['detect_acc']))
print(min(s2['detect_acc']))
print(min(s3['detect_acc']))
print(min(s4['detect_acc']))
#print(min(s5['detect_acc']))
print()
print(min(s1['true_acc'][4:]))
print(min(s2['true_acc'][4:]))
print(min(s3['true_acc'][7:]))
print(min(s4['true_acc'][7:]))
#print(min(s5['true_acc'][2:]))
