% Plot sliced 2d TEE data from hdf-file, only 1 image per sequence
%Started 04.09.2020
%Author: Anders Tasken
function SaveSliceImageHdf()

    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/3d_rotated_and_slized_ultrasounds_data_test/';
    
    hdfFileName = 'J44J71A4.h5';

    %load data
    filePath = strcat(filesPath, hdfFileName);
    data = HdfImport(filePath);
    
    %get all fields from data struct
    fields = fieldnames(data);
    
    %iterate over all fields
    for i = 1 : numel(fields)
        
        %check if field is of rotated sliced image
        if contains(fields(i), 'rotated_by_')
            
            %get field data
            fieldData = data.(fields{i});
            
            %get image, remove dimension of length 1
            slice = squeeze(fieldData(1,:,:));
     
            fileName = strcat(filesPath,string(fields(i)),'.png');
            
            %save image
            imwrite(slice, gray, fileName);
            
        end
    end
end