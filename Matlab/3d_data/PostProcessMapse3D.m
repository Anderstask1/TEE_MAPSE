%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function [mapse_left, mapse_right] = PostProcessMapse3D(name, filesPath, saveImageSlice, saveAnnulus3D)
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
        y = size(volume,2)/2;

        %iterate over all frames
        for j = 1 : frameNo

            %create 3d vector from coordinates, only 1st frame
            landmarkLeft3D = [mapseLandmarks(j,1); y; mapseLandmarks(j,2); 1];
            landmarkRight3D = [mapseLandmarks(j,3); y; mapseLandmarks(j,4); 1];

            %% Inverse transform to original coordinate system
            %load transformation matrix
            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center_', name,'/trf_matrix_mv-center-', sortedFields{i},'.mat');
            mv_trf = load(trfFileName, 'mv_trf').mv_trf;
            
            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center_', name,'/translateM_probeCenter_matrix_mv-center-', sortedFields{i},'.mat');
            translateM_probeCenter = load(trfFileName, 'translateM_probeCenter').translateM_probeCenter;  

            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center_', name,'/rotateM_y_matrix_mv-center-', sortedFields{i},'.mat');
            rotateM_y = load(trfFileName, 'rotateM_y').rotateM_y;  
            
            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center_', name,'/rotateM_z_matrix_mv-center-', sortedFields{i},'.mat');
            rotateM_z = load(trfFileName, 'rotateM_z').rotateM_z;  

            %inverse transformation matrix, to transform coordinates back to
            %original system
            %inverse_trf = inv(trf);
            mv_trf = translateM_probeCenter * inv(rotateM_z) * inv(translateM_probeCenter);
            inverse_mv_trf = inv(mv_trf);

            %inverse transform
            landmarkLeft3D_inv_trf = inverse_mv_trf * landmarkLeft3D;
            landmarkRight3D_inv_trf = inverse_mv_trf * landmarkRight3D;

            %convert to cartesian coordinates
            landmarkLeft3D_inv_trf(4) = [];
            landmarkRight3D_inv_trf(4) = [];

            %save
            landmarkLeft3DMatrix(:, i, j) = landmarkLeft3D_inv_trf;
            landmarkRight3DMatrix(:, i, j) = landmarkRight3D_inv_trf;

        end
    end
    
    %% Interpolation of landmark values
%     plot3(landmarkLeft3DMatrix(1,:,1),landmarkLeft3DMatrix(2,:,1),landmarkLeft3DMatrix(3,:,1),'ro','LineWidth',2);
%     hold on 
%     xyz = landmarkLeft3DMatrix(:,:,1);
%     xyz(:,isnan(xyz(1,:))) = [];
%     interpolation = cscvn(xyz(:,[1:end 1]));
%     fnplt(interpolation,'r',2);
%     hold off
    interpLeftLandmark3D = InterpolateLandmarks3D(landmarkLeft3DMatrix, frameNo);
    interpRightLandmark3D = InterpolateLandmarks3D(landmarkRight3DMatrix, frameNo);
    
    %% Plot image slice with landmarks
    if saveImageSlice
        SaveSliceImageWithLandmarksHdf(filesPath, name, 'MVCenterRotatedVolumes');
    end
    
    %% Plot mitral annulus 3D
    if saveAnnulus3D
        MitralAnnulus3DRendering(hdfdata, interpLeftLandmark3D, interpRightLandmark3D, landmarkLeft3DMatrix, landmarkRight3DMatrix, frameNo, name, filesPath, 0, 1, 0, 1, 1)
    end
    
    %% Rotation correction
    %estimate frames for ed and es
    [~, ed_frame] = max(nanmean(landmarkLeft3DMatrix(3,:,:)));
    [~, es_frame] = min(nanmean(landmarkLeft3DMatrix(3,:,:)));
    
    %rotation correction transformation matrix- post processing module
    [com_left_corr, com_right_corr] = RotationCorrection3D(landmarkLeft3DMatrix, landmarkRight3DMatrix, ed_frame, es_frame, frameNo, pixelCorr);
    
    %% Peak detection
    [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr);
    
    %% MAPSE calculation
    [mapse_left, mapse_right] = MapseCalculation3D(left_peaks, right_peaks);
end