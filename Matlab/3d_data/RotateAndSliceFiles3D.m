%rotate 3D ultrasound h5 file in folder along the probe axis 180 degrees
%and create slice every 5th degree
%Started 31.08.2020
%Author: Anders Tasken
function RotateAndSliceFiles3D()

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);
    rootName = [path '/' name];
    
    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    % Rotate 180 degrees with 5 degree step
    for i = 0:10:180
        %show progress
        fprintf('Extracting slice that is rotated %d degrees. \n',i)
        
        %rotate 3d data
        RotateFileAndSaveSlice3D(rootName, i, 0);
    end
end