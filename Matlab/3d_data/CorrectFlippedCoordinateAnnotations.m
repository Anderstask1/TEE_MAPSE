%Correct flipped coordinates of annotations
%Anders Tasken
%19.11. 2020

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotatedTrainingData/train/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

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
    
    reference = hdfdata.reference;
    
    reference([1 2 3 4], :) = reference([2 1 4 3], :);
    
    h5name = strcat(path, name, '.h5');
    h5write(h5name, '/reference', reference);
end
