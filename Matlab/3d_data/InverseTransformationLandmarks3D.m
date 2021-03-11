%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function InverseTransformationLandmarks3D(fileNames, startAngleRotate, endAngleRotate, stepDegreeRotate)
    %call the MAPSE postprocessing script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %% Load data   
        %fieldName = 'RotatedVolumes';
        %fieldName = 'MVCenterRotatedVolumes';

        %show progress
        fprintf('Loaded file with name: %s. \n', name);

        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        %hdfdata = HdfImport(filePath);
        
        %{
        %load optMapseAngles
        filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
        optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        %}

        %get all fields from data struct
        %fields = fieldnames(hdfdata.(fieldName));

        %sort fields on rotation degree
        %sortedFields = natsort(fields);

        %number of frames
        %frameNo = length(fieldnames(hdfdata.CartesianVolumes));
        
        %number of frames
        infoCartesianVolumes = h5info(filePath, '/CartesianVolumes');
        frameNo = length(infoCartesianVolumes.Datasets);
        
        %number of rotations
        infoMVCenterRotatedVolumes = h5info(filePath, '/MVCenterRotatedVolumes');
        rotations = length(infoMVCenterRotatedVolumes.Groups) - 1;
        

        %% Extract mapse landmark for all rotations and images
        %store landmark coordinates in matrix
        landmarkLeft3DMatrix = zeros(3, rotations, frameNo);
        landmarkRight3DMatrix = zeros(3, rotations, frameNo);
        
        %similar for annotated
        annotatedLeft3DMatrix = nan(3, rotations, frameNo);
        annotatedRight3DMatrix = nan(3, rotations, frameNo);
        
        idx = 1;

        %iterate over all fields
        for angle = startAngleRotate : stepDegreeRotate : endAngleRotate

            %get landmark landmarks coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            fieldName = strcat('rotated_by_', int2str(angle),'_degrees');

            ds = strcat('/MVCenterRotatedVolumes/', fieldName, '/MAPSE_detected_landmarks');
            mapseLandmarks = h5read(filePath, ds)';
            %mapseLandmarks = hdfdata.(fieldName).(sortedFields{i}).MAPSE_detected_landmarks';

            %if annotated data, get coordinates
            %isAnnotatedData = any(strcmp(fieldnames(hdfdata),'Annotations'));
            %annotatedLandmarks = zeros(size(mapseLandmarks));
            
            %{
            if isAnnotatedData
                %check if rotation is of step degree 10
                stringSplit = split(sortedFields{i},'_');
                rotation = str2double(stringSplit{3});
                if mod(rotation, 10) == 0
                    annotatedLandmarks = hdfdata.Annotations.(sortedFields{i}).ref_coord';
                end
            end
            %}
            
            %compute x coordinate value
            %volume = hdfdata.CartesianVolumes.('vol01');
            %volume = h5read(filePath, '/CartesianVolumes/vol01');
            %x = size(volume,2)/2;
            trfFileName = strcat(path,'LandmarkMatricesVariables/', name, '/intersection-point.mat');
            intersectionPoint = load(trfFileName,'intersectionPoint').intersectionPoint;
            x = intersectionPoint(1);

            %iterate over all frames
            for frame = 1 : frameNo

                %create 3d vector from coordinates, given frame
                landmarkLeft3D = [x; mapseLandmarks(frame,1); mapseLandmarks(frame,2); 1];
                landmarkRight3D = [x; mapseLandmarks(frame,3); mapseLandmarks(frame,4); 1];
                

                %% Inverse transform to original coordinate system
                %load transformation matrix
                trfFileName = strcat(path,'Transformation-matrices_mv-center/', name,'/trf_matrix_mv-center-', fieldName,'.mat');
                mv_trf = load(trfFileName, 'mv_trf').mv_trf;
                
                %inverse transformation matrix, to transform coordinates back to
                %original system
                landmarkLeft3D_inv_trf = mv_trf\landmarkLeft3D; %=inv(mv_trf)*landmarkLeft3D
                landmarkRight3D_inv_trf = mv_trf\landmarkRight3D;

                %convert to cartesian coordinates
                landmarkLeft3D_inv_trf(4) = [];
                landmarkRight3D_inv_trf(4) = [];

                %save
                landmarkLeft3DMatrix(:, idx, frame) = landmarkLeft3D_inv_trf;
                landmarkRight3DMatrix(:, idx, frame) = landmarkRight3D_inv_trf;
                
                
                %{
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
                %}
            end
            
            idx = idx +1;
            
        end
        
        %% Save workspace variables
        %create folder for figure
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_all-views_', name);
        save(variablesFilename,...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
    end
end