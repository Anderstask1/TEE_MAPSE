%Save slice as image
%Author: Anders Tasken
%Started 05.10.2020
function SaveSliceImageWithLandmarksHdf(fileNames, fieldName)

    %set colors
    blueColor = [0, 0.4470, 0.7410];
    orangeColor = [0.8500, 0.3250, 0.0980];
    yellowColor = [0.9290, 0.6940, 0.1250];
    greenColor = [0.4660, 0.6740, 0.1880];

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
        
        optMapseAngle = -1;
        if strcmp(fieldName, 'MVCenterRotatedVolumes')
            %load optMapseAngles
            filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
            optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;
        end

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        
        %get all fields from data struct
        fields = fieldnames(hdfdata.(fieldName));

        %iterate over all fields
        for i = 1 : numel(fields)

            %get field data
            fieldData = hdfdata.(fieldName).(fields{i}).images;

            %get mapse landmarks coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.(fieldName).(fields{i}).MAPSE_detected_landmarks';
            
            %get annotated landmarks, if any
            isAnnotatedData = any(strcmp(fieldnames(hdfdata),'Annotations')) && strcmp(fieldName, 'MVCenterRotatedVolumes');
            annotatedLandmarks = zeros(size(mapseLandmarks));
            
            if isAnnotatedData
                annotatedLandmarks = hdfdata.Annotations.(fields{i}).ref_coord';
            end

            %get image from first frame in sequence, remove dimension of length 1
            slice = squeeze(fieldData(:,:,1)');

            %plot image
            fig = figure('Visible', 'off');
            imshow(slice, [0 255]);

            hold on

            %plot landmarks (left and right)
            if ~isnan(mapseLandmarks(1,1))
                plot(mapseLandmarks(1,1), mapseLandmarks(1,2), 'x', 'LineWidth', 2, 'Color', blueColor);
            end
            if ~isnan(mapseLandmarks(1,3))
                plot(mapseLandmarks(1,3), mapseLandmarks(1,4), 'x', 'LineWidth', 2, 'Color', orangeColor);
            end
            
            %plot annotated landmarks, if any
            if isAnnotatedData
                if ~isnan(annotatedLandmarks(1,1))
                    plot(annotatedLandmarks(1,2), annotatedLandmarks(1,1), 'o', 'LineWidth', 1, 'Color', yellowColor);
                end
                if ~isnan(annotatedLandmarks(1,3))
                    plot(annotatedLandmarks(1,4), annotatedLandmarks(1,3), 'o', 'LineWidth', 1, 'Color', greenColor);
                end
            end

            hold off

            %save image
            fileName = strcat(directoryPath, name,'_',string(fields(i)),'.png');
            saveas(fig, fileName);
        end
    end
end