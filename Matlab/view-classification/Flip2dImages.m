%Flip 2d annotated images for training, to make model handle flipped images
%Started 10.02.2021
%Author: Anders Tasken

%filesPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/train/';
%filesPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/val/';
filesPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/';

outPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/';

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
    
    images = data.images;
    
    flippedImages = flipdim(images, 1);
    
    data.images = flippedImages;
    
    %filename
    outName = strcat(outPath, name, '_flipped.h5');

    %save file
    HdfExport(outName, data);
end