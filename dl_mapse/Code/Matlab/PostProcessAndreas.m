%Postprocess the deep learning results for Andreas
%Author: gkiss
%Started 07.2020
%NOTE: MAPSE processing should happen before the strain part

close all
clear all 

addpath('dirParsing')
addpath('ecgDetect')

%input folders for MAPSE and Strain results which were parsen by deep learning
%dirInMAPSE = 'd:\dl\MAPSE\Data\test\';
dirInMAPSE = 'h:\AndreasSelectedMapse\';
dirInStrain = 'd:\dl\MAPSE\Data\test2\';

%typical filename
xlsfile = 'd:\MAPSE_dl_1.xls';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MAPSE processing

%find all dcm files
fileNamesMapse = parseDirectory (dirInMAPSE, 1, '.h5');


%call the MAPSE postprocessing script for each file
for f=1:size(fileNamesMapse,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNamesMapse(f).name);
    rootName = [path '/' name];

    %post process the file
    PostProcessMapseRecording(rootName, xlsfile, 1, 0, 1); %1 1 1 save movie, figure and xls
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Strain processing
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
%     PostProcessStrainRecording(rootName, xlsfile, 1, 1, 1); %1 1 1 save movie, figure and xls
% end



