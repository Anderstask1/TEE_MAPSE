import numpy as np
import torch
import scipy.ndimage as nd
from scipy import signal, interpolate

import matplotlib.pyplot as plt

#plt.ion()


class PostProcessor(object):

    def __init__(self, coordinateExtract=None, rotate=None, peakDetect=None, threshold=None):

        if not coordinateExtract:
            if not threshold:
                self.coordinateExtract = CoordinateExtractor()
            else:
                self.coordinateExtract = CoordinateExtractor(None, threshold)
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

    def __call__(self, predicted_pmap, left, scale_correction):

        coordinates = self.coordinateExtract(predicted_pmap)
        coordinates = coordinates * scale_correction

        #coordinates = reference
        #coordinates[np.where(coordinates==1.)] = np.nan
        #coordinates = np.reshape(coordinates, (reference.shape[0],2,2))

        coordinates_mean = np.reshape(coordinates, (2*coordinates.shape[0], 2))
        coordinates_mean[:, 0] += left
        ret_cor = coordinates_mean
        ret_cor = np.reshape(ret_cor, (coordinates.shape[0], 4))
        #reference = np.reshape(reference, (2*reference.shape[0], 2))

        """
            tp = np.zeros((2))
            tn = np.zeros((2))
            fp = np.zeros((2))
            fn = np.zeros((2))

            for i in range(coordinates_mean.shape[0]):
                if np.isnan(coordinates_mean[i,:]).any() and (reference[i,:]==1.).any():
                    tp[i%2] += 1
                elif np.isnan(coordinates_mean[i,:]).any() and not (reference[i,:]==1.).any():
                    fp[i%2] += 1
                elif not np.isnan(coordinates_mean[i,:]).any() and (reference[i,:]==1.).any():
                    fn[i%2] += 1
                else:
                    tn[i%2] += 1
            """
        #coordinates_mean = np.delete(
        #    coordinates_mean, np.where(reference == 1.)[0], 0)
        #reference = np.delete(reference, np.where(reference == 1.)[0], 0)
        #reference = np.delete(reference, np.where(
        #    np.isnan(coordinates_mean))[0], 0)
        #coordinates_mean = np.delete(
        #    coordinates_mean, np.where(np.isnan(coordinates_mean))[0], 0)

        #ref_scat = reference[:, 1]/2
        #pred_scat = coordinates_mean[:, 1]/2
        #x_dist = np.mean(np.abs(coordinates_mean[:, 0]-reference[:, 0]))
        #y_dist = np.mean(np.abs(coordinates_mean[:, 1]-reference[:, 1]))
        #mean_dist = np.mean(
        #    np.sqrt(np.sum(np.power((coordinates_mean-reference), 2), axis=1)))
        #print(mean_dist, x_dist, y_dist)

        coordinates = self.rotate(coordinates)

        #plt.clf()
        #plt.plot(coordinates[:,1,1], 'r', linewidth=1, label='Estimate')
        #plt.xlabel('Frame in sequence')
        #plt.ylabel('Y-coordinate location [mm]')
        #plt.grid(b=True)

        left_movement, right_movement = self.extractHorisontalMovement(coordinates)

        # left_es, left_ed, lp_l = self.peakDetect(left_movement)
        # right_es, right_ed, lp_r = self.peakDetect(right_movement)

        # plt.plot(lp_r, 'g', linewidth=1, label='Low-pass filtered')
        # #plt.scatter(right_movement['t'][right_es], right_movement['y']
        # #            [right_es], c='b', marker='*', label='Peak')
        # #plt.scatter(right_movement['t'][right_ed],
        # #            right_movement['y'][right_ed], c='b', marker='*')
        # #plt.legend()

        # plt.show()

        # plt.clf()
        # plt.subplot(2, 1, 1)
        # plt.plot(left_movement['t'], left_movement['y'],
        #          'r', linewidth=1, label='Estimate')
        # #plt.scatter(left_movement['t'][left_es], left_movement['y']
        # #            [left_es], c='b', marker='*', label='Peak')
        # #plt.scatter(left_movement['t'][left_ed],
        # #            left_movement['y'][left_ed], c='b', marker='*')

        # plt.title('Movement of left and right landmark')
        # plt.xlabel('Frame in sequence')
        # plt.ylabel('Y-coordinate location [mm]')
        # plt.grid(b=True)
        # plt.legend()

        # plt.subplot(2, 1, 2)
        # plt.plot(right_movement['t'], right_movement['y'],
        #          'r', linewidth=1, label='Estimate')
        # #plt.scatter(right_movement['t'][right_es], right_movement['y'][right_es], c='b', marker='*', label='Peak')
        # #plt.scatter(right_movement['t'][right_ed], right_movement['y'][right_ed], c='b', marker='*')
        # plt.xlabel('Frame in sequence')
        # plt.ylabel('Y-coordinate location [mm]')
        # plt.grid(b=True)
        # plt.legend()

        # plt.show()

        #left_mapse = self.mapseCalc(
        #    left_movement['y'][left_es], left_movement['y'][left_ed], pixelsize)
        #right_mapse = self.mapseCalc(
        #    right_movement['y'][right_es], right_movement['y'][right_ed], pixelsize)

        #mapse = {'left':round(right_mapse,2)}#, 'right':round(right_mapse,2)}
        #print(mapse)

        """
        if left_movement['nan'][left_movement['t'][left_es] + 1].any() or left_movement['nan'][left_movement['t'][left_es] - 1].any():
            print("Left es not good")
        if left_movement['nan'][left_movement['t'][left_ed] + 1].any() or left_movement['nan'][left_movement['t'][left_ed] - 1].any():
            print("Left ed not good")
        if right_movement['nan'][right_movement['t'][right_es] + 1].any() or right_movement['nan'][right_movement['t'][right_es] - 1].any():
            print("Right es not good")
        if right_movement['nan'][right_movement['t'][right_ed] + 1].any() or right_movement['nan'][right_movement['t'][right_ed] - 1].any():
            print("Right ed not good")
        """

        #print("Number of frames left not detected: ", np.sum(left_movement['nan'])/left_movement['nan'].shape[0])
        #print("Number of frames right not detected: ", np.sum(right_movement['nan'])/right_movement['nan'].shape[0])

        #measurement_info = {left_movement, right_movement}
        #measurement_info = {'euclidean':mean_dist, 'x':x_dist, 'y':y_dist}
        #                    'pred':pred_scat, 'ref':ref_scat,
        #                    'tp': tp, 'fp':fp, 'tn':tn, 'fn':fn}

        #print(mapse)

        return ret_cor, left_movement, right_movement

    def extractHorisontalMovement(self, coordinates):

        left_movement = {'y': np.array([]), 'y_complete': np.array([]), 't': np.array(
            [], dtype=int), 'nan': np.array([], dtype=int)}
        right_movement = {'y': np.array([]), 'y_complete': np.array([]), 't': np.array(
            [], dtype=int), 'nan': np.array([], dtype=int)}

        for i, point in enumerate([left_movement, right_movement]):
            for j, value in enumerate(coordinates[:, i, 1]):
                if np.isnan(value):
                    point['nan'] = np.append(point['nan'], 1)
                    point['y_complete'] = np.append(point['y_complete'], np.nan)
                else:
                    point['y'] = np.append(point['y'], value)
                    point['y_complete'] = np.append(point['y_complete'], value)
                    point['t'] = np.append(point['t'], j)
                    point['nan'] = np.append(point['nan'], 0)

        return left_movement, right_movement

    def mapseCalc(self, es, ed, pixelsize):
        if es.size == 0 or ed.size == 0:
            mapse = np.nan
        else:
            mapse = np.abs(np.mean(es) - np.mean(ed))*pixelsize

        return mapse


class CoordinateExtractor(object):

    def __init__(self, method="centroid", threshold=None):
        self.method = method
        print('Post-processor threshold is: ', threshold)
        if not threshold:
            self.threshold = 0.5
        else:
            self.threshold = threshold

    def __call__(self, predicted_pmap):
        coordinates = np.empty((predicted_pmap.shape[0], 2, 2))
        if self.method == "argmax":
            for i in range(predicted_pmap.shape[0]):
                if torch.max(predicted_pmap[i, 0, :, :]) < 0.5:
                    left_point = (np.nan, np.nan)
                else:
                    left_argmax_idx = torch.argmax(predicted_pmap[i, 0, :, :])
                    left_point = (left_argmax_idx / predicted_pmap.shape[-2],
                                  left_argmax_idx % predicted_pmap.shape[-1])

                if torch.max(predicted_pmap[i, 1, :, :]) < 0.5:
                    right_point = (np.nan, np.nan)
                else:
                    right_argmax_idx = torch.argmax(predicted_pmap[i, 1, :, :])
                    right_point = (right_argmax_idx / predicted_pmap.shape[-2],
                                   right_argmax_idx % predicted_pmap.shape[-1])

                coordinates[i, 0, 0] = left_point[1]
                coordinates[i, 0, 1] = left_point[0]
                coordinates[i, 1, 0] = right_point[1]
                coordinates[i, 1, 1] = right_point[0]

        else:
            predicted_pmap = predicted_pmap.ge(self.threshold).numpy()
            for i in range(predicted_pmap.shape[0]):
                left_point = nd.center_of_mass(predicted_pmap[i, 0, :, :]) if (
                    predicted_pmap[i, 0, :, :] > 0.).any() else (np.nan, np.nan)
                right_point = nd.center_of_mass(predicted_pmap[i, 1, :, :]) if (
                    predicted_pmap[i, 1, :, :] > 0.).any() else (np.nan, np.nan)

                coordinates[i, 0, 0] = left_point[1]
                coordinates[i, 0, 1] = left_point[0]
                coordinates[i, 1, 0] = right_point[1]
                coordinates[i, 1, 1] = right_point[0]

        return coordinates


class Rotation(object):
    def __inti__(self):
        print()

    def __call__(self, coordinates):
        rotated_coordinates = np.empty(coordinates.shape)

        for i in range(coordinates.shape[1]):
            x = coordinates[:, i, 0]
            y = coordinates[:, i, 1]

            if np.isnan(y).all():
                #raise Exception('NAN in before rotation')
                rotated_coordinates = coordinates
            else:
                x_nnan = x[~np.isnan(x)]
                y_nnan = y[~np.isnan(y)]

                origin_idx = np.argsort(y_nnan)[:4]
                origin = np.array([np.nanmean(x_nnan[origin_idx]),
                                np.nanmean(y_nnan[origin_idx])])

                ind = np.argsort(y_nnan)[-4:]

                mean = np.array([np.nanmean(x_nnan[ind]), np.nanmean(y_nnan[ind])])
                mean_vector = np.array([(mean[0]-origin[0]),
                                        np.abs(origin[1]-mean[1])])
                correction_vector = np.array([0., np.abs(origin[1]-mean[1])])

                if np.sum(mean_vector)+np.sum(correction_vector) > 0.:
                    angle = np.arccos(np.dot(mean_vector, correction_vector)/np.dot(np.linalg.norm(mean_vector),
                                                                                    np.linalg.norm(correction_vector)))
                    if mean_vector[0] < 0.:
                        angle = -angle
                else:
                    angle = np.nan

                cos, sin = np.cos(angle), np.sin(angle)

                R = np.array([[cos, -sin], [sin, cos]])

                for j in range(x.shape[0]):
                    rotated_point = np.dot(R, np.array([x[j], y[j]]))
                    rotated_coordinates[j, i, 0] = rotated_point[0]
                    rotated_coordinates[j, i, 1] = rotated_point[1]

        return rotated_coordinates


class PeakDetection(object):

    def __init__(self, border_coeff=0.2, peak_distance=8):
        self.peak_distance = peak_distance
        self.border_coeff = border_coeff

    def __call__(self, point):
        if point['y'].size > 0:
            border = (np.max(point['y'])-np.min(point['y']))*self.border_coeff
            pad_front = np.ones((self.peak_distance,))*point['y'][0]
            pad_back = np.ones((self.peak_distance,))*point['y'][-1]
            padded = np.concatenate((pad_front, point['y'], pad_back))
            y_lp = np.convolve(padded, np.ones(
                (2*self.peak_distance+1,))/(2*self.peak_distance+1), mode='valid')

            peaks_es, _ = signal.find_peaks(
                -point['y'], distance=self.peak_distance, height=-y_lp+border)
            peaks_ed, _ = signal.find_peaks(
                point['y'], distance=self.peak_distance, height=y_lp+border)
        else:
            y_lp = np.array(())
            peaks_es, peaks_ed = np.array(()), np.array(())
        peaks_es, peaks_ed = self.filterPeaks(peaks_es, peaks_ed)
        return peaks_es, peaks_ed, y_lp

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
