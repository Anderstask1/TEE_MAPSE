%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function [mapse_raw_left_map, mapse_raw_right_map, mapse_bezier_left_map, mapse_bezier_right_map] = PostProcessMapse3D(fileNames, saveAnnulus3D)

    %save mapse values in map
    mapse_raw_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_raw_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mapse_bezier_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_bezier_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');

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

        %get all fields from data struct
        fields = fieldnames(hdfdata.(fieldName));

        %sort fields on rotation degree
        sortedFields = natsort(fields);

        %number of frames
        frameNo = length(fieldnames(hdfdata.CartesianVolumes));

        %default voxelsize value
        pixelCorr = 0.7e-3;

        %check if voxeldize is in hdfdata
        if any(strcmp(fieldnames(hdfdata),'a'))
            pixelCorr = hdfdata.ImageGeometry.voxelsize;
        end

        %% Extract mapse landmark for all rotations and images
        %store landmark coordinates in matrix
        landmarkLeft3DMatrix = zeros(3, numel(fields), frameNo);
        landmarkRight3DMatrix = zeros(3, numel(fields), frameNo);

        %iterate over all fields
        for i = 1 : numel(fields)

            %show progressfields
            fprintf('Processing file: %s, on field %d of %d \n', name, i, numel(fields));

            %get landmark landmarks coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.(fieldName).(sortedFields{i}).MAPSE_detected_landmarks';

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

            end
        end

        %% Interpolation of landmark values
        [leftLandmarkSplineCurve, leftLandmarkBezierCurve] = InterpolateLandmarks3D(landmarkLeft3DMatrix, frameNo);
        [rightLandmarkSplineCurve, rightLandmarkBezierCurve] = InterpolateLandmarks3D(landmarkRight3DMatrix, frameNo);

        %% Plot mitral annulus 3D
        if saveAnnulus3D
            MitralAnnulus3DRendering(hdfdata, leftLandmarkSplineCurve, rightLandmarkSplineCurve, leftLandmarkBezierCurve, rightLandmarkBezierCurve, landmarkLeft3DMatrix, landmarkRight3DMatrix, frameNo, name, path, 1, 1, 1, 1)
        end

        %% Raw landmark: Rotation correction - Peak detection - MAPSE calculation
        % Rotation correction
        %estimate frames for ed and es
        [~, ed_frame] = max(nanmean(landmarkLeft3DMatrix(3,:,:)));
        [~, es_frame] = min(nanmean(landmarkLeft3DMatrix(3,:,:)));

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(landmarkLeft3DMatrix, landmarkRight3DMatrix, ed_frame, es_frame, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 1);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_raw_left_map(name), mapse_raw_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% Bezier interpolation: Rotation correction - Peak detection - MAPSE calculation
        %rearrange matrix
        leftLandmarkBezier3D = permute(leftLandmarkBezierCurve, [2 1 3]);
        rightLandmarkBezier3D = permute(rightLandmarkBezierCurve, [2 1 3]);
        
        % Rotation correction
        %estimate frames for ed and es
        [~, ed_frame] = max(nanmean(leftLandmarkBezier3D(3,:,:)));
        [~, es_frame] = min(nanmean(rightLandmarkBezier3D(3,:,:)));

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(leftLandmarkBezier3D, rightLandmarkBezier3D, ed_frame, es_frame, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 1);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_bezier_left_map(name), mapse_bezier_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
    end
end