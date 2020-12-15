%Statistical plot of results
%Anders Tasken
%Created 21.11. 2020
function StatisticalResultPlots(fileNames, filesPath, mapse_map_name, mapse_reference_map_name, landmark3DMatrix_name, landmarkAnnotated3DMatrix_name)
    
    %% Colors
    blueColor = [0, 0.4470, 0.7410];
    orangeColor = [0.8500, 0.3250, 0.0980];
    yellowColor = [0.9290, 0.6940, 0.1250];
    greenColor = [0.4660, 0.6740, 0.1880];
    lightBlueColor = [0.3010, 0.7450, 0.9330];
    brownColor = [0.6350, 0.0780, 0.1840];
    purpleColor = [0.4940, 0.1840, 0.5560];
    grayColor = [17 17 17]/255;
    
    %% Load landmark variable matrices
    variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/MapseAndErrorMaps');
    mapse_map = load(variablesFilename,mapse_map_name).(mapse_map_name);
    
    variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/MapseReferenceMaps');
    mapse_reference_map = load(variablesFilename,mapse_reference_map_name).(mapse_reference_map_name);

    %% Directory for saving plots
    %create folder for figure
    directoryPath = strcat(filesPath, 'StatisticalPlots/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end
    
    %% Boxplot declaration
    errorCellArray = {};
    errorArray = [];
    
%     %% Iterate over all files
%     %call the MAPSE postprocessing script for each file
%     for f=1:size(fileNames,2)
%         %root name from h5 file
%         [filesPath, name, ~] = fileparts(fileNames(f).name);
%         
%         %load optMapseAngles
%         filename = strcat(filesPath, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
%         optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;
% 
%         %skip iteration if optimal angle is 0 (most likely due to no landmarks)
%         if optMapseAngle == 0
%             fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
%             continue
%         end
%         
%         %load data
%         fileName = strcat(name,'.h5'); 
%         filePath = strcat(filesPath, fileName);
%         hdfdata = HdfImport(filePath);
%         
%         %default voxelsize value
%         pixelCorr = 0.7e-3;
% 
%         %check if voxeldize is in hdfdata
%         if any(strcmp(fieldnames(hdfdata),'a'))
%             pixelCorr = hdfdata.ImageGeometry.voxelsize;
%         end
%         
%         %% Load landmark variable matrices
%         variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/landmarkMatrices_', name);
%         landmark3DMatrix = load(variablesFilename,landmark3DMatrix_name).(landmark3DMatrix_name);
%         landmarkAnnotated3DMatrix = load(variablesFilename,landmarkAnnotated3DMatrix_name).(landmarkAnnotated3DMatrix_name); 
%         
%         %change matrix dim orders if bezier
%         if contains(landmark3DMatrix_name, 'Bezier')
%             landmark3DMatrix = permute(landmark3DMatrix, [2 1 3]);
%             landmarkAnnotated3DMatrix = permute(landmarkAnnotated3DMatrix, [2 1 3]);
%         end
%         
%         %% Compute distance between estimated- and annotated landmark as points in 3D, for all points
%         landmark = reshape(landmark3DMatrix, size(landmark3DMatrix, 1), size(landmark3DMatrix,2) * size(landmark3DMatrix, 3));
%         annotated = reshape(landmarkAnnotated3DMatrix, size(landmarkAnnotated3DMatrix, 1), size(landmarkAnnotated3DMatrix,2) * size(landmarkAnnotated3DMatrix, 3));
%         
%         if ~all(annotated, 'all') || all(isnan(annotated), 'all')
%             continue
%         end
%         
%         %store in cell array
%         errors = (pixelCorr * 1000) .* sqrt(sum((landmark - annotated).^2));
%         errorCellArray{f} = errors; %in mm
%         
%         %store in single dim array
%         errorArray = cat(2, errorArray, errors);
% 
%     end
%     
%     %% Boxplot of error distribuion
%     y = num2cell(1:numel(errorCellArray));
%     x = cellfun(@(x, y) [x(:) y*ones(size(x(:)))], errorCellArray, y, 'UniformOutput', 0); % adding labels to the cells
%     X = vertcat(x{:});
%     
%     boxplotFig = figure; 
%     boxplot(X(:,1), X(:,2), 'symbol', '');
% 
%     title('Boxplot of ditribution of error')
%     xlabel('Patient')
%     ylabel('Error (mm)')
%     
%     %title(strcat(landmark3DMatrix_name, ' - ', landmarkAnnotated3DMatrix_name));
%     
%     %Save figure 
%     boxplotFigName = strcat(directoryPath, landmark3DMatrix_name, '_', landmarkAnnotated3DMatrix_name,'_BoxplotOfError.fig');
%     savefig(boxplotFig, boxplotFigName)
%     
%     %%  Histogram and distribution of error plot
%     %histogram with distribution fit
%     errorHistDistFig = figure; 
%     h = histfit(errorArray, 50, 'gamma');
%     yt = get(gca, 'YTick');
%     set(gca, 'YTick', yt, 'YTickLabel', round(yt/numel(errorArray), 3));
%     
%     h(1).FaceColor = grayColor;
%     h(1).FaceAlpha = .2;
%     h(2).Color = orangeColor;
%     h(2).LineWidth = 5.0;
%     
%     title('Histogram of error with gamma distribution fit')
%     xlabel('Error (mm)')
%     ylabel('Density')
%     
%     %title(strcat(landmark3DMatrix_name, ' - ', landmarkAnnotated3DMatrix_name));
%     
%     %Save figure 
%     errorHistDistFigName = strcat(directoryPath, landmark3DMatrix_name,'_', landmarkAnnotated3DMatrix_name,'_ErrorHistogramDistibutionPlot.fig');
%     savefig(errorHistDistFig, errorHistDistFigName)
%     
%     %% Shaded distribution fit of error
%     errorDistFig = figure;
%     plot_histogram_shaded(errorArray(~isnan(errorArray)),'Alpha',0.3);
%     
%     xlabel('Error (mm)')
%     ylabel('Density')
%     title('Distribution fit of error')
%     
%     %title(strcat(landmark3DMatrix_name, ' - ', landmarkAnnotated3DMatrix_name));
%     
%     %Save figure 
%     errorDistFigName = strcat(directoryPath, landmark3DMatrix_name,'_', landmarkAnnotated3DMatrix_name, '_ErrorDistibutionPlot.fig');
%     savefig(errorDistFig, errorDistFigName)
%     
    %% Bland Altman plot of MAPSE error
    %create array of mapse value
    mapse_raw_array = zeros(length(mapse_map), 1);
    mapse_reference_array = zeros(length(mapse_map), 1);
    
    i = 1;
    for k = keys(mapse_map)
        mapse_raw_array(i) = mapse_map(k{1})*1000;
        mapse_reference_array(i) = mapse_reference_map(k{1})*1000;
        i = i + 1;
    end
    
    % Generate Blant Altman Figure
    if length(mapse_reference_array) > 1 && length(mapse_raw_array) > 1
        blandAltmanFig = figure;
        BlandAltmanPlot(mapse_reference_array, mapse_raw_array, 'plotCI', false, 'plot_x_mean', false);

        title('Bland Altman plot of reference- and estimated MAPSE values')
        xlabel('Reference MAPSE Measure [mm]')
        ylabel('Difference Between Measures [mm]')

        %title(strcat(mapse_map_name, ' - ', mapse_annotated_map_name));

        %Save figure 
        blandAltmanFigName = strcat(directoryPath, mapse_map_name, '_', mapse_reference_map_name, '_BlandAltmanPlot.fig');
        savefig(blandAltmanFig, blandAltmanFigName)
    end
end