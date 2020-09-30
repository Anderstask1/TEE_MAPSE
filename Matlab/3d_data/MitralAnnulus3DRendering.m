%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020

function MitralAnnulus3DRendering

    close all

    %% Load data
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %iterate over all .h5 files in directory
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ext] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        hdfdata = HdfImport(filePath);
        
        %% Extract mapse landmark for all rotations and images
        %get all fields from data struct
        fields = fieldnames(hdfdata.MVCenterRotatedVolumes);
        
        %sort fields on rotation degree
        sortedFields = natsort(fields);
        
        %number of frames
        frameNo = length(fieldnames(hdfdata.CartesianVolumes));

        %store mapse coordinates in matrix
        mapseLeft3DMatrix = zeros(3, numel(fields), frameNo);
        mapseRight3DMatrix = zeros(3, numel(fields), frameNo);
        
        %iterate over all fields
        for i = 1 : numel(fields)

            %get landmark coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.MVCenterRotatedVolumes.(sortedFields{i}).MAPSE_detected_landmarks';
            
            %compute y coordinate value
            volume = hdfdata.CartesianVolumes.('vol01');
            y = size(volume,2)/2;
            
            %iterate over all frames
            for j = 1 : frameNo
            
                %create 3d vector from coordinates, only 1st frame
                mapseLeft3D = [mapseLandmarks(j,1); y; mapseLandmarks(j,2); 1];
                mapseRight3D = [mapseLandmarks(j,3); y; mapseLandmarks(j,4); 1];

                %% Inverse transform to original coordinate system
                %load transformation matrix
                trfFileName = strcat(filesPath,'Transformation-matrices_mv-center/','trf_matrix_mv-center-', sortedFields{i},'.mat');
                mv_trf = load(trfFileName, 'mv_trf').mv_trf;

                %inverse transformation matrix, to transform coordinates back to
                %original system
                inverse_trf = inv(mv_trf);

                %inverse transform
                mapseLeft3D_inv_trf = inverse_trf * mapseLeft3D;
                mapseRight3D_inv_trf = inverse_trf * mapseRight3D;

                %convert to cartesian coordinates
                mapseLeft3D_inv_trf(4) = [];
                mapseRight3D_inv_trf(4) = [];

                %save
                mapseLeft3DMatrix(:, i, j) = mapseLeft3D_inv_trf;
                mapseRight3DMatrix(:, i, j) = mapseRight3D_inv_trf;
                
            end
        end

        %% Use 3d coordinates of right and left mv landmark for 180 degrees rotation to construct 3d render of Mitral Annulus
        
        %create folder for figure
        directoryPath = strcat(filesPath, '/MVAnnulusFigures/');
        mkdir(directoryPath);
        
        %% Scatterplot -first frame
        scatterFig = figure;

        %plot right landmarks
        scatter3(mapseRight3DMatrix(1,:,1), mapseRight3DMatrix(2,:,1), mapseRight3DMatrix(3,:,1));

        hold on

        %plot left landmarks
        scatter3(mapseLeft3DMatrix(1,:,1), mapseLeft3DMatrix(2,:,1), mapseLeft3DMatrix(3,:,1));

        hold off

        %figure title
        scatterFigName = strcat('Scatterplot of frame: - ', j,'- with name: -', name);
        title(scatterFigName)

        %save figure
        scatterFigName = strcat(directoryPath, name,'_', int2str(j), '_scatterplot3D.fig');
        savefig(scatterFig, scatterFigName)

        %% Lineplot -first frame
        lineFig = figure;

        plot3(mapseLeft3DMatrix(1,:,1), mapseLeft3DMatrix(2,:,1), mapseLeft3DMatrix(3,:,1));

        hold on

        plot3(mapseRight3DMatrix(1,:,1), mapseRight3DMatrix(2,:,1), mapseRight3DMatrix(3,:,1));

        hold off

        %figure title
        lineFigName = strcat('Lineplot of frame: - ', j,'- with name: -', name);
        title(lineFigName)

        %save figure
        lineFigName = strcat(directoryPath, name,'_', int2str(j),'_lineplot3D.fig');
        savefig(lineFig, lineFigName)
        
        %% Lineplot of all frames

        lineFrameFig = figure;
        
        for j = 1 : frameNo

            plot3(mapseLeft3DMatrix(1,:,j), mapseLeft3DMatrix(2,:,j), mapseLeft3DMatrix(3,:,j));
          
            drawnow
            
            pause(0.2)
            
            hold on
            
        end

        hold off

        %figure title
        lineFigName = strcat('Lineplot of: -', name);
        title(lineFigName)

        %save figure
        lineFrameFigName = strcat(directoryPath, name,'_', int2str(j),'_lineplot3D_all_frames.fig');
        savefig(lineFrameFig, lineFrameFigName)
        
    end
end