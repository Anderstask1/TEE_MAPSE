%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function [mapse_left, mapse_right] = PostProcessMapse3D(name, filesPath, mapse_left_matrix, mapse_right_matrix, saveImageSlice, saveAnnulus3D)
    %% Load data   
    %fieldName = 'RotatedVolumes';
    fieldName = 'MVCenterRotatedVolumes';

    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    %load data
    fileName = strcat(name,'.h5'); 
    filePath = strcat(filesPath, fileName);
    hdfdata = HdfImport(filePath);
    
    %get all fields from data struct
    fields = fieldnames(hdfdata.(fieldName));

    %sort fields on rotation degree
    sortedFields = natsort(fields);

    %number of frames
    frameNo = length(fieldnames(hdfdata.CartesianVolumes));
    
    pixelCorr = hdfdata.ImageGeometry.voxelsize;

    %% Extract mapse landmark for all rotations and images
    %store mapse coordinates in matrix
    mapseLeft3DMatrix = zeros(3, numel(fields), frameNo);
    mapseRight3DMatrix = zeros(3, numel(fields), frameNo);

    %iterate over all fields
    for i = 1 : numel(fields)

        %show progressfields
        fprintf('Processing file: %s, on field %d of %d \n', name, i, numel(fields));

        %get field data
        fieldData = hdfdata.(fieldName).(fields{i}).images;

        %get mapse landmarks coordinates, left landmark: x-y, right landmark
        %x-y, for all frames
        mapseLandmarks = hdfdata.(fieldName).(sortedFields{i}).MAPSE_detected_landmarks';

        %plot image slice with landmarks
        if saveImageSlice
            SaveImageSlice(fieldData, mapseLandmarks, name, fields(i), filesPath);
        end

        %compute y coordinate value
        volume = hdfdata.CartesianVolumes.('vol01');
        y = size(volume,2)/2;

        %iterate over all frames
        for j = 1 : frameNo

            %create 3d vector from coordinates, only 1st frame
            mapseLeft3D = [mapseLandmarks(j,1); y; mapseLandmarks(j,2); 1];
            mapseRight3D = [mapseLandmarks(j,3); y; mapseLandmarks(j,4); 1];

            %% Inverse transform to original coordinate system
            %load transformation matrix
            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center/','trf_matrix_mv-center-', sortedFields{i},'.mat');
            mv_trf = load(trfFileName, 'mv_trf').mv_trf;

            %inverse transformation matrix, to transform coordinates back to
            %original system
            inverse_trf = inv(mv_trf);

            %inverse transform
            mapseLeft3D_inv_trf = inverse_trf * mapseLeft3D;
            mapseRight3D_inv_trf = inverse_trf * mapseRight3D;

            %convert to cartesian coordinates
            mapseLeft3D_inv_trf(4) = [];
            mapseRight3D_inv_trf(4) = [];

            %save
            mapseLeft3DMatrix(:, i, j) = mapseLeft3D_inv_trf;
            mapseRight3DMatrix(:, i, j) = mapseRight3D_inv_trf;

        end
    end

    %plot mitral annulus 3D
    if saveAnnulus3D
        MitralAnnulus3DRendering(mapseLeft3DMatrix, mapseRight3DMatrix, frameNo, name, filesPath)
    end
    
    %% Rotation correction
    %Rotation correction transformation matrix- post processing module
    ed_frame = 1;
    es_frame = 10;
    [com_left_corr, com_right_corr] = RotationCorrection3D(mapseLeft3DMatrix, mapseRight3DMatrix, ed_frame, es_frame, frameNo, pixelCorr);
    
    %% Peak detection
    [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr);
    
    %% MAPSE calculation
    [mapse_left, mapse_right] = MapseCalculation3D(left_peaks, right_peaks);
end