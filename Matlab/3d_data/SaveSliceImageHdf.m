%Plot sliced 2d TEE data from hdf-file, only 1 image per sequence
%Started 04.09.2020
%Author: Anders Tasken
function SaveSliceImageHdf()

    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    hdfFileName = 'J44J71A4';

    %load data
    fileName = strcat(hdfFileName,'.h5'); 
    filePath = strcat(filesPath, fileName);
    data = HdfImport(filePath);
    
    %create folder for images
    directoryPath = strcat(filesPath, '/SlicedImages/');
    mkdir(directoryPath);
    
    %get all fields from data struct
    fields = fieldnames(data.RotatedVolumes);
    
    %iterate over all fields
    for i = 1 : numel(fields)
            
        %get field data
        fieldData = data.RotatedVolumes.(fields{i}).images;

        %get image, remove dimension of length 1
        slice = squeeze(fieldData(:,:,1));
        
        %save image
        fileName = strcat(directoryPath,hdfFileName,'_',string(fields(i)),'.png');
        imwrite(slice, gray, fileName);
            
    end
end