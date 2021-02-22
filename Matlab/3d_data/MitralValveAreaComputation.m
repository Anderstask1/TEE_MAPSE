%Compute area of mitral valve from scatterpoints of annulus
%Author: Anders Tasken
%Started 19.02.2021
function MitralValveAreaComputation(fileNames, cardiac_view)

    %call the MAPSE postprocessing script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [filesPath, name, ~] = fileparts(fileNames(f).name);

        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        hdfdata = HdfImport(filePath);
        
        %default voxelsize value
        pixelCorr = 0.7e-3;

        %check if voxeldize is in hdfdata
        if any(strcmp(fieldnames(hdfdata),'a'))
            pixelCorr = hdfdata.ImageGeometry.voxelsize;
        end

        %load optMapseAngles
        filename = strcat(filesPath, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
        optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        
        % Load landmark variable matrices
        variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/landmarkMatrices_', cardiac_view, '_', name);
        
        load(variablesFilename,...
            'leftLandmarkSplineCurve', 'rightLandmarkSplineCurve', 'annotatedLeftSplineCurve', 'annotatedRightSplineCurve',...
            'leftLandmarkBezierCurve', 'rightLandmarkBezierCurve', 'annotatedLeftBezierCurve', 'annotatedRightBezierCurve',...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix',...
            'rejectedLandmarkLeft3DMatrix', 'rejectedLandmarkRight3DMatrix', ...
            'landmarkMean3DMatrix', 'meanSplineCurve', 'meanBezierCurve');

        % Frame used to render single annnulus plot
        frame = 1;
        landmark3DMatrix = landmarkLeft3DMatrix(:,~isnan(landmarkLeft3DMatrix(1,:,frame)));
        landmark3DMatrix = landmark3DMatrix .* (pixelCorr); %in meters
        
        %{
        %plot surface of valve
        figure;
        p_h=plot3(landmarkLeft3DMatrix(1,:,frame),landmarkLeft3DMatrix(2,:,frame),landmarkLeft3DMatrix(3,:,frame),'o');hold on     
        rangeX=floor(min(landmark3DMatrix(1,:))):1.0:ceil(max(landmark3DMatrix(1,:)));
        rangeY=floor(min(landmark3DMatrix(2,:))):1.0:ceil(max(landmark3DMatrix(2,:)));
        [X,Y]=meshgrid(rangeX,rangeY);
        Z = griddata(landmark3DMatrix(1,:),landmark3DMatrix(2,:),landmark3DMatrix(3,:),X,Y,'cubic');
        h = surf(X,Y,Z);
        surfarea(h)
        
        %}
        
        %plot surface of valve 2.0
        figure;
        p_h=plot3(landmarkLeft3DMatrix(1,:,frame),landmarkLeft3DMatrix(2,:,frame),landmarkLeft3DMatrix(3,:,frame),'o');hold on
        tri = delaunay(landmark3DMatrix(1,:),landmark3DMatrix(2,:));
        h = trisurf(tri, landmark3DMatrix(1,:), landmark3DMatrix(2,:), landmark3DMatrix(3,:));
        area = surfarea(h);
        fprintf('Area of MV is: %0.2f cm². \n', area*100);
        %
        
    end
end