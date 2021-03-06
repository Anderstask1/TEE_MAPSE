%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020

function MitralAnnulus3DRendering(fileNames, cardiac_view)
    %call the MAPSE postprocessing script for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [filesPath, name, ~] = fileparts(fileNames(f).name);
        
        %% Frame used to render single annnulus plot
        frame = 1;

        %% Load data   
        %show progress
        fprintf('Loaded file with name: %s. \n', name);

        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        %hdfdata = HdfImport(filePath);
        
        %number of frames
        %frameNo = length(fieldnames(hdfdata.CartesianVolumes));
        %infoCartesianVolumes = h5info(filePath, '/CartesianVolumes');
        %frameNo = length(infoCartesianVolumes.Datasets);
        
        %{
        %load optMapseAngles
        filename = strcat(filesPath, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
        optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

        %skip iteration if optimal angle is 0 (most likely due to no landmarks)
        if optMapseAngle == 0
            fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
            continue
        end
        %}
        
        blueColor = [0, 0.4470, 0.7410];
        orangeColor = [0.8500, 0.3250, 0.0980];
        yellowColor = [0.9290, 0.6940, 0.1250];
        greenColor = [0.4660, 0.6740, 0.1880];
        lightBlueColor = [0.3010, 0.7450, 0.9330];
        brownColor = [0.6350, 0.0780, 0.1840];
        purpleColor = [0.4940, 0.1840, 0.5560];
        
        %% Load landmark variable matrices
        variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/landmarkMatrices_', cardiac_view, '_', name);
        
        load(variablesFilename,...
            'leftLandmarkSplineCurve', 'rightLandmarkSplineCurve', 'annotatedLeftSplineCurve', 'annotatedRightSplineCurve',...
            'leftLandmarkBezierCurve', 'rightLandmarkBezierCurve', 'annotatedLeftBezierCurve', 'annotatedRightBezierCurve',...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix',...
            'rejectedLandmarkLeft3DMatrix', 'rejectedLandmarkRight3DMatrix', ...
            'landmarkMean3DMatrix', 'meanSplineCurve', 'meanBezierCurve');

        %% Load 3d slices
        %get volume data of frame
        volumeFieldName = strcat('vol0', int2str(frame));
        if frame > 9
            volumeFieldName = strcat('vol', int2str(frame));
        end
        %volumeData = hdfdata.CartesianVolumes.(volumeFieldName);
        ds = strcat('/CartesianVolumes/', volumeFieldName);
        volumeData = h5read(filePath, ds);

        %get volume size
        volumeSize = size(volumeData);
        
        xImage = [0 volumeSize(1); 0 volumeSize(1)];   % The x data for the image corners
        yImage = [volumeSize(2)/2 volumeSize(2)/2; volumeSize(2)/2 volumeSize(2)/2]; % The y data for the image corners
        zImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners

        %get image from first frame in sequence, remove dimension of length 1
        sliceX = squeeze(volumeData(round(volumeSize(2)/2),:,:))';
        
        xRotImage = [volumeSize(1)/2 volumeSize(1)/2; volumeSize(1)/2 volumeSize(1)/2];   % The x data for the image corners
        yRotImage = [0 volumeSize(2); 0 volumeSize(2)]; % The y data for the image corners
        zRotImage = [0 0; volumeSize(3) volumeSize(3)];   % The z data for the image corners
        
        %get image from first frame in sequence, remove dimension of length 1
        sliceY = squeeze(volumeData(:,round(volumeSize(1)/2),:))';

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
        
        %% Scatterplot of landmarks from mv center rotation and landmarks from x and y axis rotatio

        scatterFig = figure('visible','off');
        
        %load landmark matrix for x and y rot
        trfFileName = strcat(filesPath,'LandmarkMatricesVariables/', name, '/landmark3DMatrix.mat');
        landmark3DMatrix = load(trfFileName,'landmark3DMatrix').landmark3DMatrix;
        
        %----------- add to 2d perpendicular slices to the volume ---------
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',sliceX,...
         'FaceColor','texturemap'); hold on
        colormap('gray');

        surf(xRotImage,yRotImage,zRotImage,...    % Plot the surface
         'CData',sliceY,...
         'FaceColor','texturemap');
        colormap('gray');
        
        alpha 0.6
        
        %---------------------- plot landmarks --------------------
        plot3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'LineWidth', 3, 'Color', blueColor);
        plot3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'LineWidth', 3, 'Color', orangeColor);
        
        %plot scatter landmarks
        scatter3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'o', 'MarkerEdgeColor', blueColor); hold on
        scatter3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'o', 'MarkerEdgeColor', orangeColor);
        
        %plot scatter landmarks rejected
        scatter3(landmark3DMatrix(1,:), landmark3DMatrix(2,:), landmark3DMatrix(3,:), '*', 'MarkerEdgeColor', yellowColor);
        
        xlabel('x');
        ylabel('y');    
        zlabel('z');
        
        legend('Left scatter mv rot', 'Right scatter mv rot', 'Left scatter xy rot', 'Right scatter xy rot');
        
        %figure title
        interpTitleName = strcat('Scatterplot of frame: - ', int2str(frame),'- with name: -', name);
        title(interpTitleName)

        %save figure
        scatterFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_scatterfig_xy_rotation.fig');
        savefig(scatterFig, scatterFigName)
        %{
        
        %% Scatterplot of landmarks and rejected landmarks
        scatterFig = figure('visible','off');
        
        %plot scatter landmarks
        scatter3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'o', 'MarkerEdgeColor', blueColor); hold on
        scatter3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'o', 'MarkerEdgeColor', orangeColor);
        
        %plot scatter landmarks rejected
        scatter3(rejectedLandmarkLeft3DMatrix(1,:,frame), rejectedLandmarkLeft3DMatrix(2,:,frame), rejectedLandmarkLeft3DMatrix(3,:,frame), '*', 'MarkerEdgeColor', yellowColor);
        scatter3(rejectedLandmarkRight3DMatrix(1,:,frame), rejectedLandmarkRight3DMatrix(2,:,frame), rejectedLandmarkRight3DMatrix(3,:,frame), '*', 'MarkerEdgeColor', greenColor);
        
        %plot bezier curve
        plot3(leftLandmarkBezierCurve(:,1,frame),leftLandmarkBezierCurve(:,2,frame),leftLandmarkBezierCurve(:,3,frame), 'LineWidth', 3, 'Color', blueColor);
        plot3(rightLandmarkBezierCurve(:,1,frame),rightLandmarkBezierCurve(:,2,frame),rightLandmarkBezierCurve(:,3,frame), 'LineWidth', 3, 'Color', orangeColor);hold off
        
        xlabel('x');
        ylabel('y');    
        zlabel('z');
        
        legend('Left scatter', 'Right scatter', 'Left rejected scatter', 'Right rejected scatter');
        
        %figure title
        interpTitleName = strcat('Scatterplot of frame: - ', int2str(frame),'- with name: -', name);
        title(interpTitleName)

        %save figure
        scatterFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_scatterfig_rejected.fig');
        savefig(scatterFig, scatterFigName)

        %% Lineplot -first frame
        lineFig = figure('visible','off');
        
        %----------- add to 2d perpendicular slices to the volume --------
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',sliceX,...
         'FaceColor','texturemap'); hold on
        colormap('gray');

        surf(xRotImage,yRotImage,zRotImage,...    % Plot the surface
         'CData',sliceY,...
         'FaceColor','texturemap');
        colormap('gray');
        
        alpha 0.6
        
        %---------------------- plot landmarks --------------------
        %for frame = 1 : frameNo
            plot3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'LineWidth', 3, 'Color', blueColor);
            plot3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'LineWidth', 3, 'Color', orangeColor);
        %end
        % annotated data
        plot3(annotatedLeft3DMatrix(1,:,frame), annotatedLeft3DMatrix(2,:,frame), annotatedLeft3DMatrix(3,:,frame), '-', 'LineWidth', 3, 'Color', yellowColor);
        plot3(annotatedRight3DMatrix(1,:,frame), annotatedRight3DMatrix(2,:,frame), annotatedRight3DMatrix(3,:,frame), '-', 'LineWidth', 3, 'Color', greenColor);

        %plot landmarks scatter
        scatter3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'MarkerEdgeColor', blueColor);
        scatter3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'MarkerEdgeColor', orangeColor);

        legend('Y-axis slice of original volume', 'X-axis slice of original volume',...
            'Left landmarks', 'Right landmarks', 'Left annotation', 'Right annotation', 'Left scatter', 'Right scatter');

        xlabel('x');
        ylabel('y');    
        zlabel('z');
        
        title(name)

        %save figure
        lineFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_lineplot3D_with_slices.fig');
        savefig(lineFig, lineFigName)

        %% Plot of interpolated annulus - frame
        interpFigure = figure('visible','off');
        
        %----------- add to 2d perpendicular slices to the volume ---------
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',sliceX,...
         'FaceColor','texturemap'); hold on
        colormap('gray');
        
        surf(xRotImage,yRotImage,zRotImage,...    % Plot the surface
         'CData',sliceY,...
         'FaceColor','texturemap');
        colormap('gray');
        
        alpha 0.8
        
        %---------------------- plot landmarks --------------------

        fnplt(rightLandmarkSplineCurve(frame), 2);
        fnplt(leftLandmarkSplineCurve(frame), 2);

        %annotated spline
        fnplt(annotatedLeftSplineCurve(frame), 2, yellowColor);
        fnplt(annotatedRightSplineCurve(frame), 2, greenColor);

        %plot landmarks scatter
        scatter3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'MarkerEdgeColor', orangeColor);
        scatter3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'MarkerEdgeColor', blueColor);

        legend('Y-axis slice of original volume', 'X-axis slice of original volume',...
            'Left landmarks', 'Right landmarks', 'Left annotation', 'Right annotation', 'Left scatter', 'Right scatter');

        %figure title
        interpTitleName = strcat('Spline interpolation of frame: - ', int2str(frame),'- with name: -', name);
        title(interpTitleName)

        %save 2d image of figure
        %change view 
        view(320, 32);
        interpFrameImageName = strcat(directoryPath, name,'_spline_interpolation-frame3D.png');
        saveas(gca, interpFrameImageName);

        hold off

        %save figure
        interpFrameFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_spline_interpolation-plot3D_with_slices.fig');
        savefig(interpFigure, interpFrameFigName);

        %% Plot Bezier interpolated annulus
        interpFig = figure('visible','off');
        
        %----------- add to 2d perpendicular slices to the volume ---------
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',sliceX,...
         'FaceColor','texturemap'); hold on
        colormap('gray');

        surf(xRotImage,yRotImage,zRotImage,...    % Plot the surface
         'CData',sliceY,...
         'FaceColor','texturemap');
        colormap('gray');
        
        alpha 0.8
        
        %---------------------- plot landmarks --------------------

        %bezier landmarks
        plot3(leftLandmarkBezierCurve(:,1,frame),leftLandmarkBezierCurve(:,2,frame),leftLandmarkBezierCurve(:,3,frame), 'LineWidth', 3, 'Color', blueColor);
        plot3(rightLandmarkBezierCurve(:,1,frame),rightLandmarkBezierCurve(:,2,frame),rightLandmarkBezierCurve(:,3,frame), 'LineWidth', 3, 'Color', orangeColor);

        %annotated
        plot3(annotatedLeftBezierCurve(:,1,frame),annotatedLeftBezierCurve(:,2,frame),annotatedLeftBezierCurve(:,3,frame), '-', 'LineWidth', 3, 'Color', yellowColor);
        plot3(annotatedRightBezierCurve(:,1,frame),annotatedRightBezierCurve(:,2,frame),annotatedRightBezierCurve(:,3,frame), '-', 'LineWidth', 3, 'Color', greenColor);

        %plot landmarks scatter
        scatter3(landmarkLeft3DMatrix(1,:,frame), landmarkLeft3DMatrix(2,:,frame), landmarkLeft3DMatrix(3,:,frame), 'MarkerEdgeColor', blueColor);
        scatter3(landmarkRight3DMatrix(1,:,frame), landmarkRight3DMatrix(2,:,frame), landmarkRight3DMatrix(3,:,frame), 'MarkerEdgeColor', orangeColor);

        xlabel('x');
        ylabel('y');    
        zlabel('z');

        legend('Y-axis slice of original volume', 'X-axis slice of original volume',...
            'Left landmarks', 'Right landmarks', 'Left annotation', 'Right annotation', 'Left scatter', 'Right scatter');

        %figure title
        interpTitleName = strcat('Bezier interpolation of frame: - ', int2str(frame),'- with name: -', name);
        title(interpTitleName)

        hold off;

        %save figure
        interpFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_bezier_interpolation_3D_with_slices.fig');
        savefig(interpFig, interpFigName)

        %% Plot of mean scatter, spline and bezier
        meanFig = figure('visible','off');
        
        %----------- add to 2d perpendicular slices to the volume ---------
        surf(xImage,yImage,zImage,...    % Plot the surface
         'CData',sliceX,...
         'FaceColor','texturemap'); hold on
        colormap('gray');

        surf(xRotImage,yRotImage, zRotImage,...    % Plot the surface
         'CData',sliceY,...
         'FaceColor','texturemap');
        colormap('gray');
        
        alpha 0.8
        
        %---------------------- plot landmarks --------------------
        
        %spline landmarks
        fnplt(meanSplineCurve(frame), 2);
        
        %annotated
        plot3(annotatedLeftBezierCurve(:,1,frame),annotatedLeftBezierCurve(:,2,frame),annotatedLeftBezierCurve(:,3,frame), '-', 'LineWidth', 3, 'Color', yellowColor);
        plot3(annotatedRightBezierCurve(:,1,frame),annotatedRightBezierCurve(:,2,frame),annotatedRightBezierCurve(:,3,frame), '-', 'LineWidth', 3, 'Color', greenColor);

        %bezier landmarks
        plot3(meanBezierCurve(:,1,frame), meanBezierCurve(:,2,frame), meanBezierCurve(:,3,frame), 'LineWidth', 3, 'Color', orangeColor);
        
        %plot landmarks scatter
        scatter3(landmarkMean3DMatrix(1,:,frame), landmarkMean3DMatrix(2,:,frame), landmarkMean3DMatrix(3,:,frame), 'MarkerEdgeColor', lightBlueColor);

        xlabel('x');
        ylabel('y');    
        zlabel('z');

        legend('Y-axis slice of original volume', 'X-axis slice of original volume',...
            'Mean Spline landmarks', 'Left annotation', 'Right annotation',  'Mean Bezier landmarks', 'Mean Scatter');

        %figure title
        meanTitleName = strcat('Mean bezier, spline and scatter of frame: - ', int2str(frame),'- with name: -', name);
        title(meanTitleName); hold off;

        %save figure
        meanFigName = strcat(directoryPath, name,'_frame_', int2str(frame),'_mean_scatter_spline_bezier_3D_with_slices.fig');
        savefig(meanFig, meanFigName)
        
        %% Create movie of annulus though all frames -raw

        %open mp4
        movieName = strcat(directoryPath, name, '_raw_annulus_movie.avi');
        mapseVideo = VideoWriter(movieName);
        mapseVideo.FrameRate = 2;
        mapseVideo.Quality = 100;
        open(mapseVideo)

        movieFig = figure('visible','off');

        %loop through the frames
        for f = 1:size(leftLandmarkSplineCurve, 2)

            plot3(landmarkRight3DMatrix(1,:,f), landmarkRight3DMatrix(2,:,f), landmarkRight3DMatrix(3,:,f), 'LineWidth', 3, 'Color', orangeColor); hold on
            plot3(annotatedRight3DMatrix(1,:,f), annotatedRight3DMatrix(2,:,f), annotatedRight3DMatrix(3,:,f), '-', 'LineWidth', 3, 'Color', greenColor); hold off

            %change view
            view(320, 32);

            xlabel('x');
            ylabel('y');    
            zlabel('z');
            
            %store first axis limits, and set the rest
            if f == 1
                ax = gca;
                xAxis = ax.XLim;
                yAxis = ax.YLim;
                zAxis = ax.ZLim;
            end
            
            padding = [-10 10];
            xlim(xAxis + padding);
            ylim(yAxis + padding);
            zlim(zAxis + [-20 20]);
            
            legend('Landmark Raw Right','Annotated Raw Right');

            drawnow

            frame = getframe(gcf);
            writeVideo(mapseVideo, frame);
        end

        %figure title
        movieTitle = strcat('Raw landmark movie of name: -', name);
        title(movieTitle)

        %cleanup
        close(mapseVideo)
        close(movieFig)

        %% Create movie of annulus though all frames -bezier

        %open mp4
        movieName = strcat(directoryPath, name, '_bezier_annulus_movie.avi');
        mapseVideo = VideoWriter(movieName);
        mapseVideo.FrameRate = 2;
        mapseVideo.Quality = 100;
        open(mapseVideo)

        movieFig = figure('visible','off');

        %loop through the frames
        for f = 1:size(leftLandmarkSplineCurve, 2)

            plot3(rightLandmarkBezierCurve(:,1,f),rightLandmarkBezierCurve(:,2,f),rightLandmarkBezierCurve(:,3,f), 'LineWidth', 3, 'Color', orangeColor); hold on;
            plot3(annotatedRightBezierCurve(:,1,f),annotatedRightBezierCurve(:,2,f),annotatedRightBezierCurve(:,3,f), '-', 'LineWidth', 3, 'Color', greenColor); hold off

            %change view 
            view(320, 32);

            xlabel('x');
            ylabel('y');    
            zlabel('z');
            
            %store first axis limits, and set the rest
            if f == 1
                ax = gca;
                xAxis = ax.XLim;
                yAxis = ax.YLim;
                zAxis = ax.ZLim;
            end
            
            padding = [-10 10];
            xlim(xAxis + padding);
            ylim(yAxis + padding);
            zlim(zAxis + [-20 20]);
            
            legend('Landmark Bezier Right','Annotated Bezier Right');

            drawnow

            frame = getframe(gcf);
            writeVideo(mapseVideo, frame);
        end

        %figure title
        movieTitle = strcat('Bezier interpolation movie of name: -', name);
        title(movieTitle)

        %cleanup
        close(mapseVideo)
        close(movieFig)


        %% Create movie of annulus though all frames -spline

        %open mp4
        movieName = strcat(directoryPath, name, '_spline_annulus_movie.avi');
        mapseVideo = VideoWriter(movieName);
        mapseVideo.FrameRate = 2;
        mapseVideo.Quality = 100;
        open(mapseVideo)

        movieFig = figure('visible','off');

        %loop through the frames
        for f = 1:size(leftLandmarkSplineCurve, 2)

            fnplt(rightLandmarkSplineCurve(f),2); hold on;
            fnplt(annotatedRightSplineCurve(f),2); hold off

            %change view 
            view(320, 32);

            xlabel('x');
            ylabel('y');    
            zlabel('z');
            
            %store first axis limits, and set the rest
            if f == 1
                ax = gca;
                xAxis = ax.XLim;
                yAxis = ax.YLim;
                zAxis = ax.ZLim;
            end
            
            padding = [-10 10];
            xlim(xAxis + padding);
            ylim(yAxis + padding);
            zlim(zAxis + [-20 20]);
            
            legend('Landmark Spline Right','Annotated Spline Right');

            drawnow

            frame = getframe(gcf);
            writeVideo(mapseVideo, frame);
        end

        %figure title
        movieTitle = strcat('Spline interpolation movie of name: -', name);
        title(movieTitle)

        %cleanup
        close(mapseVideo)
        close(movieFig)
        %}
    end
end