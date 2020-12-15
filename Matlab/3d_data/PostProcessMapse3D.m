%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function PostProcessMapse3D(fileNames)

    %save mapse values in map
    mapse_raw_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_raw_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mapse_rejected_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_rejected_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mapse_mean_rejected_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mapse_bezier_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_bezier_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mapse_annotated_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_annotated_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    annotated_error1_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error2_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error1_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error2_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    annotated_error1_rejected_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error2_rejected_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error1_rejected_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    annotated_error2_rejected_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    
    mean_error1_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mean_error2_map = containers.Map('KeyType', 'char', 'ValueType', 'double');

    %call the MAPSE postprocessing script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %% Load data   
        
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

        %number of frames
        frameNo = length(fieldnames(hdfdata.CartesianVolumes));

        %default voxelsize value
        pixelCorr = 0.7e-3;

        %check if voxeldize is in hdfdata
        if any(strcmp(fieldnames(hdfdata),'a'))
            pixelCorr = hdfdata.ImageGeometry.voxelsize;
        end

        %% Load landmark variables
        variablesFilename = strcat(path, 'LandmarkMatricesVariables/landmarkMatrices_', name);
        load(variablesFilename,...
            'leftLandmarkSplineCurve', 'rightLandmarkSplineCurve', 'annotatedLeftSplineCurve', 'annotatedRightSplineCurve',...
            'leftLandmarkBezierCurve', 'rightLandmarkBezierCurve', 'annotatedLeftBezierCurve', 'annotatedRightBezierCurve',...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix',...
            'rejectedLandmarkLeft3DMatrix', 'rejectedLandmarkRight3DMatrix', ...
            'landmarkMean3DMatrix', 'meanSplineCurve', 'meanBezierCurve');

        %% MAPSE calculation - Raw landmark: Rotation correction - Peak detection
        % Rotation correction
        
        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(landmarkLeft3DMatrix, landmarkRight3DMatrix, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 1);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_raw_left_map(name), mapse_raw_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% MAPSE calculation - Rejected raw landmark: Rotation correction - Peak detection
        % Rotation correction

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(rejectedLandmarkLeft3DMatrix, rejectedLandmarkRight3DMatrix, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 0);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_rejected_left_map(name), mapse_rejected_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% MAPSE calculation - Mean and rejected landmark: Rotation correction - Peak detection
        % Rotation correction

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(landmarkMean3DMatrix, landmarkMean3DMatrix, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 0);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_mean_rejected_map(name), ~] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% MAPSE calculation - Bezier interpolation: Rotation correction - Peak detection
        %rearrange matrix
        leftLandmarkBezier3D = permute(leftLandmarkBezierCurve, [2 1 3]);
        rightLandmarkBezier3D = permute(rightLandmarkBezierCurve, [2 1 3]);
        
        % Rotation correction

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(leftLandmarkBezier3D, rightLandmarkBezier3D, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 0);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_bezier_left_map(name), mapse_bezier_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% MAPSE calculation - Annotated data: Rotation correction - Peak detection
        % Rotation correction

        %rotation correction transformation matrix- post processing module
        [com_left_corr, com_right_corr] = RotationCorrection3D(annotatedLeft3DMatrix, annotatedRight3DMatrix, frameNo, pixelCorr);

        % Peak detection
        [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, path, name, 0);

        % MAPSE calculation
        %post process the file - add mapse value and file name to map
        [mapse_annotated_left_map(name), mapse_annotated_right_map(name)] = MapseCalculation3D(left_peaks, right_peaks);
        
        %% Landmark error computation
        annotated_error1_left_map(name) = LandmarkError(pixelCorr, landmarkLeft3DMatrix, annotatedLeft3DMatrix);
        annotated_error2_left_map(name) = LandmarkError(pixelCorr, landmarkLeft3DMatrix, annotatedRight3DMatrix);
        
        
        annotated_error1_right_map(name) = LandmarkError(pixelCorr, landmarkRight3DMatrix, annotatedLeft3DMatrix);
        annotated_error2_right_map(name) = LandmarkError(pixelCorr, landmarkRight3DMatrix, annotatedRight3DMatrix);
        
                                                                                                  
        annotated_error1_rejected_left_map(name) = LandmarkError(pixelCorr, rejectedLandmarkLeft3DMatrix,annotatedLeft3DMatrix);
        annotated_error2_rejected_left_map(name) = LandmarkError(pixelCorr, rejectedLandmarkLeft3DMatrix, annotatedRight3DMatrix);
                                                                                                                    
                                                                                                                    
        annotated_error1_rejected_right_map(name) = LandmarkError(pixelCorr, rejectedLandmarkRight3DMatrix, annotatedLeft3DMatrix);
        annotated_error2_rejected_right_map(name) = LandmarkError(pixelCorr, rejectedLandmarkRight3DMatrix, annotatedRight3DMatrix);
                                                                                                                    
                                                                                                                                                                                                     
        mean_error1_map(name) = LandmarkError(pixelCorr, landmarkMean3DMatrix, annotatedLeft3DMatrix);
        mean_error2_map(name) = LandmarkError(pixelCorr, landmarkMean3DMatrix, annotatedRight3DMatrix);
        
                                                                                                  
    end
    
    %% Save workspace variables
    variablesFilename = strcat(path, 'LandmarkMatricesVariables/MapseAndErrorMaps');
    save(variablesFilename,...
        'mapse_raw_left_map', 'mapse_raw_right_map', 'mapse_bezier_left_map', 'mapse_bezier_right_map',...
        'mapse_annotated_left_map', 'mapse_annotated_right_map', 'mapse_rejected_left_map', 'mapse_rejected_right_map', 'mapse_mean_rejected_map', ...
        'annotated_error1_left_map', 'annotated_error2_left_map', 'annotated_error1_right_map', 'annotated_error2_right_map', ...
        'annotated_error1_rejected_left_map', 'annotated_error2_rejected_left_map', 'annotated_error1_rejected_right_map',...
        'annotated_error2_rejected_right_map', 'mean_error1_map', 'mean_error2_map');
    
end