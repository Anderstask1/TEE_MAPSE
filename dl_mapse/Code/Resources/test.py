from matplotlib import pyplot as plt
from matplotlib import image as mpimg
import numpy as np
import h5py
"""
class EventHandler:
    def __init__(self):
        fig.canvas.mpl_connect('button_press_event', self.onpress)
        fig.canvas.mpl_connect('key_press_event', self.keypress)

        self.coordinates = []

    def onpress(self, event):
        xi, yi = (int(round(n if n else -1)) for n in (event.xdata, event.ydata))
        print (xi,yi)
        if xi<=10 or xi>=img.shape[0]-10 or yi<=10 or yi>=img.shape[1]-10:
            return
        self.coordinates.append(xi)
        self.coordinates.append(yi)
        self.updatePlot()

    def keypress(self, event):
        if event.key == " ":
            print("space")
            print(self.coordinates)
        if event.key == "backspace":
            print("backspace")
            if self.coordinates:
                self.coordinates.pop()
                self.coordinates.pop()

    def updatePlot(self):
        fig.clear()
        plt.imshow(img, cmap='gray')
        length = int(len(self.coordinates)/2)
        for i in range(0,2*length,2):
            plt.scatter(self.coordinates[i], self.coordinates[i+1], color='r', marker='*')
        plt.show()
for i in range(1,10):
    plt.clf()
    img = mpimg.imread('I59D3DRA_{}.png'.format(i))
    im = plt.imshow(img, cmap='gray')

    fig = plt.gcf()
    fig.set_size_inches(10,10)

    lol = plt.ginput(n=3, timeout=0, show_clicks=True)
    #plt.scatter(lol[0][0], lol[0][1], color='r', marker='*')
    #plt.scatter(lol[1][0], lol[1][1], color='r', marker='*')
    #plt.waitforbuttonpress()

    print(lol)
"""
f = h5py.File('../../Data/RefData/p05_4c1.h5','r')

imgs = np.array(f['images'])
points = np.array(f['reference'])
print(points.shape)
plt.ion()
for i in range(imgs.shape[0]):
    plt.imshow(imgs[i,:,:], cmap='gray')
    plt.scatter(points[i,:][0],points[i,:][1])
    plt.scatter(points[i,:][2],points[i,:][3])
    plt.pause(0.01)
    plt.clf()
    print(i)

print(list(f.keys()))
