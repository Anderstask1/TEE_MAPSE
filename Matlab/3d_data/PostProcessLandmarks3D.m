%Postprocess the deep learning results for MAPSE
%Author: Anders Tasken
%Started 18.09.2020

function PostProcessLandmarks3D(fileNames, cardiac_view)

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

        %check if voxeldize is in hdfdata
        %if any(strcmp(fieldnames(hdfdata),'a'))
            %pixelCorr = hdfdata.ImageGeometry.voxelsize;
        %end
        try 
            ds = strcat('/ImageGeometry/voxelsize');
            pixelCorr = h5read(filePath, ds);
        catch
            %default voxelsize value
            pixelCorr = 0.7e-3;
            fprintf('Failed to read pixelCorr for file %s', name);
        end

        %number of frames
        %frameNo = length(fieldnames(hdfdata.CartesianVolumes));
        infoCartesianVolumes = h5info(filePath, '/CartesianVolumes');
        frameNo = length(infoCartesianVolumes.Datasets);
        
        %% Load landmark variables
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_', cardiac_view, '_', name);
        
        load(variablesFilename,...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
        %% Interpolation of landmark values
        [leftLandmarkSplineCurve, leftLandmarkBezierCurve] = InterpolateLandmarks3D(landmarkLeft3DMatrix, frameNo);
        [rightLandmarkSplineCurve, rightLandmarkBezierCurve] = InterpolateLandmarks3D(landmarkRight3DMatrix, frameNo);

        %% Interpolation of annotated landmark values
        [annotatedLeftSplineCurve, annotatedLeftBezierCurve] = InterpolateLandmarks3D(annotatedLeft3DMatrix, frameNo);
        [annotatedRightSplineCurve, annotatedRightBezierCurve] = InterpolateLandmarks3D(annotatedRight3DMatrix, frameNo);
        
        %% Outliers rejection
        rejectedLandmarkLeft3DMatrix = LandmarkOutlierRejection3D(landmarkLeft3DMatrix, leftLandmarkBezierCurve, frameNo, pixelCorr);
        rejectedLandmarkRight3DMatrix = LandmarkOutlierRejection3D(landmarkRight3DMatrix, rightLandmarkBezierCurve, frameNo, pixelCorr);
        
        %% Mean left and right landmark - init and interpolate
        landmarkMean3DMatrix = MeanLandmarkMatrix3D(rejectedLandmarkLeft3DMatrix, rejectedLandmarkRight3DMatrix);
        [meanSplineCurve, meanBezierCurve] = InterpolateLandmarks3D(landmarkMean3DMatrix, frameNo); 
        
        %% Save workspace variables        
        variablesFilename = strcat(path, 'LandmarkMatricesVariables/landmarkMatrices_', cardiac_view, '_', name);
        save(variablesFilename,...
            'leftLandmarkSplineCurve', 'rightLandmarkSplineCurve', 'annotatedLeftSplineCurve', 'annotatedRightSplineCurve',...
            'leftLandmarkBezierCurve', 'rightLandmarkBezierCurve', 'annotatedLeftBezierCurve', 'annotatedRightBezierCurve',...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix',...
            'rejectedLandmarkLeft3DMatrix', 'rejectedLandmarkRight3DMatrix', ...
            'landmarkMean3DMatrix', 'meanSplineCurve', 'meanBezierCurve','-append');
        
    end
end