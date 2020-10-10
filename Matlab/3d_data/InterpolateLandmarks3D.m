function interpLandmark3DArray = InterpolateLandmarks3D(landmark3DMatrix, frameNo)

    %init
    interpLandmark3DArray = cscvn(0);

    %iterate over all frames
    for f = 1 : frameNo
        %get x, y, z values of all landmarks
        xyz = landmark3DMatrix(:,:,f);
        
        %remove all nan values
        xyz(:,isnan(xyz(1,:))) = [];
        xyz(:,isnan(xyz(2,:))) = [];
        xyz(:,isnan(xyz(3,:))) = [];
        %xyz(isnan(xyz)) = 0;
        
        %interpolating cubic spline curve
        interpLandmark3DArray(f) = cscvn(xyz(:,[1:end 1]));
    end
end