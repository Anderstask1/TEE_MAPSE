%Postprocess the deep learning results for MAPSE
%Author: gkiss
%Started 01.07.2020

function PostProcessMapseRecording(rootName, xlsfile, saveTrackingMovie, saveTrackingPlot, saveXls)

disp("Processing file: " + rootName)

%window for averaging before computing the velocity estimates
velocitySmoothLength = 5;

%display scale for ECG
ecgScaleFactor = 0.3;

%load dataset
hdfdata = HdfImport([rootName '.h5']);

%if this is isotropic (as is by default) should simplify some computations later
pixelSize = 4.0E-4.* ones(55,1);

imageData = hdfdata.rotated_by_0;
imageTimes = [1:size(imageData,3)];

mapseLandmarks = hdfdata.MAPSE_detected_landmarks';

%convert MAPSE from pixels to mm
mapseLeft = hdfdata.MAPSE_left_movement'.*pixelSize(2);
mapseRight = hdfdata.MAPSE_right_movement'.*pixelSize(2);

%get ECG data
%ecgData = double(hdfdata.ecg.ecg_data);
%ecgTimes = double(hdfdata.ecg.ecg_times);

%compute the peaks in the ECG
%[~, ecgPeakIndex] = pan_tompkin(ecgData, round(1/(ecgTimes(2)-ecgTimes(1))), 0);
ecgPeakTimes = 1; %ecgTimes(ecgPeakIndex);

%process the left and right MAPSE curves
[mapseCycleEstimatesLeft, mapseMinIndicesLeft, mapseMaxIndicesLeft, interpMapseLeft, velocityMapseLeft] = PostProcessOneMapseCurve(mapseLeft, imageTimes, ecgPeakTimes, velocitySmoothLength);
[mapseCycleEstimatesRight, mapseMinIndicesRight, mapseMaxIndicesRight, interpMapseRight, velocityMapseRight] = PostProcessOneMapseCurve(mapseRight, imageTimes, ecgPeakTimes, velocitySmoothLength);

% %plot stuff

%plot the images with landmarks and save as movie
if saveTrackingMovie > 0 
    SaveMapseMovieAsMp4(rootName, imageData, mapseLandmarks);
end
 
%plot the curves
if saveTrackingPlot > 0
    fig = figure('Position', [40, 40, 1000, 1400]);
    clf(fig)

    %colors for the left and right plots so that the NaNs are visible as orange
    mapseNansLeft = isnan(mapseLeft);
    sz = size(mapseNansLeft, 2);
    colorLeft = repmat([0 255 0 1]', [1 sz]);
    idx = find(mapseNansLeft == 1);
    if (~isempty(idx))
        colorLeft(:, idx) =  repmat([255 69 0 1]', [1 size(idx, 2)]);
    end
    mapseNansRight = isnan(mapseRight);
    sz = size(mapseNansRight, 2);
    colorRight = repmat([0 0 255 1]', [1 sz]);
    idx = find(mapseNansRight == 1);
    if (~isempty(idx))
        colorRight(:, idx) =  repmat([255 69 0 1]', [1 size(idx, 2)]);
    end

    %plot left/right movement
    subplot(3,1,1)
    hold on
    pLeft = plot(imageTimes, interpMapseLeft, 'g', 'LineWidth', 2);
    if ~isnan(mapseMinIndicesLeft)
        plot(imageTimes(mapseMinIndicesLeft), interpMapseLeft(mapseMinIndicesLeft), 'or');
    end
    if ~isnan(mapseMaxIndicesLeft)
        plot(imageTimes(mapseMaxIndicesLeft), interpMapseLeft(mapseMaxIndicesLeft), 'xr');
    end
    drawnow
    set(pLeft.Edge, 'ColorBinding','interpolated', 'ColorData', uint8(colorLeft))

    pRight = plot(imageTimes, interpMapseRight, 'b', 'LineWidth', 2);
    if ~isnan(mapseMinIndicesRight)
        plot(imageTimes(mapseMinIndicesRight), interpMapseRight(mapseMinIndicesRight), 'or');
    end
    if ~isnan(mapseMaxIndicesRight)
        plot(imageTimes(mapseMaxIndicesRight), interpMapseRight(mapseMaxIndicesRight), 'xr');
    end
    
    %custom legend explains just the lines
    h = zeros(2, 1);
    h(1) = plot(NaN,NaN,'-g');
    h(2) = plot(NaN,NaN,'-b');
    legend(h, 'left wall', 'right wall');

    drawnow
    set(pRight.Edge, 'ColorBinding','interpolated', 'ColorData', uint8(colorRight))
    title("MAPSE displacement [mm], average MAPSE left = "+  num2str(mean(mapseCycleEstimatesLeft))+ " right = "+ num2str(mean(mapseCycleEstimatesRight)))
    ylim([0 25])

    %plot velocity
    subplot(3,1,2)
    hold on
    pvLeft = plot(imageTimes(2:end), velocityMapseLeft, 'g', 'LineWidth', 2);
    drawnow
    %set(pvLeft.Edge, 'ColorBinding','interpolated', 'ColorData', uint8(colorLeft(:,2:end)))

    pvRight = plot(imageTimes(2:end), velocityMapseRight, 'b', 'LineWidth', 2);
    drawnow
    %set(pvRight.Edge, 'ColorBinding','interpolated', 'ColorData', uint8(colorRight(:,2:end)))

    %custom legend explains just the lines
    h = zeros(2, 1);
    h(1) = plot(NaN,NaN,'-g');
    h(2) = plot(NaN,NaN,'-b');
    legend(h, 'left wall', 'right wall');

    title ("MAPSE velocity [mm/s]")
    ylim([-100 100])

    %subplot(3,1,3)
    hold on
    %plot(ecgTimes, ecgScaleFactor.*ecgData, 'black')
    %plot(ecgTimes(ecgPeakIndex), ecgScaleFactor.*ecgData(ecgPeakIndex), 'xr')
    %title ("ECG plot")
    %ylim([-100 100])

    %save figure to PNG
    saveas(fig, [rootName '_MAPSE.png'])
    close(fig)
end

%save the XLS file
if saveXls > 0
    SaveMapseToXls(xlsfile, rootName, mapseLeft, mapseRight, mapseCycleEstimatesLeft, mapseCycleEstimatesRight);
end


