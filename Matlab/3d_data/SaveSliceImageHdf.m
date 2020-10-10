%Plot sliced 2d TEE data from hdf-file, only 1 image per sequence
%Started 04.09.2020
%Author: Anders Tasken
function SaveSliceImageHdf(path, name, fieldName)
    
    inputName = [path name];

    %load data
    data = HdfImport(inputName);

    %create folder for images
    %directoryPath = strcat(filesPath, '/SlicedImages_MVCenter_', name, '/');
    directoryPath = strcat(path, '/PreProcessSlicedImages_', fieldName, '/');
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