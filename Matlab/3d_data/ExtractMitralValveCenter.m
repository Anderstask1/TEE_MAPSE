function ExtractMitralValveCenter
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

    hdfFileName = 'J65BP22M';
    
    angle = 84;

    %% Load data
    fileName = strcat(hdfFileName,'.h5'); 
    filePath = strcat(filesPath, fileName);
    hdfdata = HdfImport(filePath);
    
    %number of frames
    frameNo = length(fieldnames(hdfdata.CartesianVolumes));
    
    %volumetric data
    vol1 = hdfdata.CartesianVolumes.vol01;
    boundingBox = imref3d(size(vol1));

    disp("Extracting MV center from file: " + fileName);

    %get field data
    fieldName = strcat('rotated_by_', int2str(angle),'_degrees');
    hdfImages = hdfdata.RotatedVolumes.(fieldName).images;
    
    %get landmark coordinates, left landmark: x-y, right landmark x-y
    mapseLandmarks = hdfdata.RotatedVolumes.(fieldName).MAPSE_detected_landmarks';
    
    %load transformation matrix
    trfFileName = strcat(filesPath,'Transformation-matrices/','trf_matrix_y-axis-rotation_by_', int2str(angle),'.mat');
    trf = load(trfFileName, 'trf').trf; %received signal from beam k
    
    %% Transformation computation    
    %compute y coordinate value
    volume = hdfdata.CartesianVolumes.('vol01');
    y = size(volume,2)/2;
    
    %create 3d vector from coordinates, only 1st frame
    mapseLeft3D = [mapseLandmarks(1,1); y; mapseLandmarks(1,2); 1];
    mapseRight3D = [mapseLandmarks(1,3); y; mapseLandmarks(1,4); 1];
    
    %inverst transformation matrix, to transform coordinates back to
    %original system
    inverse_tform = inv(trf);
    
    %inverse transform
    mapseLeft3D_inv_trf = inverse_tform * mapseLeft3D;
    mapseRight3D_inv_trf = inverse_tform * mapseRight3D;
    
    %find MV center
    mvCenter= [(mapseLeft3D_inv_trf(1) + mapseRight3D_inv_trf(1))/2; (mapseLeft3D_inv_trf(2) + mapseRight3D_inv_trf(2))/2; (mapseLeft3D_inv_trf(3) + mapseRight3D_inv_trf(3))/2; 1];
    
    %translate origin to MV center
    translateM_mvCenter = [
          1 0 0 mvCenter(1)
          0 1 0 mvCenter(2)
          0 0 1 mvCenter(3)
          0 0 0 1
        ];
    
    %right mapse landmark coordinates after translation
    mapseRight3D_mvCenter = inv(translateM_mvCenter) * mapseRight3D_inv_trf;
    
    %find rotation resulting in the right landmark on the x-axis
    %theta = - atan(mapseRight3D_mvCenter(1)/mapseRight3D_mvCenter(3));
    
    %rotate 360 degrees around mv center
    for theta = 1 : 360
        
        %show progress
        fprintf('Extracting slice that is rotated %d degrees. \n',i)
    
        %rotate around y axis by theta
        rotateM_y = [
             cos(theta)  0  sin(theta)  0
             0           1  0           0
             -sin(theta) 0  cos(theta)  0  
             0           0  0           1
             ];

         mv_trf = translateM_mvCenter * rotateM_y * inv(translateM_mvCenter);

         %transform volume to coordinate system with mv as origin
         mv_tform = affine3d(mv_trf');

        %% Extract slices with rotation around mv center
        %matrix of 2d slices for sequence
        %allocate
        imageData = hdfdata.CartesianVolumes.('vol01');
        slices = zeros(size(imageData, 1), size(imageData, 3), frameNo); 

        for f = 1:frameNo
            %get the 3D frame
            volName = sprintf('vol%02d', f);
            imageData = hdfdata.CartesianVolumes.(volName);

            %rotate volume
            processedData = uint8(imwarp(imageData, mv_tform, 'OutputView', boundingBox));

            %get slize from 3D frame
            slices(:,:,f) = squeeze(processedData(:,mvCenter(2),:));
        end

        %save slice sequence to .h5 file
        fieldName = strcat('rotated_by_', int2str(theta),'_degrees');
        hdfdata.MVCenterRotatedVolumes.(fieldName).images = slices;

        %new filename
        outName = strcat(filesPath, hdfFileName, '.h5');

        HdfExport(outName, hdfdata);
    end
end