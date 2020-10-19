%Save slice as image
%Author: Anders Tasken
%Started 05.10.2020
function SaveSliceImageWithLandmarksHdf(fileNames, fieldName)

    %call the split script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %show progress
        fprintf('Save image with landmarks from file with name: %s. \n', name);

        %% Load data
        inputName = [path name];

        %load data
        hdfdata = HdfImport(inputName);

        %get all fields from data struct
        fields = fieldnames(hdfdata.(fieldName));

        %create folder for images
        directoryPath = strcat(path, 'PostProcessMapseImages_', fieldName, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %create folder for current file
        directoryPath = strcat(directoryPath, name, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end

        %iterate over all fields
        for i = 1 : numel(fields)

            %get field data
            fieldData = hdfdata.(fieldName).(fields{i}).images;

            %get mapse landmarks coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.(fieldName).(fields{i}).MAPSE_detected_landmarks';

            %get image from first frame in sequence, remove dimension of length 1
            slice = squeeze(fieldData(:,:,1)');

            %plot image
            fig = figure('Visible', 'off');
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

            %save image
            fileName = strcat(directoryPath, name,'_',string(fields(i)),'.png');
            saveas(fig, fileName);
        end
    end
end