%Pipeline of automatic mapse computation from 3d TEE ultrasound data
%Started 31.08.2020
%Author: Anders Tasken

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear

%%

addpath('dirParsing')
addpath('ecgDetect')
addpath('3d_data')
addpath('Bezier')
addpath('3d_data/ShadedPlot')
addpath('3d_data/thrynae-BlandAltmanPlot-bf89c89')
addpath('surface_area')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Filepath and all files in folder

%CurrentAnnotatingData
%test_old
%test_new
%test_mix1
%test_old_threshold55
%test_new_threshold55z
%test_mix1_threshold55

filePaths = {'old', 'new', 'mix1'};

for i = 1 : length(filePaths)
    
    modelPath = strcat('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_', filePaths{i},'.pth');
    
    filesPath = strcat('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_', filePaths{i}, '/');
    
    %%
    modelPath = strcat('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Data/best_true_weights_Mapse_new.pth');
    
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/';

    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %% Hyperparameters

    %Rotate volume from start-angle to end-angle with degree step
    startAngleCenter = 60;
    endAngleCenter = 120;
    stepDegreeCenter = 1;

    %Rotate volume from start-angle to end-angle with degree step
    startAngleRotate = 0;
    endAngleRotate = 360;
    stepDegreeRotate = 10;
    % % 
    % Threshold for probability map - binary CoM
    thresholdCenter = 0.5;
    thresholdRotate = 0.5;

    % Save parameters in text file
    %Save results as txt file table
    parametersName = strcat(filesPath, 'Hyperparameter-values', '.txt');
    fileID = fopen(parametersName,'w');

    %---raw--- landmark values
    fprintf(fileID,'%s\n\n', '----------------- Hyperparameters -----------------');
    fprintf(fileID,'%s\n', 'Rotate about y-axis: start angle -- end angle -- step degree');
    fprintf(fileID,'%d%s%d%s%d%s\n\n', startAngleCenter, ' -- ', endAngleCenter, ' -- ', stepDegreeCenter, ' degrees');
    fprintf(fileID,'%s\n', 'Rotate about y-axis: start angle -- end angle -- step degree');
    fprintf(fileID,'%d%s%d%s%d%s\n\n', startAngleRotate, ' -- ', endAngleRotate, ' -- ', stepDegreeRotate, ' degrees');
    fprintf(fileID,'%s\n', 'Threshold for probability map to binary map convertions; y-axis rotation -- mv-center rotation');
    fprintf(fileID,'%.3f%s%.3f\n\n',thresholdCenter, ' -- ', thresholdRotate);

    fclose(fileID);

    %% Reference MAPSE values
    SaveMapseReferences(filesPath);

    %% Rotate volume around y axis from probe center
    %rotate 3D ultrasound h5 file in folder along the probe axis
    %and create slice every degree - save image of rotation
    disp('Rotate volume around y axis');

    %rotate 3d data
    RotateVolumeYAxis3D(fileNames, startAngleCenter, endAngleCenter, stepDegreeCenter);

    %% Save image from first frame of y-axis rotation
    disp('Save image slice from volume rotated around y axis');

    %SaveSliceImageHdf(fileNames, 'RotatedVolumes');

    %% Run python script with DNN model finding MAPSE landmarks in all y-axis rotated
    % slices from volumes in folder

    disp('Run DNN model to find MAPSE landmarks in y-axis rotated slices (python)');

    % p.s. conda environment must be activated on matlab launch: 
    % conda activate TEE_MAPSE
    % matlab
    system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py RotatedVolumes %s %0.2f %s', filesPath, thresholdCenter, modelPath));

    %% Save image of y-axis rotated slices with landmarks
    disp('Save images of y-axis rotated slices with landmarks');

    %SaveSliceImageWithLandmarksHdf(fileNames, 'RotatedVolumes');

    %% Find optimal angle for mitral valve center computation
    disp('Find optimal y-axis rotation angle');

    %optimal angle = rotation angle with mapse landmarks furthest apart
    OptimalMapseAngles(fileNames, filesPath);

    %% Rotate around mv center
    disp('Rotate volume around MV center');

    RotateAndSliceMitralValveCenter(fileNames, startAngleRotate, endAngleRotate, stepDegreeRotate);

    %% Save images of mv center rotation
    disp('Save images of slices rotated around MV center');

    %save image
    SaveSliceImageHdf(fileNames, 'MVCenterRotatedVolumes');

    %% Run python script with DNN model finding MAPSE landmarks in all mv-center rotated
    % slices from volumes in folder

    disp('Run DNN model to find MAPSE landmarks in MV center rotated slices (python)');

    % p.s. conda environment must be activated on matlab launch: 
    % conda activate TEE_MAPSE
    % matlab
    system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py MVCenterRotatedVolumes %s %0.2f\n %s', filesPath, thresholdRotate, modelPath));

    %% Save image of mv-center rotated slices with landmarks
    disp('Save images of mv center rotated slices with landmarks');

    %SaveSliceImageWithLandmarksHdf(fileNames, 'MVCenterRotatedVolumes');
    
    %% Classify the view of all images rotated around the mv-center
    disp('View classification of all images rotated about the mv-center');
    
    %choose model architecture - CNN - VGG16 - ResNext
    model_name = 'CNN';
    
    % p.s. conda environment must be activated on matlab launch: 
    % conda activate TEE_MAPSE
    % matlab
    system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_cardiac-view-classification/Code/pipeline3D.py %s', model_name));
    
    %% Plot classification as a function of rotation degree
    
    PlotCardiacClassOfRotation(fileNames);
    
    %% Run python script to annotate landmarks
    disp('Run annotations script from python on MV center rotated slices (python)');

    % p.s. conda environment must be activated on matlab launch: 
    % conda activate TEE_MAPSE
    % matlab
    %system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/manualMALabeling.py -d %s', filesPath));

    %% Inverse Transformation of Landmarks
    disp('Inverse transformation of landmarks to 3D');

    InverseTransformationLandmarks3D(fileNames, 0, 360);

    %% Landmark selection based on view class
    disp('Group landmark based on classified cardiac view, to compute regional 2C, 4C and ALAX MAPSE');
    
    LandmarkCardiacViewSelection(fileNames);
    
    %% Interpolation - outlier rejection - mean left&right landmarks
    disp('Landmarks Post-Processing');

    PostProcessLandmarks3D(fileNames, 'all-views');
    PostProcessLandmarks3D(fileNames, '4C');
    PostProcessLandmarks3D(fileNames, '2C');
    PostProcessLandmarks3D(fileNames, 'ALAX');

    %% MAPSE processing
    disp('Compute MAPSE values (plot mapse curve) (annulus render)');

    PostProcessMapse3D(fileNames, 'all-views');
    PostProcessMapse3D(fileNames, '4C');
    PostProcessMapse3D(fileNames, '2C');
    PostProcessMapse3D(fileNames, 'ALAX');

    %% Save MAPSE results
    disp('Save MAPSE value results in table as a text file')

    SaveMapseValuesTxtFile(filesPath, 'all-views');
    SaveMapseValuesTxtFile(filesPath, '4C');
    SaveMapseValuesTxtFile(filesPath, '2C');
    SaveMapseValuesTxtFile(filesPath, 'ALAX');
    %SaveMapseToCSV(filesPath);

    %% Plot statistics
    disp('Create plots of results from statistics')

    %LEFT
    StatisticalResultPlots(fileNames, filesPath, 'mapse_raw_left_map', 'mapse_mean_reference_map', 'landmarkLeft3DMatrix', 'annotatedLeft3DMatrix');

    %% RIGHT
    StatisticalResultPlots(fileNames, filesPath, 'mapse_raw_right_map', 'mapse_mean_reference_map', 'landmarkRight3DMatrix', 'annotatedRight3DMatrix');

    %% LEFT
    %StatisticalResultPlots(fileNames, filesPath, 'mapse_bezier_left_map', 'mapse_mean_reference_map', 'leftLandmarkBezierCurve', 'annotatedLeftBezierCurve');

    %% RIGHT
    %StatisticalResultPlots(fileNames, filesPath, 'mapse_bezier_right_map', 'mapse_mean_reference_map', 'rightLandmarkBezierCurve', 'annotatedRightBezierCurve');

    %% LEFT
    %StatisticalResultPlots(fileNames, filesPath, 'mapse_rejected_left_map', 'mapse_mean_reference_map', 'rejectedLandmarkLeft3DMatrix', 'annotatedLeft3DMatrix');

    %% RIGHT
    %StatisticalResultPlots(fileNames, filesPath, 'mapse_rejected_right_map', 'mapse_mean_reference_map', 'rejectedLandmarkRight3DMatrix', 'annotatedRight3DMatrix');

    %% MEAN
    %StatisticalResultPlots(fileNames, filesPath, 'mapse_mean_rejected_map', 'mapse_mean_reference_map', 'landmarkMean3DMatrix', 'annotatedLeft3DMatrix');

    %% Plot mitral annulus 3D
    disp('Create plots for all files in directory')

    %MitralAnnulus3DRendering(fileNames, 'all-views');

    %% Show plot from all files
    disp('Show selected plots')

    %Chose one of the following
    % _frame_1_scatterfig_rejected
    % _frame_1_lineplot3D_with_slices
    % _frame_1_spline_interpolation-plot3D_with_slices
    % _spline_interpolation-plot3D_left_all-frames
    % _frame_1_mean_scatter_spline_bezier_3D_with_slices
    %MitralAnnulus3DPlot(fileNames, {'_frame_1_spline_interpolation-plot3D_with_slices'});
    
    %% Compute area of mitral valve
    
    %MitralValveAreaComputation(fileNames, 'all-views');
    
    %% Compute perimeter of mitral valve
    
    %MitralValvePerimeterComputation(fileNames, 'all-views');
end

