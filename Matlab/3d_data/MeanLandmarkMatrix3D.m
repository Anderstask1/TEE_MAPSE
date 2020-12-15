%Compute mean of left and right landmark for all estimations on mital
%annulus
%Author: Anders Tasken
%Started 27.10.2020
function landmarkMean3DMatrix = MeanLandmarkMatrix3D(landmarkLeft3DMatrix, landmarkRight3DMatrix)
    landmarkMean3DMatrix = zeros(size(landmarkLeft3DMatrix));
    for i = 1 : size(landmarkLeft3DMatrix, 2)
        for j = 1 : size(landmarkLeft3DMatrix, 3)
            landmarkRightMatrix = circshift(landmarkRight3DMatrix(:,:,j),19,2); %shift elements 180 degrees
            landmarkMean3DMatrix(:,i,j) = (landmarkLeft3DMatrix(:,i,j) + landmarkRightMatrix(:,i)) ./ 2;
        end
    end
end