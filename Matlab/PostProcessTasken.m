%NOTE: MAPSE processing should happen before the strain part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all 

addpath('dirParsing')
addpath('ecgDetect')
addpath('3d_data')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAPSE processing

%input folders for MAPSE and Strain results which were parsen by deep learning
dirInMAPSE = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated_2files/';

%find all .h5 files
fileNamesMapse = parseDirectoryLinux(dirInMAPSE, 1, '.h5');

%save mapse values in matrix
mapse_left_matrix = zeros(size(fileNamesMapse,2), 1);
mapse_right_matrix = zeros(size(fileNamesMapse,2), 1);

%call the MAPSE postprocessing script for each file
for f=1:size(fileNamesMapse,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNamesMapse(f).name);
    
    %post process the file
    [mapse_left_matrix(f), mapse_right_matrix(f)] = PostProcessMapse3D(name, path, mapse_left_matrix, mapse_right_matrix, 0, 1); %save slice bool, save annulus bool
end

disp(mapse_left_matrix);
disp(mapse_right_matrix);

