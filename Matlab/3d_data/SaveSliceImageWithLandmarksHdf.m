%Save slice as image
%Author: Anders Tasken
%Started 05.10.2020
function SaveSliceImageWithLandmarksHdf(path, name, fieldName)

    %% Load data
    inputName = [path name];

    %load data
    hdfdata = HdfImport(inputName);
    
    %get all fields from data struct
    fields = fieldnames(hdfdata.(fieldName));
    
    %iterate over all fields
    for i = 1 : numel(fields)
        
        %get field data
        fieldData = hdfdata.(fieldName).(fields{i}).images;
        
        %get mapse landmarks coordinates, left landmark: x-y, right landmark
        %x-y, for all frames
        mapseLandmarks = hdfdata.(fieldName).(fields{i}).MAPSE_detected_landmarks';

        %create folder for images
        directoryPath = strcat(path, 'PostProcessMapseImages_', fieldName, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %get image from first frame in sequence, remove dimension of length 1
        slice = squeeze(fieldData(:,:,1)');

        %plot image
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