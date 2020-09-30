%Postprocess the deep learning results for MAPSE - single frame
%Author: Anders Tasken
%Started 18.09.2020

function PostProcessMapseImage3D(fileName, pathName, directoryPath, xlsfile, saveTrackingMovie, saveTrackingPlot, saveXls)
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    fieldName = 'RotatedVolumes';
    %fieldName = 'MVCenterRotatedVolumes';
    
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

        %create folder for images
        directoryPath = strcat(filesPath, 'PostProcessMapseImage', '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %get all fields from data struct
        fields = fieldnames(hdfdata.(fieldName));

        %iterate over all fields
        for i = 1 : numel(fields)

            %get field data
            fieldData = hdfdata.(fieldName).(fields{i}).images;

            %get image from first frame in sequence, remove dimension of length 1
            slice = squeeze(fieldData(:,:,1)');
            
            %get mapse landmarks coordinates
            mapseLandmarks = hdfdata.(fieldName).(fields{i}).MAPSE_detected_landmarks';
            
            imshow(slice, [0 255]);
        
            hold on
    
            %plot landmarks (left and right)
            if ~isnan(mapseLandmarks(1,1))
                plot(mapseLandmarks(1,1), mapseLandmarks(1,2), 'gx', 'LineWidth', 2);
            end
            if ~isnan(mapseLandmarks(1,3))
                plot(mapseLandmarks(1,3), mapseLandmarks(1,4), 'bx', 'LineWidth', 2);
            end

            hold off

            drawnow
            
            %save image
            fileName = strcat(directoryPath, name,'_',string(fields(i)),'.png');
            saveas(gcf, fileName);

        end
    end
end