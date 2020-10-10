%Find rotation around y-axis angle resulting in slice in center of Mitral
%Valve. Should be the slice where the distance between the left and right
%landmarks is biggest
%Author: Anders Tasken
%Started 07.10.2020
function angle = OptimalMapseAngles(path, name)
    
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
                fieldName = fields{i}
                angleCell = regexp(fieldName,'\d*','Match');
                angleString = angleCell{1};
                angle = str2num(angleString);
            end
        end
    end
end