%Visualization of Gaussian weight annotation
%Started 15.02.2021
%Author: Anders Tasken

addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab')
addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab/dirParsing')

folderPath = '/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/';

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);
    
    %show progress
    fprintf('Classified: %d/%d. \n', f, size(fileNames,2));

    % Load data
    inputName = [path name];

    data = HdfImport(inputName);

    fieldNames = fieldnames(data.Annotations);
    sortedFields = natsort(fieldNames);
    
    weights = zeros(1, length(fieldNames));
    
    for i = 1 : length(sortedFields)
       
        weights(i) = data.Annotations.(sortedFields{i}).reference;
        
    end
end