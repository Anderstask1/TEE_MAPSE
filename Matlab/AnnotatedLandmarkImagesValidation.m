%Validate annotations on all files in specified folder by images
%Author: Anders Tasken
%Started 05.11.2020

addpath('dirParsing')
addpath('3d_data')

%set colors
blueColor = [0, 0.4470, 0.7410];
orangeColor = [0.8500, 0.3250, 0.0980];
yellowColor = [0.9290, 0.6940, 0.1250];
greenColor = [0.4660, 0.6740, 0.1880];

%filesPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotatedTrainingData/';
filesPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotateProcessingFiles/AnnotatedCorrectionFiles/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%create folder for images
directoryPath = strcat(filesPath, 'AnnotatedLandmarkImages/');
if ~exist(directoryPath, 'dir')
    % Folder does not exist so create it.
    mkdir(directoryPath);
end

%call the split script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %show progress
    fprintf('File: %d / %d \n', f, size(fileNames,2));

    %% Load data
    inputName = [path name];

    %load data
    hdfdata = HdfImport(inputName);

    %get field data
    fieldData = hdfdata.images;
    
    %get mapse landmarks coordinates, left landmark: x-y, right landmark
    %x-y, for all frames
    annotatedLandmarks = hdfdata.reference';

    %iterate over all frames
    for i = 1 : size(fieldData, 3)

        %get image from frame in sequence, remove dimension of length 1
        slice = squeeze(fieldData(:,:,i));

        %plot image
        fig = figure('Visible', 'off');
        imshow(slice, [0 255]); hold on

        %plot annotated landmarks
        if ~isnan(annotatedLandmarks(1,1))
            plot(annotatedLandmarks(i,2), annotatedLandmarks(i,1), 'o', 'LineWidth', 1, 'Color', yellowColor);
        end
        if ~isnan(annotatedLandmarks(1,3))
            plot(annotatedLandmarks(i,4), annotatedLandmarks(i,3), 'o', 'LineWidth', 1, 'Color', greenColor);
        end

        hold off

        %save image
        fileName = strcat(directoryPath, name,'_frame:',int2str(i),'.png');
        saveas(fig, fileName);
    end
end