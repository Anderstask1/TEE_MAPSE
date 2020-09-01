%Detect the strain peaks and compute the strain value for the cycle
%Author: gkiss
%Started 03.07.2020
function [strainEstimate, strainMinIndex, strainMaxIndex] = PostProcessStrainCurve(strainCurve)

%find the min value index
inverseStrainCurve = max(strainCurve(:))-strainCurve + min(strainCurve(:));
[~, minPeakIndices] = findpeaks(inverseStrainCurve);
[~, strainMinPeakIndex] = max(inverseStrainCurve(minPeakIndices));
strainMinIndex = minPeakIndices(strainMinPeakIndex);
strainMinVal = strainCurve(strainMinIndex);

%expand the inverted strain vector to make sure the ends are included in
%the search and finc the max value
strainCurveExtended = [0,0,0,0,0, strainCurve(1:strainMinIndex), 0,0,0,0,0];
[~, maxPeakIndices] = findpeaks(strainCurveExtended);
[~, strainMaxPeakIndex] = max(strainCurveExtended(maxPeakIndices));
strainMaxIndex = maxPeakIndices(strainMaxPeakIndex)-5; %-5 takes care of the padding
strainMaxVal = strainCurve(strainMaxIndex);


%strain estimate for this cycle (Lmin-Lmax)/Lmax
strainEstimate = (strainMinVal-strainMaxVal)/strainMaxVal;


