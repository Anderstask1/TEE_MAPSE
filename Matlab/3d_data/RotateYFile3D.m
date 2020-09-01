%rotate a 3D ultrasound h5 file along the probe axis by a predefined amount
%Started 05.2020, Gabriel Kiss
function RotateYFile3D(inputName, outputName, angle, visualDebug)
    %load data
    data = HdfImport(inputName);

    %number of frames
    frameNo = length(fieldnames(data.CartesianVolumes));

    vol1 = data.CartesianVolumes.vol01;
    boundingBox = imref3d(size(vol1));
    sz =size(vol1);
    translateM = [1 0 0 0
          0 1 0 -sz(1)/2
          0 0 1 -sz(3)/2
          0 0 0 1
        ];

    theta = deg2rad(angle);

    rotateM = [1 0 0 0
         0   cos(theta)   -sin(theta) 0  
         0 sin(theta)    cos(theta) 0  
         0             0              0     1];

    trf = inv(translateM)*rotateM*translateM; 
    tform = affine3d(trf');

    for f = 1:frameNo
        %get the 3D frame
        volName = sprintf('vol%02d', f);
        imageData = data.CartesianVolumes.(volName);   

        %rotate volume
        processedData = uint8(imwarp(imageData, tform, 'OutputView',boundingBox));
        data.CartesianVolumes.(volName) = processedData;
        
    end
    
    %plot if enabled
    if visualDebug
        imageData = data.CartesianVolumes.vol01;
        
        figure
        slice = squeeze(imageData(:,round(end*0.33),:));
        sliceOrigo = squeeze(vol1(:,round(end*0.33),:));
        
        subplot(2,1,1), imshow(sliceOrigo, [0 255])
        subplot(2,1,2), imshow(slice, [0 255])
    end         
    
    HdfExport(outputName, data);
