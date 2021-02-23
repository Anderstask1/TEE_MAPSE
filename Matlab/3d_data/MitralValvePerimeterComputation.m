%Compute perimeter of mitral valve from scatterpoints of annulus
%Author: Anders Tasken
%Started 19.02.2021
function MitralValvePerimeterComputation(fileNames, cardiac_view)

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
        
        for frame = 1 : size(landmarkLeft3DMatrix, 3)
            
            %landmark3DMatrix = rejectedLandmarkLeft3DMatrix(:,:,frame);
            landmark3DMatrix = permute(leftLandmarkBezierCurve(:, :, frame), [2 1 3]);
            landmark3DMatrix = landmark3DMatrix(:,~isnan(landmark3DMatrix(1,:)));            
            landmark3DMatrix = landmark3DMatrix .* (pixelCorr); %in millimeters
            
            plot3(landmark3DMatrix(1,:), landmark3DMatrix(2,:), landmark3DMatrix(3,:), 'LineWidth', 3);
            
            dist = 0;
            
            for i = 1 : size(landmark3DMatrix, 2)
                dist = dist + norm(landmark3DMatrix(:,1)-landmark3DMatrix(:,2)); %mm
            end
            
            fprintf('Perimeter of MV is: %0.2f cm. \n', dist*100); 
        end
    end
end