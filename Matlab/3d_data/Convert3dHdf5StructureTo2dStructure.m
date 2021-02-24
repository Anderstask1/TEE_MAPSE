%Convert 3d data rotated around mv center to 2d structure
%Started 4.02.2021
%Author: Anders Tasken

addpath('../dirParsing')
addpath('../3d_data')

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/ConvertAnnotated3dTo2dStructure/';
outPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Converting: %d/%d. \n', f, size(fileNames,2));

    % Load data
    inputName = [path name];

    data = HdfImport(inputName);

    fieldNames = fieldnames(data.MVCenterRotatedVolumes);

    newData = struct();

    for i = 1 : length(fieldNames)

        images = data.MVCenterRotatedVolumes.(fieldNames{i}).images;

        %images = permute(images, [3 1 2]);

        newData.images = images;
        
        reference = data.Annotations.(fieldNames{i}).reference;

        %filename
        outName = strcat(outPath, name, '_', fieldNames{i}, '.h5');

        %save file
        HdfExport(outName, newData);

    end

end