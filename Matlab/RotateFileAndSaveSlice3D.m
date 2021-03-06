%rotate a 3D ultrasound h5 file along the probe axis by a predefined
%amount, and save slice of 3d volume in sequence array
%Started 31.08.2020, Anders Tasken 
function RotateFileAndSaveSlice3D(inputName, outName, angle, visualDebug)
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
    
    %matrix of 2d slices for sequence
    %allocate
    imageData = data.CartesianVolumes.('vol01');
    slices = zeros(frameNo, size(imageData, 1), size(imageData, 3));   
 
    for f = 1:frameNo
        %get the 3D frame
        volName = sprintf('vol%02d', f);
        imageData = data.CartesianVolumes.(volName);   

        %rotate volume
        processedData = uint8(imwarp(imageData, tform, 'OutputView',boundingBox));
        data.CartesianVolumes.(volName) = processedData;
        
        %get slize from 3D frame
        slices(f,:,:) = squeeze(processedData(:,round(end*0.33),:));
    end
    
    %save slice sequence to .h5 file
    data.images = slices;
    
    %plot if enabled
    if visualDebug
        slices = data.images;
        
        figure
        slice = slices(1);
        
        subplot(2,1,1), imshow(slice, [0 255])
    end         
    
    HdfExport(outName, data);