%Extract MV Landmarks, inverse transform to 3d coordinate systen and
%estimate MV center from x- and y-rotattion
%Author: Anders Tasken
%Started 05.03.2021

function MitralValveCenterEstimation(fileNames, startAngle, endAngle, stepDegree)

    blueColor = [0, 0.4470, 0.7410];
    orangeColor = [0.8500, 0.3250, 0.0980];
    yellowColor = [0.9290, 0.6940, 0.1250];
    greenColor = [0.4660, 0.6740, 0.1880];

    %iterate over all .h5 files in directory
    for f=1:size(fileNames,2)
        
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        fprintf('File %d of %d \n', f, size(fileNames,2));

        %% Load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        
        infoVol01 = h5info(filePath, '/CartesianVolumes/vol01');
        sz = infoVol01.Dataspace.Size;
        
        info = h5info(filePath);
        if ~any(strcmp({info.Groups.Name}, '/RotatedYVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        
        elseif ~any(strcmp({info.Groups.Name}, '/RotatedXVolumes'))
            fprintf('Skipping iteration with file %s, since volume not rotated. \n', name);
            continue
        end
        
        %number of rotations
        infoRotations = h5info(filePath, '/RotatedXVolumes');
        rotations = length(infoRotations.Groups);
        
        landmark3DMatrix = nan(3, 4 * rotations);
        
        i = 1;
        
        % Rotate given degrees
        for angle = startAngle:stepDegree:endAngle
        
            %get field data
            fieldName = strcat('rotated_by_', int2str(angle),'_degrees');

            ds = strcat('/RotatedYVolumes/', fieldName, '/MAPSE_detected_landmarks');
            mapseLandmarksY = h5read(filePath, ds)';

            ds = strcat('/RotatedXVolumes/', fieldName, '/MAPSE_detected_landmarks');
            mapseLandmarksX = h5read(filePath, ds)';

            %load rotation matrix
            trfFileName = strcat(path,'Transformation-matrices_y-axis/', name, '/rotateM_y_y-axis-rotated_by_', int2str(angle),'_degrees.mat');
            rotateM_y = load(trfFileName, 'rotateM_y').rotateM_y;
            
            trfFileName = strcat(path,'Transformation-matrices_x-axis/', name, '/rotateM_x_x-axis-rotated_by_', int2str(angle),'_degrees.mat');
            rotateM_x = load(trfFileName, 'rotateM_x').rotateM_x;

            %translate origin to probe center
            translateM_probe_center = [
                  1 0 0 sz(1)/2
                  0 1 0 sz(2)/2
                  0 0 1 0
                  0 0 0 1
                ];
            
            trfY = translateM_probe_center * rotateM_y / translateM_probe_center;
            
            trfX = translateM_probe_center * rotateM_x / translateM_probe_center;

            %% Transformation computation    
            %compute x coordinate value
            x = sz(1)/2;
            y = sz(1)/2;

            %create 3d vector from coordinates, only 1st frame
            %landmark: x-z, right landmark x-z
            mapseYLeft3D_trf = [x; mapseLandmarksY(1,1); mapseLandmarksY(1,2); 1];
            mapseYRight3D_trf = [x; mapseLandmarksY(1,3); mapseLandmarksY(1,4); 1];
            
            %landmark: y-z, right landmark y-z
            mapseXLeft3D_trf = [mapseLandmarksX(1,1); y; mapseLandmarksX(1,2); 1];
            mapseXRight3D_trf = [mapseLandmarksX(1,3); y; mapseLandmarksX(1,4); 1];

            mapseYLeft3D = trfY \ mapseYLeft3D_trf;
            mapseYRight3D = trfY \ mapseYRight3D_trf;
            
            mapseXLeft3D = trfX \ mapseXLeft3D_trf;
            mapseXRight3D = trfX \ mapseXRight3D_trf;
            
             %convert to cartesian coordinates
            mapseYLeft3D(4) = [];
            mapseYRight3D(4) = [];
            
            mapseXLeft3D(4) = [];
            mapseXRight3D(4) = [];
            
            if ~(any(isnan(mapseYLeft3D)) || any(isnan(mapseYRight3D)))
                landmark3DMatrix(:, i) = mapseYLeft3D;
                landmark3DMatrix(:, 3*rotations - i) = mapseYRight3D;
            end
            
            if ~(any(isnan(mapseXLeft3D)) || any(isnan(mapseXRight3D)))                
                landmark3DMatrix(:, i + rotations) = mapseXLeft3D;
                landmark3DMatrix(:, 4*rotations - i) = mapseXRight3D;
            end
            
            i = i + 1;
            
        end
        
        landmark3DMatrix(:,any(isnan(landmark3DMatrix),1)) = [];
        
        %% Folders
        %create folder for mv center estimate variable
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end
        
        %create folder for transformation matrices
        directoryPath = strcat(directoryPath, name, '/');
        if ~exist(directoryPath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryPath);
        end
        
        %% Save landmark matrix
        trfFileName = strcat(directoryPath, 'landmark3DMatrix.mat');
        save(trfFileName,'landmark3DMatrix');
               
        %% Interpolation of landmark values
        %[~, landmarkBezierCurve] = InterpolateLandmarks3D(landmark3DMatrix, 1);
        
        %% Outliers rejection
        %rejectedLandmark3DMatrix = LandmarkOutlierRejection3D(landmark3DMatrix, landmarkBezierCurve, 1, 0.0007);
        
        %% MV Center Estimation - CoM
        mvCenter3D = [nanmean(landmark3DMatrix(1,:));
                   nanmean(landmark3DMatrix(2,:));
                   nanmean(landmark3DMatrix(3,:));
                   1];

        %save mv center estimate
        trfFileName = strcat(directoryPath, 'mv-center-estimate.mat');
        save(trfFileName,'mvCenter3D');
                
        %% Plot
        figure; 
        scatter3(landmark3DMatrix(1,:), landmark3DMatrix(2,:), landmark3DMatrix(3,:), 'o', 'MarkerEdgeColor', blueColor); hold on
        %plot3(landmarkBezierCurve(:,1,1),landmarkBezierCurve(:,2,1),landmarkBezierCurve(:,3,1), 'LineWidth', 3, 'Color', yellowColor);
        %scatter3(rejectedLandmark3DMatrix(1,:), rejectedLandmark3DMatrix(2,:), rejectedLandmark3DMatrix(3,:), 'o', 'MarkerEdgeColor', orangeColor);
        %fnplt(landmarkSplineCurve(1), 2);
        scatter3(mvCenter3D(1), mvCenter3D(2), mvCenter3D(3), 'o', 'MarkerEdgeColor', greenColor);
        
        xlabel('x');
        ylabel('y');
        zlabel('z');
        
        %% Fit plane to 3d points of annulus
        X = permute(landmark3DMatrix, [2 1]);
        p = [mvCenter3D(1), mvCenter3D(2), mvCenter3D(3)];
        
        R = X-p;
        [V,D] = eig(R'*R);
        n = V(:,1);%normal vector
        V = V(:,2:end);
        
        %X=X-mean(X); 
        %[U,S,W]=svd(V,0);
        %n=W(:,end)
        
        %% Intersection with perpendicular line and z-axis
        m = -p(3) / n(3);
        intersectionPoint = p + m * n';
        
        %save points of intersection with z-axis
        trfFileName = strcat(directoryPath, 'intersection-point.mat');
        save(trfFileName,'intersectionPoint');
        
        %% Plot
        %{
        i = intersectionPoint;
        line([i(1) p(1)], [i(2) p(2)], [i(3) p(3)]);
  
        %plane
        [S1,S2] = meshgrid([-100 0 100]);
        X = p(1)+[S1(:) S2(:)]*V(1,:)';
        Y = p(2)+[S1(:) S2(:)]*V(2,:)';
        Z = p(3)+[S1(:) S2(:)]*V(3,:)';
        surf(reshape(X,3,3),reshape(Y,3,3),reshape(Z,3,3),'facecolor','blue','facealpha',0.5);
        %}
    end
end