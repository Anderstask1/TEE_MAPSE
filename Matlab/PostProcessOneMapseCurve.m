%Detect the MAPSE peaks and compute the velocity of the displacement
%Author: gkiss
%Started 03.07.2020
function [mapseCycleEstimates, mapseMinIndices, mapseMaxIndices, interpMapse, velocityMapse] = PostProcessOneMapseCurve(mapseCurve, imageTimes, ecgPeakTimes, velocitySmoothLength)

%remove leading and ending NaNs

%interpolate and zero the MAPSE curve
interpMapse = fillmissing(mapseCurve, 'linear','EndValues','nearest');
interpMapse = interpMapse - min(interpMapse(:));
interpInverseMapse = max(interpMapse(:))-interpMapse + min(interpMapse(:));

mapseMaxIndices = zeros(1,1);
mapseMinIndices = zeros(1,1);

%find the max value index
[~, mapsePeakIndices] = findpeaks(interpMapse);
[~, mapseMaxPeakIndex] = max(interpMapse(mapsePeakIndices));  

if (size(mapseMaxPeakIndex,2) > 0)
    mapseMaxIndices(1,1) = mapsePeakIndices(mapseMaxPeakIndex(1,1));
else
    mapseMaxIndices(1,1) = NaN;
end

%expand the inverted MAPSE vector to make sure the ends are included in the search
interpInverseMapse = [0,0,0,0,0, interpInverseMapse, 0,0,0,0,0];

%find the min value
[~, inverseMapsePeakIndices] = findpeaks(interpInverseMapse);
[~, mapseMinPeakIndex] = max(interpInverseMapse(inverseMapsePeakIndices));

if (size(mapseMinPeakIndex,2) > 0)
    mapseMinIndices(1,1) = inverseMapsePeakIndices(mapseMinPeakIndex(1,1))-5; %-5 takes care of the padding   
else
    mapseMinIndices(1,1) = NaN;
end

%visual degug
%figure, plot(1:size(interpInverseMapse,2), interpInverseMapse), hold on
%plot(inverseMapsePeakIndices, interpInverseMapse(inverseMapsePeakIndices),'x')

%MAPSE estimates per cycle
if (isnan(mapseMaxIndices(1,1)) || isnan(mapseMinIndices(1,1)))
    mapseCycleEstimates = NaN;
else
    mapseCycleEstimates = interpMapse(mapseMaxIndices)-interpMapse(mapseMinIndices);
end

%velocity of MAPSE
velocityMapse = diff(smooth(interpMapse, velocitySmoothLength))./diff(imageTimes);

