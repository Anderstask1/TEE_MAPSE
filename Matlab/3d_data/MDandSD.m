%Calculate mean difference and standard deviation of mapse estimates
%against reference values
%Author: Anders Tasken
function [meanDifference, standardDeviation] = MDandSD(mapseEstimatedMap, mapseReferenceMap)
    
    estimatedKeys = keys(mapseEstimatedMap);
    referenceKeys = keys(mapseReferenceMap);

    estimatedValues = nan(length(mapseReferenceMap),1);
    referenceValues = nan(length(mapseReferenceMap),1);
    
    for i = 1 : length(mapseReferenceMap)
        if any(strcmp(estimatedKeys, referenceKeys{i}))
            estimatedValues(i) = mapseEstimatedMap(referenceKeys{i})*1000;
        end
        referenceValues(i) = mapseReferenceMap(referenceKeys{i})*1000;
    end
    
    meanDifference = nanmean(estimatedValues) - nanmean(referenceValues);
    standardDeviation = sqrt(nanvar(estimatedValues)/length(estimatedValues) + nanvar(referenceValues)/length(referenceValues));
end