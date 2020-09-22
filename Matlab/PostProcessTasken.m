%NOTE: MAPSE processing should happen before the strain part

close all
clear all 

addpath('dirParsing')
addpath('ecgDetect')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAPSE processing

%input folders for MAPSE and Strain results which were parsen by deep learning
dirInMAPSE = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

%typical filename
xlsfile = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test2/MAPSE_dl_len3.xls';

%find all dcm files
fileNamesMapse = parseDirectoryLinux(dirInMAPSE, 1, '.h5');

%create folder for images and videos
directoryPath = strcat(dirInMAPSE, 'PostProcessMapseRecordings/');
mkdir(directoryPath);

%call the MAPSE postprocessing script for each file
for f=1:size(fileNamesMapse,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNamesMapse(f).name);
    
    %post process the file
    PostProcessMapseRecording3D(name, path, directoryPath, xlsfile, 1, 1, 0); % save movie and figure, no xls on linux
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Strain processing
% 
% dirInStrain = 'h:\AndreasSelectedConvertedSplitStrain_ID5\';
% xlsfile = 'd:\Strain_ID5.xls';
% 
% 
% %find all dcm files
% fileNamesStrain = parseDirectory (dirInStrain, 1, '.h5');
% 
% %call the strain post-processing script for each file
% for f=1:size(fileNamesStrain,2)
%     %root name from h5 file
%     [path, name, ext] = fileparts(fileNamesStrain(f).name);
%     rootName = [path '/' name];
% 
%     %post process the file
%     PostProcessStrainRecording(rootName, xlsfile, 1, 1, 0); % save movie and figure, no xls on linux
% end

