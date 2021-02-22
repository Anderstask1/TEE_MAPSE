%Convert 3d data rotated around mv center to 2d structure
%Started 4.02.2021
%Author: Anders Tasken

function Convert3dHdf5StructureTo2dStructure(fileNames, outPath) 

    %filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentAnnotatingData/';
    %outPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/';

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

            %filename
            outName = strcat(outPath, name, '_', fieldNames{i}, '.h5');

            %save file
            HdfExport(outName, newData);

        end

    end
end