%Compute mean distance between annotated and predicted all landmarks on the
%mitral annulus
%Author: Anders Tasken
%Started 27.10.2020
function error = LandmarkError(pixelCorr, landmark3DMatrix, annotated3DMatrix)
    % Compute error if annotated data
    error = nan;
    if any(annotated3DMatrix(:))
        landmark3DMatrix = reshape(landmark3DMatrix, size(landmark3DMatrix, 1), size(landmark3DMatrix,2) * size(landmark3DMatrix, 3));
        annotated3DMatrix = reshape(annotated3DMatrix, size(annotated3DMatrix, 1), size(annotated3DMatrix,2) * size(annotated3DMatrix, 3));
        
        errorMatrix = sqrt(sum((landmark3DMatrix - annotated3DMatrix).^2));
        errorMatrix = errorMatrix(~isnan(errorMatrix));
        error = pixelCorr * mean(errorMatrix);
    end
end