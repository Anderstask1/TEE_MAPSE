%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function InverseTransformationLandmarks3D(fileNames, fromAngle, toAngle)
    %call the MAPSE postprocessing script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %% Load data   
        %fieldName = 'RotatedVolumes';
        fieldName = 'MVCenterRotatedVolumes';

        %show progress
        fprintf('Loaded file with name: %s. \n', name);

        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        hdfdata = HdfImport(filePath);
        
        %load optMapseAngles
        filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
        optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end

        %get all fields from data struct
        fields = fieldnames(hdfdata.(fieldName));

        %sort fields on rotation degree
        sortedFields = natsort(fields);

        %number of frames
        frameNo = length(fieldnames(hdfdata.CartesianVolumes));
        
        %% Compute MAPSE for sub-section of annulus
        %only use landmarks from sub-section = a set of rotation degrees
        fromAngleString = strcat('rotated_by_', int2str(fromAngle), '_degrees');
        toAngleString = strcat('rotated_by_', int2str(toAngle), '_degrees');
        
        if any(strcmp(sortedFields,'rotated_by_10_degrees'))
            fromAngleIndex = find(strcmp(sortedFields, fromAngleString));
            toAngleIndex = find(strcmp(sortedFields, toAngleString));

            sortedFields = permute({sortedFields{fromAngleIndex:toAngleIndex}}, [2 1]);
        end

        %% Extract mapse landmark for all rotations and images
        %store landmark coordinates in matrix
        landmarkLeft3DMatrix = zeros(3, numel(sortedFields), frameNo);
        landmarkRight3DMatrix = zeros(3, numel(sortedFields), frameNo);
        
        %similar for annotated
        annotatedLeft3DMatrix = nan(3, numel(sortedFields), frameNo);
        annotatedRight3DMatrix = nan(3, numel(sortedFields), frameNo);

        %iterate over all fields
        for i = 1 : numel(sortedFields)

            %get landmark landmarks coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.(fieldName).(sortedFields{i}).MAPSE_detected_landmarks';

            %if annotated data, get coordinates
            isAnnotatedData = any(strcmp(fieldnames(hdfdata),'Annotations'));
            annotatedLandmarks = zeros(size(mapseLandmarks));
            
            if isAnnotatedData
                %check if rotation is of step degree 10
                stringSplit = split(sortedFields{i},'_');
                rotation = str2double(stringSplit{3});
                if mod(rotation, 10) == 0
                    annotatedLandmarks = hdfdata.Annotations.(sortedFields{i}).ref_coord';
                end
            end
            
            %compute y coordinate value
            volume = hdfdata.CartesianVolumes.('vol01');
            x = size(volume,2)/2;

            %iterate over all frames
            for frame = 1 : frameNo

                %create 3d vector from coordinates, given frame
                landmarkLeft3D = [x; mapseLandmarks(frame,1); mapseLandmarks(frame,2); 1];
                landmarkRight3D = [x; mapseLandmarks(frame,3); mapseLandmarks(frame,4); 1];
                

                %% Inverse transform to original coordinate system
                %load transformation matrix
                trfFileName = strcat(path,'Transformation-matrices_mv-center/', name,'/trf_matrix_mv-center-', sortedFields{i},'.mat');
                mv_trf = load(trfFileName, 'mv_trf').mv_trf;
                
                %inverse transformation matrix, to transform coordinates back to
                %original system
                landmarkLeft3D_inv_trf = mv_trf\landmarkLeft3D; %=inv(mv_trf)*landmarkLeft3D
                landmarkRight3D_inv_trf = mv_trf\landmarkRight3D;

                %convert to cartesian coordinates
                landmarkLeft3D_inv_trf(4) = [];
                landmarkRight3D_inv_trf(4) = [];

                %save
                landmarkLeft3DMatrix(:, i, frame) = landmarkLeft3D_inv_trf;
                landmarkRight3DMatrix(:, i, frame) = landmarkRight3D_inv_trf;
                
                %similar for annotations
                if isAnnotatedData
                    annotatedLeft3D = [x; annotatedLandmarks(frame,2); annotatedLandmarks(frame,1); 1];
                    annotatedRight3D = [x; annotatedLandmarks(frame,4); annotatedLandmarks(frame,3); 1];
                    
                    annotatedLeft3D_inv_trf = mv_trf\annotatedLeft3D; 
                    annotatedRight3D_inv_trf = mv_trf\annotatedRight3D;
                    
                    annotatedLeft3D_inv_trf(4) = [];
                    annotatedRight3D_inv_trf(4) = [];
                    
                    annotatedLeft3DMatrix(:, i, frame) = annotatedLeft3D_inv_trf;
                    annotatedRight3DMatrix(:, i, frame) = annotatedRight3D_inv_trf;
                end

            end
        end
        
        %% Save workspace variables
        %create folder for figure
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_', name);
        save(variablesFilename,...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
    end
end