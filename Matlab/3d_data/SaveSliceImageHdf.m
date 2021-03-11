%Plot sliced 2d TEE data from hdf-file, only 1 image per sequence
%Started 04.09.2020
%Author: Anders Tasken
function SaveSliceImageHdf(fileNames, fieldName, startAngle, endAngle, stepDegree)

    %call the split script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %show progress
        fprintf('Extracting slices from file with name: %s. \n', name);

        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);

        %create folder for images
        %directoryPath = strcat(filesPath, '/SlicedImages_MVCenter_', name, '/');
        directoryPath = strcat(path, '/PreProcessSlicedImages_', fieldName, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %create folder for images
        %directoryPath = strcat(filesPath, '/SlicedImages_MVCenter_', name, '/');
        directoryPath = strcat(directoryPath, name, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end
        
        %{
        %check if volume is rotated
        info = h5info(filePath);
        if ~any(strcmp({info.Groups.Name}, '/RotatedXVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        end
        
        %
        optMapseAngle = -1;
        
        if strcmp(fieldName, 'MVCenterRotatedVolumes')
            %load optMapseAngles
            filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
            optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;           
        end
        
        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        %}

        % Rotate given degrees
        for angle = startAngle : stepDegree : endAngle
        
            %get field data
            fn = strcat('rotated_by_', int2str(angle),'_degrees');
            ds = strcat('/', fieldName, '/', fn, '/images');
            fieldData =  h5read(filePath, ds);

            %get image, remove dimension of length 1
            slice = squeeze(fieldData(:,:,1));

            %save image
            fileName = strcat(directoryPath, name, '_', string(angle), '.png');
            imwrite(slice, gray, fileName);

        end
    end
end