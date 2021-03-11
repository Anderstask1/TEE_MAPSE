%Find rotation around y-axis angle resulting in slice in center of Mitral
%Valve. Should be the slice where the distance between the left and right
%landmarks is biggest
%Author: Anders Tasken
%Started 07.10.2020
function OptimalMapseAngles(fileNames, filesPath, startAngle, endAngle, stepDegree)

    %for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %show progress
        fprintf('Loaded file with name: %s. \n', name);

        %default angle value
        optMapseAngle = 0;

        %highest found distance
        bestDistance = 0;

        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        
        info = h5info(filePath);
        if ~any(strcmp({info.Groups.Name}, '/RotatedXVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        end

        %iterate over all rotations
        for angle = startAngle : stepDegree : endAngle
            
            fieldName = strcat('rotated_by_', int2str(angle),'_degrees');
            ds = strcat('/RotatedYVolumes/', fieldName, '/MAPSE_detected_landmarks');
            mapseLandmarks = h5read(filePath, ds)';

            %need both left and right landmark
            if ~isnan(mapseLandmarks(1,:))
                %save landmarks as matrix
                x = [mapseLandmarks(1,1), mapseLandmarks(1,2); mapseLandmarks(1,3), mapseLandmarks(1,4)];

                %compute distance between landmarks
                distance = pdist(x,'euclidean');

                %check if distance is biggest
                if distance > bestDistance
                    %save distance
                    bestDistance = distance;

                    %save angle -parsing from fieldName
                    angleCell = regexp(fieldName,'\d*','Match');
                    angleString = angleCell{1};
                    optMapseAngle = str2num(angleString);
                end
            end
        end
        
        fprintf('Optimal angle for file %s is %d \n', name, optMapseAngle);
        
        %save variable
        %create folder for matlab variables
        directoryPath = strcat(filesPath, 'Optimal_angle_mv-center-computation/');
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
        
        filename = strcat(directoryPath, 'optMapseAngle');
        save(filename, 'optMapseAngle');
        
    end
end