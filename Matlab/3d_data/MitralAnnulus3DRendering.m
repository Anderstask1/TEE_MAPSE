%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020mapseLeft3D_inv_trf

function MitralAnnulus3DRendering(hdfdata, interpLeftLandmark3D, interpRightLandmark3D, mapseLeft3DMatrix, mapseRight3DMatrix, frameNo, name, filesPath, saveScatterplot, saveLineplot, saveLineplotAllFrames, saveInterpPlot, saveInterpPlotAllFrames)
    %% Use 3d coordinates of right and left mv landmark for 180 degrees rotation to construct 3d render of Mitral Annulus

    %create folder for figure
    directoryPath = strcat(filesPath, 'MVAnnulusFigures/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end

    %% Scatterplot -first frame
    if saveScatterplot
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
    end

    %% Lineplot -first frame
    if saveLineplot
        frame = 2;
        lineFig = figure;

        plot3(mapseLeft3DMatrix(1,:,frame), mapseLeft3DMatrix(2,:,frame), mapseLeft3DMatrix(3,:,frame));

        hold on;

        plot3(mapseRight3DMatrix(1,:,frame), mapseRight3DMatrix(2,:,frame), mapseRight3DMatrix(3,:,frame));

        xlabel('x');
        ylabel('y');    
        zlabel('z');

        %figure title
        lineFigName = strcat('Lineplot of frame: - ', int2str(frame),'- with name: -', name);
        title(lineFigName)

        %save figure
        lineFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_lineplot3D.fig');
        savefig(lineFig, lineFigName)

        %----------- add to 2d perpendicular slices to the volume ---------
        %get volume data of frame
        volumeFieldName = strcat('vol0', int2str(frame));
        if frame > 9
            volumeFieldName = strcat('vol', int2str(frame));
        end
        volumeData = hdfdata.CartesianVolumes.(volumeFieldName);

        %get volume size
        volumeSize = size(volumeData);

        %get image from first frame in sequence, remove dimension of length 1
        slice = squeeze(volumeData(:,round(volumeSize(2)/2),:))';

        xImage = [0 volumeSize(1); 0 volumeSize(1)];   % The x data for the image corners
        yImage = [volumeSize(2)/2 volumeSize(2)/2; volumeSize(2)/2 volumeSize(2)/2]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');
        
        %get image from first frame in sequence, remove dimension of length 1
        slice = squeeze(volumeData(round(volumeSize(1)/2),:,:))';

        xImage = [volumeSize(1)/2 volumeSize(1)/2; volumeSize(1)/2 volumeSize(1)/2];   % The x data for the image corners
        yImage = [0 volumeSize(2); 0 volumeSize(2) ]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');

        hold off;
        
        %save figure
        lineFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_lineplot3D_with_slices.fig');
        savefig(lineFig, lineFigName)
    end

    %% Lineplot of all frames
    if saveLineplotAllFrames
        
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
    
    %% Plot of interpolated annulus - first frame
    if saveInterpPlot
        
        interpFigure = figure;
        
        fnplt(interpLeftLandmark3D(1),2);
        
        hold on
        fnplt(interpRightLandmark3D(1),2);
        hold off
        
        %figure title
        interpFigName = strcat('Interpolation plot of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_interpolation-plot3D.fig');
        savefig(interpFigure, interpFrameFigName);
    end
    
    %% Plot of interpolated annulus - all frames - left
    if saveInterpPlotAllFrames
        
        interpAllFramesFigure = figure;
        
        for f = 1 : frameNo
            fnplt(interpLeftLandmark3D(f),2);
            hold on 
        end
        
        hold off
        
        %figure title
        interpFigName = strcat('Interpolation left plot (all frames) of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_interpolation-plot3D_left_all-frames.fig');
        savefig(interpAllFramesFigure, interpFrameFigName);
    end
    %% Plot of interpolated annulus - all frames - right
    if saveInterpPlotAllFrames
        
        interpAllFramesFigure = figure;
        
        for f = 1 : frameNo
            fnplt(interpRightLandmark3D(f),2);
            hold on 
        end
        
        hold off
        
        %figure title
        interpFigName = strcat('Interpolation right plot (all frames) of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_interpolation-plot3D_right_all-frames.fig');
        savefig(interpAllFramesFigure, interpFrameFigName);
    end
end