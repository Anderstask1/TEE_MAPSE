%Detect the MAPSE peaks and compute the velocity of the displacement
%Author: gkiss
%Started 03.07.2020
function [mapseCycleEstimates, mapseMinIndices, mapseMaxIndices, interpMapse, velocityMapse] = PostProcessMapseCurve(mapseCurve, imageTimes, ecgPeakTimes, velocitySmoothLength)

%get the closest image frames to the ecgPeakTimes
cycleIdx = zeros(size(ecgPeakTimes,1),1);
for i=1:size(ecgPeakTimes,1)
    [~,cycleIdx(i,1)]=min(abs(imageTimes-ecgPeakTimes(i)));
end

%process all ECG cycles
ecgCycles = size (ecgPeakTimes,1)-1;
disp(['Detected ECG cycles ' num2str(ecgCycles)])

%interpolate and zero the MAPSE curve
interpMapse = fillmissing(mapseCurve, 'linear','EndValues','nearest');
interpMapse = interpMapse - min(interpMapse(:));
interpInverseMapse = max(interpMapse(:))-interpMapse + min(interpMapse(:));

mapseMaxIndices = zeros(ecgCycles,1);
mapseMinIndices = zeros(ecgCycles,1);
for i=1:ecgCycles
    interpMapseCycle = interpMapse(cycleIdx(i,1)+1:cycleIdx(i+1,1));
    interpInverseMapseCycle = interpInverseMapse(cycleIdx(i,1)+1:cycleIdx(i+1,1));
    
    %find the max value index
    [~, mapsePeakIndices] = findpeaks(interpMapseCycle);
    [~, mapseMaxPeakIndex] = max(interpMapseCycle(mapsePeakIndices));  
    mapseMaxIndices(i,1) = mapsePeakIndices(mapseMaxPeakIndex)+cycleIdx(i,1);
    
    %expand the inverted MAPSE vector to make sure the ends are included in the search
    interpInverseMapseCycle = [0,0,0,0,0, interpInverseMapseCycle, 0,0,0,0,0];

    %find the min value for the cycle
    [~, inverseMapsePeakIndices] = findpeaks(interpInverseMapseCycle);
    [~, mapseMinPeakIndex] = max(interpInverseMapseCycle(inverseMapsePeakIndices));
    mapseMinIndices(i,1) = inverseMapsePeakIndices(mapseMinPeakIndex)+cycleIdx(i,1)-5; %-5 takes care of the padding   
    
    %visual degug
    %figure, plot(1:size(interpInverseMapseCycle,2), interpInverseMapseCycle), hold on
    %plot(inverseMapsePeakIndices, interpInverseMapseCycle(inverseMapsePeakIndices),'x')

end

%MAPSE estimates per cycle
mapseCycleEstimates = interpMapse(mapseMaxIndices)-interpMapse(mapseMinIndices);

%velocity of MAPSE
velocityMapse = diff(smooth(interpMapse, velocitySmoothLength))./diff(imageTimes);

