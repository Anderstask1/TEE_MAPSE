%Postprocess the deep learning results for Andreas
%Author: gkiss
%Started 07.2020
%NOTE: MAPSE processing should happen before the strain part

close all
clear all 

addpath('dirParsing')
addpath('ecgDetect')

%input folders for MAPSE and Strain results which were parsen by deep learning
dirIn = 'h:\AndreasSelectedConverted\';
dirOut = 'h:\AndreasSelectedConvertedSplit\';

%find all .h5 files
fileNamesMapse = parseDirectory (dirIn, 1, '.h5');

%in case the ECG detector does not see the last cycle
minImageFrames = 20;

%call the split script for each file
for f=1:size(fileNamesMapse,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNamesMapse(f).name);
    rootName = [path '/' name];

    %split the file
    SplitRecordingIntoHeartCycles(rootName, dirOut, minImageFrames);
end


%debug
%hdfData = HdfImport('h:\AndreasSelectedConvertedSplit\KWA22_62_4.h5');
%figure
%imshow(squeeze(hdfData.tissue.data(1,:,:)),[0 255])
%SplitRecordingIntoHeartCycles('h:\AndreasSelectedConverted\/KWA17_95', dirOut, minImageFrames)

