%Visualization of Gaussian weight annotation
%Started 15.02.2021
%Author: Anders Tasken

addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab')
addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab/dirParsing')

folderPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/gaussian/train/';

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

weights = zeros(3, 37);

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);
    
    if contains(name, 'J44J730I')

        % Load data
        inputName = [path name];
        
        data = HdfImport(inputName);
        
        nameSplit = split(name, '_');
        
        rotation = str2num(nameSplit{4});

        if rotation ~= 0
            weights(:,rotation/10) = data.reference(:,1);
        end
    end
end

