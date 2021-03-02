%Extract MV Landmarks, find MV center and rotate around that center
%Author: Anders Tasken
%Started 24.09.2020

function RotateAndSliceMitralValveCenter(fileNames, startAngle, endAngle, stepDegree)

    %optMapseAngles:
    %angle with best landmark detection result, used for MV center
    %computation, length must be equal to size(fileNames,2), one for
    %each file in folder

    %iterate over all .h5 files in directory
    for f=1:size(fileNames,2)
        
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        fprintf('File %d of %d \n', f, size(fileNames,2));

        %% Load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        
        %hdfdata = HdfImport(filePath);
        %frameNo = length(fieldnames(hdfdata.CartesianVolumes));

        %number of frames
        infoCartesianVolumes = h5info(filePath, '/CartesianVolumes');
        frameNo = length(infoCartesianVolumes.Datasets);
        
        %{
        %volumetric data
        vol1 = hdfdata.CartesianVolumes.vol01;
        boundingBox = imref3d(size(vol1));
        sz = size(vol1);
        %}
        
        infoVol01 = h5info(filePath, '/CartesianVolumes/vol01');
        sz = infoVol01.Dataspace.Size;
        boundingBox = imref3d(sz);
        
        info = h5info(filePath);
        if ~any(strcmp({info.Groups.Name}, '/RotatedVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        end
        
        %{
        %check if volume is rotated
        if ~any(strcmp(fieldnames(hdfdata),'RotatedVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        end
        %}
        
        %load optMapseAngles
        filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
        optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        
        %get field data
        fieldName = strcat('rotated_by_', int2str(optMapseAngle),'_degrees');

        %get landmark coordinates
        %mapseLandmarks = hdfdata.RotatedVolumes.(fieldName).MAPSE_detected_landmarks';
        
        ds = strcat('/RotatedVolumes/', fieldName, '/MAPSE_detected_landmarks')
        mapseLandmarks = h5read(filePath, ds)';

        %stop iteration if no landmark at specified angle
        if isnan(mapseLandmarks)
            disp('No MAPSE landmarks detected at given angle, so cannot find MV center.');
            continue 
        end
        
        %load rotation matrix
        trfFileName = strcat(path,'Transformation-matrices_y-axis/', name, '/rotateM_y_y-axis-rotated_by_', int2str(optMapseAngle),'_degrees.mat');
        rotateM_y = load(trfFileName, 'rotateM_y').rotateM_y;
        
        %translate origin to probe center
        translateM_probeCenter = [
              1 0 0 sz(1)/2
              0 1 0 sz(2)/2
              0 0 1 0
              0 0 0 1
            ];
         
        %% Transformation computation    
        %compute x coordinate value
        x = sz(1)/2;

        %create 3d vector from coordinates, only 1st frame, left
        %landmark: x-z, right landmark x-z
        mapseLeft3D_trf = [x; mapseLandmarks(1,1); mapseLandmarks(1,2); 1];
        mapseRight3D_trf = [x; mapseLandmarks(1,3); mapseLandmarks(1,4); 1];
        
        %find MV center
        mvCenter3D_trf = [(mapseLeft3D_trf(1) + mapseRight3D_trf(1))/2; (mapseLeft3D_trf(2) + mapseRight3D_trf(2))/2; (mapseLeft3D_trf(3) + mapseRight3D_trf(3))/2; 1];
        
        mvCenter3D = translateM_probeCenter \ mvCenter3D_trf;
        
        alpha = atan(mvCenter3D(2)/mvCenter3D(3));
        
        rotateM_x = [
            1  0           0           0
            0  cos(alpha)  -sin(alpha) 0
            0  sin(alpha)  cos(alpha)  0  
            0  0           0           1
            ];

        %rotate 360 degrees around mv center
        for angle = startAngle : stepDegree : endAngle

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

            mv_trf = (translateM_probeCenter * rotateM_z * rotateM_x * rotateM_y) / translateM_probeCenter;

            %transform volume +
            mv_tform = affine3d(mv_trf');

            %create folder for transformation matrices
            directoryPath = strcat(path, 'Transformation-matrices_mv-center/');
            if ~exist(directoryPath, 'dir')
                % Folder does not exist so create it.
                mkdir(directoryPath);
            end
            
            %create folder for transformation matrices
            directoryPath = strcat(directoryPath, name, '/');
            if ~exist(directoryPath, 'dir')
                % Folder does not exist so create it.
                mkdir(directoryPath);
            end

            %save transformation in order to inverse transform coordinates later
            trfFileName = strcat(directoryPath, 'trf_matrix_mv-center-rotated_by_', int2str(angle),'_degrees.mat');
            save(trfFileName,'mv_trf');

            %% Extract slices with rotation around mv center
            %matrix of 2d slices for sequence
            %allocate
            %slices = zeros(size(vol1, 1), size(vol1, 3), frameNo); 
            
            slices = zeros(sz(1), sz(3), frameNo); 

            for frame = 1:frameNo
                %get the 3D frame
                volName = sprintf('vol%02d', frame);
                %imageData = hdfdata.CartesianVolumes.(volName);
                
                ds = strcat('/CartesianVolumes/', volName);
                imageData = h5read(filePath, ds);
                
                %rotate volume
                processedData = uint8(imwarp(imageData, mv_tform, 'OutputView', boundingBox));

                %get slize from 3D frame
                slices(:,:,frame) = squeeze(processedData(:,round(sz(2)/2),:));
            end

            %save slice sequence to .h5 file
            fieldName = strcat('rotated_by_', int2str(angle),'_degrees');
            %hdfdata.MVCenterRotatedVolumes.(fieldName).images = slices;

            %new filename
            outName = strcat(path, name, '.h5');
            ds = strcat('/MVCenterRotatedVolumes/', fieldName, '/images');
            
            try
                h5create(outName, ds, size(slices));
                h5write(outName, ds, slices);
            catch
                h5write(outName, ds, slices);
            end

            %HdfExport(outName, hdfdata);
        end
    end
end