%Extract MV Landmarks, find MV center and rotate around that center
%Author: Anders Tasken
%Started 24.09.2020

function RotateAndSliceMitralValveCenter(optMapseAngles, filesPath)

    %optMapseAngles:
    %angle with best landmark detection result, used for MV center
    %computation, length must be equal to size(fileNames,2), one for
    %each file in folder

    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %iterate over all .h5 files in directory
    for f=1:size(fileNames,2)
        
        %root name from h5 file
        [path, name, ext] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        fprintf('File %d of %d \n', f, size(fileNames,2));

        %% Load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        hdfdata = HdfImport(filePath);

        %number of frames
        frameNo = length(fieldnames(hdfdata.CartesianVolumes));

        %volumetric data
        vol1 = hdfdata.CartesianVolumes.vol01;
        boundingBox = imref3d(size(vol1));
        sz =size(vol1);

        %get field data
        fieldName = strcat('rotated_by_', int2str(optMapseAngles(f)),'_degrees');

        %get landmark coordinates, left landmark: x-y, right landmark x-y
        mapseLandmarks = hdfdata.RotatedVolumes.(fieldName).MAPSE_detected_landmarks';

        %stop iteration if no landmark at specified angle
        if isnan(mapseLandmarks)
            disp('No MAPSE landmarks detected at given angle, so cannot find MV center.');
            continue 
        end
        
        %load transformation matrix
        trfFileName = strcat(filesPath,'Transformation-matrices_y-axis_', name, '/','trf_matrix_y-axis-rotated_by_', int2str(optMapseAngles(f)),'_degrees.mat');
        trf = load(trfFileName, 'trf').trf;

        %% Transformation computation    
        %compute y coordinate value
        volume = hdfdata.CartesianVolumes.('vol01');
        y = size(volume,2)/2;

        %create 3d vector from coordinates, only 1st frame
        mapseLeft3D = [mapseLandmarks(1,1); y; mapseLandmarks(1,2); 1];
        mapseRight3D = [mapseLandmarks(1,3); y; mapseLandmarks(1,4); 1];

        %inverse transformation matrix, to transform coordinates back to
        %original system
        inverse_trf = inv(trf);

        %inverse transform
        mapseLeft3D_inv_trf = inverse_trf * mapseLeft3D;
        mapseRight3D_inv_trf = inverse_trf * mapseRight3D;

        %find MV center
        mvCenter= [(mapseLeft3D_inv_trf(1) + mapseRight3D_inv_trf(1))/2; (mapseLeft3D_inv_trf(2) + mapseRight3D_inv_trf(2))/2; (mapseLeft3D_inv_trf(3) + mapseRight3D_inv_trf(3))/2; 1];

        %translate origin to probe center
        translateM_probeCenter = [
              1 0 0 sz(1)/2
              0 1 0 sz(2)/2
              0 0 1 0
              0 0 0 1
            ];

    %     %right mapse landmark coordinates after translation
    %     mapseRight3D_mvCenter = inv(translateM_mvCenter) * mapseRight3D_inv_trf;
    %     
    %     %find rotation resulting in the right landmark on the x-axis
    %     theta = - atan(mapseRight3D_mvCenter(1)/mapseRight3D_mvCenter(3));

        %right mapse landmark coordinates after translation
        mvCenter_translated = inv(translateM_probeCenter) * mvCenter;

        %find rotation resulting in the MV center on the z-axis (when origin at probe)
        alpha = - atan(mvCenter_translated(1)/mvCenter_translated(3));

        %rotate around y axis by theta
        rotateM_y = [
             cos(alpha)  0  sin(alpha)  0
             0           1  0           0
             -sin(alpha) 0  cos(alpha)  0  
             0           0  0           1
             ];

        %rotate 360 degrees around mv center
        for angle = 0 : 10 : 360

            %show progress
            fprintf('Extracting slice that is rotated %d degrees around MV center. \n',angle)

            theta = deg2rad(angle);

            %rotate around z axis by theta
            rotateM_z = [
                 cos(theta)  -sin(theta)  0 0
                 sin(theta)  cos(theta)   0 0
                 0           0            1 0  
                 0           0            0 1
                 ];

            mv_trf = translateM_probeCenter * rotateM_z * rotateM_y * inv(translateM_probeCenter);

            %transform volume to coordinate system with mv as origin
            mv_tform = affine3d(mv_trf');

            %create folder for transformation matrices
            directoryPath = strcat(filesPath, 'Transformation-matrices_mv-center_', name, '/');
            if ~exist(directoryPath, 'dir')
                % Folder does not exist so create it.
                mkdir(directoryPath);
            end

            %save transformation in order to inverse transform coordinates later
            trfFileName = strcat(directoryPath, 'trf_matrix_mv-center-rotated_by_', int2str(angle),'_degrees.mat');
            save(trfFileName,'mv_trf');
            
            trfFileName = strcat(directoryPath,'translateM_probeCenter_matrix_mv-center-rotated_by_', int2str(angle),'_degrees.mat');
            save(trfFileName,'translateM_probeCenter');
            
            trfFileName = strcat(directoryPath,'rotateM_y_matrix_mv-center-rotated_by_', int2str(angle),'_degrees.mat');
            save(trfFileName,'rotateM_y');
            
            trfFileName = strcat(directoryPath,'rotateM_z_matrix_mv-center-rotated_by_', int2str(angle),'_degrees.mat');
            save(trfFileName,'rotateM_z');

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
                slices(:,:,f) = squeeze(processedData(:,round(mvCenter(2)),:));
            end

            %save slice sequence to .h5 file
            fieldName = strcat('rotated_by_', int2str(angle),'_degrees');
            hdfdata.MVCenterRotatedVolumes.(fieldName).images = slices;

            %new filename
            outName = strcat(filesPath, name, '.h5');

            HdfExport(outName, hdfdata);
        end
    end
end