%Plot sliced 2d TEE data from hdf-file, only 1 image per sequence
%Started 04.09.2020
%Author: Anders Tasken
function SaveSliceImageHdf()

    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    fieldName = 'RotatedVolumes';
    %fieldName = 'MVCenterRotatedVolumes';
    
    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %call the split script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ext] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        data = HdfImport(filePath);

        %create folder for images
        %directoryPath = strcat(filesPath, '/SlicedImages_MVCenter_', name, '/');
        directoryPath = strcat(filesPath, '/SlicedImages_', name, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %get all fields from data struct
        fields = fieldnames(data.(fieldName));

        %iterate over all fields
        for i = 1 : numel(fields)

            %get field data
            fieldData = data.(fieldName).(fields{i}).images;

            %get image, remove dimension of length 1
            slice = squeeze(fieldData(:,:,1));

            %save image
            fileName = strcat(directoryPath,name,'_',string(fields(i)),'.png');
            imwrite(slice, gray, fileName);

        end
    end
end