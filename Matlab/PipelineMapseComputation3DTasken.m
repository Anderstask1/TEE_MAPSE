%Pipeline of automatic mapse computation from 3d TEE ultrasound data
%Started 31.08.2020
%Author: Anders Tasken

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear

addpath('dirParsing')
addpath('ecgDetect')
addpath('3d_data')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated_8files/'; %must match python script path

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%% Rotate volume around y axis from probe center
%rotate 3D ultrasound h5 file in folder along the probe axis
%and create slice every degree - save image of rotation
disp('Rotate volume around y axis');

%Rotate volume from start-angle to end-angle with degree step
startAngle = 80;
endAngle = 100;
stepDegree = 2;

%rotate 3d data
RotateVolumeYAxis3D(fileNames, startAngle, endAngle, stepDegree);

%% Save image from first frame of y-axis rotation
disp('Save image slice from volume rotated around y axis');
   
SaveSliceImageHdf(fileNames, 'RotatedVolumes');

%% Run python script with DNN model finding MAPSE landmarks in all y-axis rotated
% slices from volumes in folder

disp('Run DNN model to find MAPSE landmarks in y-axis rotated slices (python)');

% p.s. conda environment must be activated on matlab launch: 
% conda activate TEE_MAPSE
% matlab
system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py RotatedVolumes %s', filesPath));

%% Save image of y-axis rotated slices with landmarks
disp('Save images of y-axis rotated slices with landmarks');

SaveSliceImageWithLandmarksHdf(fileNames, 'RotatedVolumes');

%% Find optimal angle for mitral valve center computation
disp('Find optimal y-axis rotation angle');

%optimal angle = rotation angle with mapse landmarks furthest apart
OptimalMapseAngles(fileNames, filesPath);

%% Rotate around mv center
disp('Rotate volume around MV center');

%Rotate volume from start-angle to end-angle with degree step
startAngle = 0;
endAngle = 360;
stepDegree = 10;

RotateAndSliceMitralValveCenter(fileNames, startAngle, endAngle, stepDegree);

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
system(sprintf('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py MVCenterRotatedVolumes %s', filesPath));

%% Save image of mv-center rotated slices with landmarks
disp('Save images of mv center rotated slices with landmarks');

SaveSliceImageWithLandmarksHdf(fileNames, 'MVCenterRotatedVolumes');

%% MAPSE processing

disp('Compute MAPSE values (plot mapse curve) (annulus render)');

[mapse_raw_left_map, mapse_raw_right_map, mapse_bezier_left_map, mapse_bezier_right_map] = PostProcessMapse3D(fileNames, 1); %save slice bool, save annulus bool

%% Show and save MAPSE results
disp('Save MAPSE value results in table as a text file')

%keys and values
% left_keys = keys(mapse_raw_left_map);
% left_raw_values = values(mapse_raw_left_map);
% left_bezier_values = values(mapse_bezier_left_map);
% right_keys = keys(mapse_raw_right_map);
% right_raw_values = values(mapse_raw_right_map);
% right_bezier_values = values(mapse_bezier_right_map);

%Save results as txt file table
resultsName = strcat(filesPath, 'MAPSE-values', '.txt');
fileID = fopen(resultsName,'w');

%left -raw landmark values
fprintf(fileID,'%s\n', 'MAPSE left values from raw landmarks');

for key = keys(mapse_raw_left_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_raw_left_map(key{1})*1000);
end

%right -raw landmark values
fprintf(fileID,'\n\n%s\n', 'MAPSE right values from raw landmarks');

for key = keys(mapse_raw_right_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_raw_right_map(key{1})*1000);
end

%left -bezier interpolation values
fprintf(fileID,'\n\n\n\n%s\n', 'MAPSE left values from Bezier interpolation');

for key = keys(mapse_bezier_left_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_bezier_left_map(key{1})*1000);
end


%right -bezier interpolation values
fprintf(fileID,'\n\n%s\n', 'MAPSE right values from Bezier interpolation');

for key = keys(mapse_bezier_right_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_bezier_right_map(key{1})*1000);
end

fclose(fileID);

%% Show one type of plot from all files
disp('Show selected plots')

% Chose one of the following
% _frame_1_scatterplot3D.fig - _frame_1_lineplot3D.fig -
% _frame_1_lineplot3D_with_slices.fig - _lineplot3D_all_frames.fig
% _frame_1_spline_interpolation-plot3D.fig - _frame_1_spline_interpolation-plot3D_with_slices.fig
% _spline_interpolation-plot3D_left_all-frames.fig - _spline_interpolation-plot3D_right_all-frames.fig
% _frame_1_bezier_interpolation_3D_with_slices - J65BP22K_frame_1_bezier_interpolation_3D
plotnames = {'_frame_1_lineplot3D_with_slices.fig', '_frame_1_bezier_interpolation_3D_with_slices'};

%call the script for each plot
for i = 1 : length(plotnames)
    %call the script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);
        figname = strcat(path, 'PostProcessMVAnnulusFigures/', name, '/', name, plotnames{i});
        openfig(figname, 'visible');
    end
end
