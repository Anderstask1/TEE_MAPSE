%rotate a 3D ultrasound h5 file along the probe axis by a predefined
%amount, and save slice of 3d volume in sequence array
%Started 31.08.2020, Anders Tasken 
function RotateFileAndSaveSlice3D(inputName, angle, rotationPoint,visualDebug)
    %load data
    data = HdfImport(inputName);

    %number of frames
    frameNo = length(fieldnames(data.CartesianVolumes));

    %volumetric data
    vol1 = data.CartesianVolumes.vol01;
    boundingBox = imref3d(size(vol1));
    sz =size(vol1);
   
    %rotation point in center of MV
    translateM_z = [
          1 0 0 rotationPoint(1)
          0 1 0 rotationPoint(2)
          0 0 1 rotationPoint(3)
          0 0 0 1
        ];
    
    %rotation 
    theta = deg2rad(angle);

    %rotate around a line perpendicular to MV
    rotateM_y = [
        cos(theta)  0  sin(theta)  0
        0           1  0           0
        -sin(theta) 0  cos(theta)  0  
        0           0  0           1
        ];
    
    %rotation around an arbitrary point = moving rotation point to origin,
    %rotation around origin and moving back to original position
    trf = translateM_z*rotateM_y*inv(translateM_z); 
    tform = affine3d(trf');
     
    %matrix of 2d slices for sequence
    %allocate
    imageData = data.CartesianVolumes.('vol01');
    slices = zeros(size(imageData, 1), size(imageData, 3), frameNo);   
    
    for f = 1:frameNo
        %get the 3D frame
        volName = sprintf('vol%02d', f);
        imageData = data.CartesianVolumes.(volName);
        
        %rotate volume
        processedData = uint8(imwarp(imageData, tform, 'OutputView',boundingBox));
        
        %get slize from 3D frame
        slices(:,:,f) = squeeze(processedData(:,round(end*0.5),:));
    end
  
    %delete field if there from beforehand
    if angle == 0
        if isfield(data, 'RotatedVolumes')
            data = rmfield(data, 'RotatedVolumes');
        end
    end
        
    %save slice sequence to .h5 file
    fieldName = strcat('rotated_by_', int2str(angle),'_degrees');
    data.RotatedVolumes.(fieldName).images = slices;
    
    %plot if enabled
    if visualDebug
        slices = data.images;
        
        figure
        slice = slices(1);
        
        subplot(2,1,1), imshow(slice, [0 255])
    end         
    
    %new filename
    outName = strcat(inputName,'.h5');
    
    HdfExport(outName, data);