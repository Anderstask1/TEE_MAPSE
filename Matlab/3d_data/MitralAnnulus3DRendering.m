%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020mapseLeft3D_inv_trf

function MitralAnnulus3DRendering(hdfdata, leftLandmarkSplineCurve, rightLandmarkSplineCurve, leftLandmarkBezierCurve, rightLandmarkBezierCurve, mapseLeft3DMatrix, mapseRight3DMatrix, frameNo, name, filesPath, saveScatterplot, saveLineplot, saveSplineInterpPlot, saveBezierInterpPlot)
    %% Frame used to render single annnulus plot
    frame = 1;

    %% Use 3d coordinates of right and left mv landmark for 180 degrees rotation to construct 3d render of Mitral Annulus

    %create folder for figure
    directoryPath = strcat(filesPath, 'PostProcessMVAnnulusFigures/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end
    
    %create folder for figure
    directoryPath = strcat(directoryPath, name, '/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end

    %% Scatterplot -first frame
    if saveScatterplot
        
        scatterFig = figure('visible','off');

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
        scatterFigName = strcat(directoryPath, name,'_frame_', int2str(frame), '_scatterplot3D.fig');
        savefig(scatterFig, scatterFigName)
    end

    %% Lineplot -first frame
    if saveLineplot
        
        lineFig = figure('visible','off');

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

        xImage = [0 volumeSize(1);0 volumeSize(1)];   % The x data for the image corners
        yImage = [volumeSize(2)/2 volumeSize(2)/2; volumeSize(2)/2 volumeSize(2)/2]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');
        
        %get image from first frame in sequence, remove dimension of length 1
        slice = squeeze(volumeData(round(volumeSize(1)/2),:,:))';

        xImage = [volumeSize(1)/2 volumeSize(1)/2; volumeSize(1)/2 volumeSize(1)/2];   % The x data for the image corners
        yImage = [0 volumeSize(2);0 volumeSize(2)]; % The y data for the image corners
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
    if saveLineplot
        
        lineFrameFig = figure('visible','off');

        for j = 1 : frameNo

            plot3(mapseLeft3DMatrix(1,:,j), mapseLeft3DMatrix(2,:,j), mapseLeft3DMatrix(3,:,j));

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
    if saveSplineInterpPlot
        
        interpFigure = figure('visible','off');
        
        fnplt(leftLandmarkSplineCurve(frame),2);
        
        hold on
        fnplt(rightLandmarkSplineCurve(frame),2);
        
        %figure title
        interpFigName = strcat('Spline interpolation plot of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_frame_', int2str(frame), '_spline_interpolation-plot3D.fig');
        savefig(interpFigure, interpFrameFigName);
        
        %save 2d image of figure
        %change view 
        view(320, 32);
        interpFrameImageName = strcat(directoryPath, name,'_spline_interpolation-frame3D.png');
        saveas(gca, interpFrameImageName);
        
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
        yImage = [0 volumeSize(2); 0 volumeSize(2)]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');
        
        hold off
        
        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_spline_interpolation-plot3D_with_slices.fig');
        savefig(interpFigure, interpFrameFigName);
    end
    
    %% Plot of interpolated annulus - all frames - left
    if saveSplineInterpPlot
        
        interpAllFramesFigure = figure('visible','off');
        
        for f = 1 : frameNo
            fnplt(leftLandmarkSplineCurve(f),2);
            hold on 
        end
        
        hold off
        
        %figure title
        interpFigName = strcat('Spline interpolation left plot (all frames) of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_spline_interpolation-plot3D_left_all-frames.fig');
        savefig(interpAllFramesFigure, interpFrameFigName);
    end
    
    %% Plot of interpolated annulus - all frames - right
    if saveSplineInterpPlot
        
        interpAllFramesFigure = figure('visible','off');
        
        for f = 1 : frameNo
            fnplt(rightLandmarkSplineCurve(f),2);
            hold on 
        end
        
        hold off
        
        %figure title
        interpFigName = strcat('Spline interpolation right plot (all frames) of: -', name);
        title(interpFigName);

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_spline_interpolation-plot3D_right_all-frames.fig');
        savefig(interpAllFramesFigure, interpFrameFigName);
    end
    
    %% Plot Bezier interpolated annulus
    if saveBezierInterpPlot
       
        interpFig = figure('visible','off');
        
        plot3(leftLandmarkBezierCurve(:,1,frame),leftLandmarkBezierCurve(:,2,frame),leftLandmarkBezierCurve(:,3,frame));
        
        hold on
        
        plot3(rightLandmarkBezierCurve(:,1,frame),rightLandmarkBezierCurve(:,2,frame),rightLandmarkBezierCurve(:,3,frame));
        
        xlabel('x');
        ylabel('y');    
        zlabel('z');

        %figure title
        interpTitleName = strcat('Bezier interpolation of frame: - ', int2str(frame),'- with name: -', name);
        title(interpTitleName)

        %save figure
        interpFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_bezier_interpolation_3D.fig');
        savefig(interpFig, interpFigName)

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

        xImage = [0 volumeSize(1);0 volumeSize(1)];   % The x data for the image corners
        yImage = [volumeSize(2)/2 volumeSize(2)/2; volumeSize(2)/2 volumeSize(2)/2]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');
        
        %get image from first frame in sequence, remove dimension of length 1
        slice = squeeze(volumeData(round(volumeSize(1)/2),:,:))';

        xImage = [volumeSize(1)/2 volumeSize(1)/2; volumeSize(1)/2 volumeSize(1)/2];   % The x data for the image corners
        yImage = [0 volumeSize(2);0 volumeSize(2)]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',slice,...
         'FaceColor','texturemap');
        colormap('gray');

        hold off;
        
        %save figure
        interpFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_bezier_interpolation_3D_with_slices.fig');
        savefig(interpFig, interpFigName)
        
    end
end