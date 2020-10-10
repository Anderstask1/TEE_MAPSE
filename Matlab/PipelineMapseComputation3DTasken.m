%Pipeline of automatic mapse computation from 3d TEE ultrasound data
%Started 31.08.2020
%Author: Anders Tasken

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all

addpath('dirParsing')
addpath('ecgDetect')
addpath('3d_data')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Rotate volume around y axis from probe center
%rotate 3D ultrasound h5 file in folder along the probe axis
%and create slice every degree - save image of rotation
disp('Rotate volume around y axis');

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    %rotate 3d data
    RotateVolumeYAxis3D(path, name);
        
    % Save image from first frame of y-axis rotation
    SaveSliceImageHdf(path, name, 'RotatedVolumes');
end

%% Run python script with DNN model finding MAPSE landmarks in all y-axis rotated
% slices from volumes in folder

disp('Run DNN model to find MAPSE landmarks in y-axis rotated slices (python)');

% p.s. conda environment must be activated on matlab launch: 
% conda activate TEE_MAPSE
% matlab
system('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py RotatedVolumes');

%% Save image of y-axis rotated slices with landmarks
disp('Save images of y-axis rotated slices with landmarks');

SaveSliceImageWithLandmarksHdf(path, name, 'RotatedVolumes');

%% Find optimal angle for mitral valve center computation
disp('Find optimal y-axis rotation angle');

%one angle for each file
optMapseAngles = zeros(size(fileNames,2), 1)';

%for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    %optimal angle = rotation angle with mapse landmarks furthest apart
    optMapseAngles(f) = OptimalMapseAngles(path, name);
end

%% Rotate around mv center
disp('Rotate volume around MV center');

RotateAndSliceMitralValveCenter(optMapseAngles, filesPath);

%% Save images of mv center rotation
disp('Save images of slices rotated around MV center');

for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Loaded file with name: %s. \n', name);
        
    %save image
    SaveSliceImageHdf(path, name, 'MVCenterRotatedVolumes');
end

%% Run python script with DNN model finding MAPSE landmarks in all mv-center rotated
% slices from volumes in folder

disp('Run DNN model to find MAPSE landmarks in MV center rotated slices (python)');

% p.s. conda environment must be activated on matlab launch: 
% conda activate TEE_MAPSE
% matlab
system('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py MVCenterRotatedVolumes');

%% Save image of mv-center rotated slices with landmarks
disp('Save images of mv center rotated slices with landmarks');

SaveSliceImageWithLandmarksHdf(path, name, 'MVCenterRotatedVolumes');

%% MAPSE processing

disp('Compute MAPSE values (plot mapse curve) (annulus render)');

%save mapse values in m
mapse_left_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
mapse_right_map = containers.Map('KeyType', 'char', 'ValueType', 'double');

%call the MAPSE postprocessing script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);
    
    %post process the file - add mapse value and file name to map
    [mapse_left_map(name), mapse_right_map(name)] = PostProcessMapse3D(name, path, 0, 1); %save slice bool, save annulus bool

end

%% Show and save MAPSE results
disp('Save MAPSE value results in table as a text file')

%keys and values
left_keys = keys(mapse_left_map);
left_values = values(mapse_left_map);
right_keys = keys(mapse_right_map);
right_values = values(mapse_right_map);

%Save results as txt file table
resultsName = strcat(filesPath, 'MAPSE-values', '.txt');
fileID = fopen(resultsName,'w');

%left
fprintf(fileID,'%s\n', 'MAPSE left values');

for key = keys(mapse_left_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_left_map(name)*1000);
end


%right
fprintf(fileID,'\n\n%s\n', 'MAPSE right values');

for key = keys(mapse_right_map)
    fprintf(fileID,'%s: %f mm\n', key{1}, mapse_right_map(name)*1000);
end

fclose(fileID);
