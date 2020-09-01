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
%dirInMAPSE = 'h:\AndreasSelectedMapse\';
dirInMAPSE = 'h:\AndreasSelectedConvertedSplitMapseLen3\';
%typical filename
xlsfile = 'd:\MAPSE_dl_len3.xls';

dirInStrain = 'h:\AndreasSelectedConvertedSplitStrain_ID5\';
xlsfile = 'd:\Strain_ID5.xls';

%PostProcessMapseRecording('h:\AndreasSelectedMapse\/KWA17_95_3', xlsfile, 1, 1, 1); %1 1 1 save movie, figure and xls

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %MAPSE processing
% 
% %find all dcm files
% fileNamesMapse = parseDirectory (dirInMAPSE, 1, '.h5');
% 
% 
% %call the MAPSE postprocessing script for each file
% for f=1:size(fileNamesMapse,2)
%     %root name from h5 file
%     [path, name, ext] = fileparts(fileNamesMapse(f).name);
%     rootName = [path '/' name];
% 
%     %post process the file
%     PostProcessMapseRecording(rootName, xlsfile, 1, 1, 1); %1 1 1 save movie, figure and xls
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Strain processing

%find all dcm files
fileNamesStrain = parseDirectory (dirInStrain, 1, '.h5');

%call the strain post-processing script for each file
for f=1:size(fileNamesStrain,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNamesStrain(f).name);
    rootName = [path '/' name];

    %post process the file
    PostProcessStrainRecording(rootName, xlsfile, 1, 1, 1); %1 1 1 save movie, figure and xls
end



