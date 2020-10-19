%Find rotation around y-axis angle resulting in slice in center of Mitral
%Valve. Should be the slice where the distance between the left and right
%landmarks is biggest
%Author: Anders Tasken
%Started 07.10.2020
function optMapseAngles= OptimalMapseAngles(fileNames, filesPath)

    %for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

        %show progress
        fprintf('Loaded file with name: %s. \n', name);

        %default angle value
        angle = 0;

        %highest found distance
        bestDistance = 0;

        inputName = [path name];

        %load data
        hdfdata = HdfImport(inputName);

        %get all fields from data struct
        fields = fieldnames(hdfdata.RotatedVolumes);

        %number of frames
        frameNo = length(fieldnames(hdfdata.RotatedVolumes));

        %iterate over all rotations
        for i = 1:frameNo
            %get field data. left landmark (x,y) - right landmark (x,y)
            %all frames, only interested in first frame = first row
            mapseLandmarks = hdfdata.RotatedVolumes.(fields{i}).MAPSE_detected_landmarks';

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
                    fieldName = fields{i};
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