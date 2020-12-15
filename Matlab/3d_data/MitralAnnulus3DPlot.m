function MitralAnnulus3DPlot(fileNames, plotnames)
    %call the script for each plot

    for i = 1 : length(plotnames)
        %call the script for each file
        for f=1:size(fileNames,2)
            %root name from h5 file
            [path, name, ~] = fileparts(fileNames(f).name);
            
            %load optMapseAngles
            filename = strcat(path, 'Optimal_angle_mv-center-computation/', name, '/optMapseAngle.mat');
            optMapseAngle = load(filename, 'optMapseAngle').optMapseAngle;

            %skip iteration if optimal angle is 0 (most likely due to no landmarks)
            if optMapseAngle == 0
                fprintf('Optimal mapse angle is 0, skipping iteration with file %s \n', name);
                continue
            end
            
            figname = strcat(path, 'PostProcessMVAnnulusFigures/', name, '/', name, plotnames{i}, '.fig');
            openfig(figname, 'visible');
        end
    end
end