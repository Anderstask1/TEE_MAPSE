%rotate 3D ultrasound h5 file in folder along the probe axis
%and create slice every degree - save image of rotation
%Started 31.08.2020
%Author: Anders Tasken

%Rotate volume from start-angle to end-angle with 1 degree step
startAngle = 60;
endAngle = 120;

filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    % Rotate given degrees (since 3d scan is within this range), with 5 degree step
    for i = startAngle:1:endAngle
        %show progress
        fprintf('Extracting slice that is rotated %d degrees. \n',i)

        %rotate 3d data
        RotateVolumeYAxis3D(path, name, i, startAngle);
        
    end
    
    %save image from first frame of rotation
    SaveSliceImageHdf(path, name, 'RotatedVolumes');
end

%% Run python script with DNN model finding MAPSE landmarks in all rotated
% slices from volumes in folder
% p.s. conda environment must be activated on matlab launch: 
% conda activate TEE_MAPSE
% matlab
system('python /home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/dl_mapse/Code/pipeline3D.py RotatedVolumes');

%% Save image of rotated slices with landmarks
SaveSliceImageWithLandmarksHdf(path,  name, 'RotatedVolumes');

%% Find optimal angle for mitral valve center computation
%one angle for each file
optMapseAngles = zeros(size(fileNames,2));

%for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Loaded file with name: %s. \n', name);

    %optimal angle = rotation angle with mapse landmarks furthest apart
    optMapseAngles(f) = OptimalMapseAngles(path, name);
end