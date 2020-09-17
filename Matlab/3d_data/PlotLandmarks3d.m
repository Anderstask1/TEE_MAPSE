%Visualization and plot of landmarks from 3d data
%Author: Anders Tasken
%Started 16.09.2020
function PlotLandmarks3d

    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %call the split script for each file
    for f=1:size(fileNames,2)
        
        %root name from h5 file
        [path, name, ext] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        hdfdata = HdfImport(filePath);
        
        %get all fields from data struct
        fields = fieldnames(hdfdata.RotatedVolumes);
        
        %store all landmark points in matrix
        mapseLandmarksMatrix = zeros(360, 4, 11);

        %iterate over all fields
        for i = 1 : numel(fields)

            %get landmark data - position for left and right landmark for all
            %images in sequence (11 x 4 matrix)
            mapseLandmarks = hdfdata.RotatedVolumes.(fields{i}).MAPSE_detected_landmarks;
            
            mapseLandmarksMatrix(f,:,:) = mapseLandmarks;
        end
        
        mapseLandmarksMatrix(isnan(mapseLandmarksMatrix)) = 0;
        
        x_left = squeeze(mapseLandmarksMatrix(1,1,:));
        y_left = squeeze(mapseLandmarksMatrix(1,2,:));
        
        x_right = squeeze(mapseLandmarksMatrix(1,3,:));
        y_right = squeeze(mapseLandmarksMatrix(1,4,:));
        
        x = squeeze([x_left; x_right]);
        y = squeeze([y_left; y_right]);
        
        scatter(x, y)
    end
end