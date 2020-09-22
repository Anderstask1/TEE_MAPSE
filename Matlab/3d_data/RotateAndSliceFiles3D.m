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
    
    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    % Rotate from 60 degrees to 120 degrees (since 3d scan is within this range), with 5 degree step
    for i = 80:1:90
        %show progress
        fprintf('Extracting slice that is rotated %d degrees. \n',i)
        
        %rotate 3d data
        RotateVolumeYAxis3D(path, name, i, 0);
    end
end