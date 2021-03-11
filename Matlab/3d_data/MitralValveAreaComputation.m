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
        %hdfdata = HdfImport(filePath);
        
        try 
            ds = strcat('/ImageGeometry/voxelsize');
            pixelCorr = h5read(filePath, ds);
        catch
            %default voxelsize value
            pixelCorr = 0.7e-3;
            fprintf('Failed to read pixelCorr for file %s', name);
        end
        
        % Load landmark variable matrices
        variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/landmarkMatrices_', cardiac_view, '_', name);
        
        load(variablesFilename,...
            'leftLandmarkSplineCurve', 'rightLandmarkSplineCurve', 'annotatedLeftSplineCurve', 'annotatedRightSplineCurve',...
            'leftLandmarkBezierCurve', 'rightLandmarkBezierCurve', 'annotatedLeftBezierCurve', 'annotatedRightBezierCurve',...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix',...
            'rejectedLandmarkLeft3DMatrix', 'rejectedLandmarkRight3DMatrix', ...
            'landmarkMean3DMatrix', 'meanSplineCurve', 'meanBezierCurve');

        %load landmark matrix for x and y rot
        trfFileName = strcat(filesPath,'LandmarkMatricesVariables/', name, '/landmark3DMatrix.mat');
        
        for frame = 1 : size(landmarkLeft3DMatrix, 3)
            %landmark3DMatrix = landmarkRight3DMatrix(:,:,frame);
            landmark3DMatrix = load(trfFileName,'landmark3DMatrix').landmark3DMatrix;
            %landmark3DMatrix = permute(leftLandmarkBezierCurve(:, :, frame), [2 1 3]);
            landmark3DMatrix = landmark3DMatrix(:,~isnan(landmark3DMatrix(1,:)));            
            landmark3DMatrix = landmark3DMatrix .* (pixelCorr*10); %in cm

            %plot surface of valve
            %p_h=plot3(landmark3DMatrix(1,:),landmark3DMatrix(2,:),landmark3DMatrix(3,:),'o'); hold on
            tri = delaunay(landmark3DMatrix(1,:),landmark3DMatrix(2,:)); %matlab  of scattered data
            h = trisurf(tri, landmark3DMatrix(1,:), landmark3DMatrix(2,:), landmark3DMatrix(3,:), ...
                'FaceColor', 'y', 'FaceAlpha', 0.5); %surf of triangulations
            
            %area of patch = sum of areas of all patch faces
            faces = h.Faces;
            verts = h.Vertices;
            a = verts(faces(:, 2), :) - verts(faces(:, 1), :);
            b = verts(faces(:, 3), :) - verts(faces(:, 1), :);
            c = cross(a, b, 2);
            area = 1/2 * sum(sqrt(sum(c.^2, 2)));
            
            fprintf('Area of MV is: %0.2f cm². \n', area);
            %
        end
    end
end