import numpy as np
import torch
import scipy.ndimage as nd
from scipy import signal, interpolate

class PostProcessor(object):

    def __init__(self,coordinateExtract=None, rotate=None, peakDetect=None):

        if not coordinateExtract:
            self.coordinateExtract = CoordinateExtractor()
        else:
            self.coordinateExtract = coordinateExtract
        if not rotate:
            self.rotate = Rotation()
        else:
            self.rotate = rotate
        if not peakDetect:
            self.peakDetect = PeakDetection()
        else:
            self.peakDetect = peakDetect

    def __call__(self, predicted_pmap, pixelsize, scale_correction):

        coordinates = self.coordinateExtract(predicted_pmap)
        coordinates = self.rotate(coordinates)

        coordinates = coordinates * scale_correction

        left_movement, right_movement = self.extractHorisontalMovement(coordinates)

        left_es, left_ed = self.peakDetect(left_movement)
        right_es, right_ed = self.peakDetect(right_movement)

        left_mapse = self.mapseCalc(left_es, left_ed, pixelsize)
        right_mapse = self.mapseCalc(right_es, right_ed, pixelsize)

        print(left_mapse)
        print(right_mapse)


    def extractHorisontalMovement(self, coordinates):

        left_movement = {'y': np.array([]), 't': np.array([], dtype=int), 'nan': np.array([], dtype=int)}
        right_movement = {'y': np.array([]), 't': np.array([], dtype=int), 'nan': np.array([], dtype=int)}

        for i, point in enumerate([left_movement, right_movement]):
            for j, value in enumerate(coordinates[:,i,1]):
                if np.isnan(value):
                    point['nan'] = np.append(point['nan'],1)
                else:
                    point['y'] = np.append(point['y'],value)
                    point['t'] = np.append(point['t'],j)
                    point['nan'] = np.append(point['nan'],0)

        return left_movement, right_movement


    def mapseCalc(self, es, ed):

        if es.size==0 or ed.size==0:
            mapse = np.nan
        else:
            mapse = np.abs(np.mean(es) - np.mean(ed))*self.pixelsize

        return mapse

class CoordinateExtractor(object):

    def __init__(self, method="centroid", threshold=0.5):
        self.method = method
        self.threshold = threshold

    def __call__(self, predicted_pmap):
        coordinates = np.empty((predicted_pmap.shape[0],2,2))
        if self.method == "argmax":
            for i in range(predicted_pmap.shape[0]):
                left_argmax_idx = torch.argmax(predicted_pmap[i,0,:,:])
                right_argmax_idx = torch.argmax(predicted_pmap[i,1,:,:])
                left_point = (left_argmax_idx / predicted_pmap.shape[-2],
                              left_argmax_idx % predicted_pmap.shape[-1])
                right_point = (right_argmax_idx / predicted_pmap.shape[-2],
                               right_argmax_idx % predicted_pmap.shape[-1])

                coordinates[i,0,0] = left_point[1]
                coordinates[i,0,1] = left_point[0]
                coordinates[i,1,0] = right_point[1]
                coordinates[i,1,1] = right_point[0]

        else:
            predicted_pmap = predicted_pmap.ge(self.threshold).numpy()
            for i in range(predicted_pmap.shape[0]):
                left_point = nd.center_of_mass(predicted_pmap[i,0,:,:])
                right_point = nd.center_of_mass(predicted_pmap[i,1,:,:])

                coordinates[i,0,0] = left_point[1]
                coordinates[i,0,1] = left_point[0]
                coordinates[i,1,0] = right_point[1]
                coordinates[i,1,1] = right_point[0]

        return coordinates

class Rotation(object):
    def __inti__(self):
        print()

    def __call__(self, coordinates):

        rotated_coordinates = np.empty(coordinates.shape)

        print(coordinates.shape)

        for i in range(coordinates.shape[1]):
            x = coordinates[:,i,0]
            y = coordinates[:,i,1]

            origin_idx = np.nanargmin(y)
            origin = np.array([x[origin_idx], y[origin_idx]])

            mean = np.array([np.nanmean(x), np.nanmean(y)])
            mean_vector = np.array([np.abs(origin[0]-mean[0]),
                                    np.abs(origin[1]-mean[1])])
            correction_vector = np.array([0., np.abs(origin[1]-mean[1])])

            angle = np.arccos((np.dot(mean_vector/np.linalg.norm(mean_vector),
                                      correction_vector/np.linalg.norm(correction_vector))))

            cos, sin = np.cos(angle), np.sin(angle)

            R = np.array([[cos, -sin],[sin, cos]])

            for j in range(x.shape[0]):
                rotated_point = np.dot(R, np.array([x[j], y[j]]))
                rotated_coordinates[j,i,0] = rotated_point[0]
                rotated_coordinates[j,i,1] = rotated_point[1]

        return rotated_coordinates

class PeakDetection(object):

    def __init__(self, border_coeff=0.15, peak_distance=8):
        self.peak_distance = peak_distance
        self.border_coeff = border_coeff

    def __call__(self, point):
        #b, a = signal.butter(3, 0.05)
        #y_lp = signal.filtfilt(b, a, point['y'])
        border = (np.max(point['y'])-np.min(point['y']))*self.border_coeff
        y_lp = np.convolve(point['y'], np.ones((self.peak_distance,))/self.peak_distance, mode='same')

        peaks_es, _ = signal.find_peaks(-point['y'], distance=self.peak_distance)#, height=-y_lp+border)
        peaks_ed, _ = signal.find_peaks(point['y'], distance=self.peak_distance)#, height=y_lp+border)

        print(peaks_es)
        print(peaks_ed)

        return self.filterPeaks(peaks_es, peaks_ed)

    def filterPeaks(self, peaks_es, peaks_ed):
        peaks_es, peaks_ed, temp_es, temp_ed = peaks_es.tolist(), peaks_ed.tolist(), [], []

        while peaks_es and peaks_ed:
            if peaks_ed[0] > peaks_es[0]:
                if len(peaks_es) == 1:
                    if peaks_ed[0] > peaks_es[0]:
                        temp_es.append(peaks_es[0])
                        temp_ed.append(peaks_ed[0])
                        peaks_es.pop(0)
                        peaks_ed.pop(0)
                        continue
                if peaks_ed[0] < peaks_es[1]:
                    temp_es.append(peaks_es[0])
                    temp_ed.append(peaks_ed[0])
                    peaks_es.pop(0)
                    peaks_ed.pop(0)
                else:
                    peaks_es.pop(0)
            else:
                peaks_ed.pop(0)

        return np.asarray(temp_es), np.asarray(temp_ed)
