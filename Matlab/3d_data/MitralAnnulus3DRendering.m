%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020

function MitralAnnulus3DRendering(mapseLeft3DMatrix, mapseRight3DMatrix, frameNo, name, filesPath)
    %% Use 3d coordinates of right and left mv landmark for 180 degrees rotation to construct 3d render of Mitral Annulus

    %create folder for figure
    directoryPath = strcat(filesPath, 'MVAnnulusFigures/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end

    %% Scatterplot -first frame
    frame = 1;
    scatterFig = figure;

    %plot right landmarks
    scatter3(mapseRight3DMatrix(1,:,frame), mapseRight3DMatrix(2,:,frame), mapseRight3DMatrix(3,:,frame));

    hold on

    %plot left landmarks
    scatter3(mapseLeft3DMatrix(1,:,frame), mapseLeft3DMatrix(2,:,frame), mapseLeft3DMatrix(3,:,frame));

    hold off

    %figure title
    scatterFigName = strcat('Scatterplot of frame: - ', frame,'- with name: -', name);
    title(scatterFigName)

    %save figure
    scatterFigName = strcat(directoryPath, name,'_', int2str(frame), '_scatterplot3D.fig');
    savefig(scatterFig, scatterFigName)

    %% Lineplot -first frame
    lineFig = figure;

    plot3(mapseLeft3DMatrix(1,:,frame), mapseLeft3DMatrix(2,:,frame), mapseLeft3DMatrix(3,:,frame));

    hold on

    plot3(mapseRight3DMatrix(1,:,frame), mapseRight3DMatrix(2,:,frame), mapseRight3DMatrix(3,:,frame));

    hold off

    %figure title
    lineFigName = strcat('Lineplot of frame: - ', frame,'- with name: -', name);
    title(lineFigName)

    %save figure
    lineFigName = strcat(directoryPath, name,'_', int2str(frame),'_lineplot3D.fig');
    savefig(lineFig, lineFigName)

    %add to 2d perpendicular slices to the volume

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
    lineFrameFigName = strcat(directoryPath, name,'_lineplot3D_all_frames.fig');
    savefig(lineFrameFig, lineFrameFigName)
    
end