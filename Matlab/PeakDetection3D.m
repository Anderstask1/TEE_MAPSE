function [left_peaks, right_peaks] = PeakDetection3D(com_left_corr, com_right_corr, filesPath, name, savePeakPlot)
    %% Peak computation
    % Left
    %find max and min
    [es_left_peak, es_left_frame] = min(com_left_corr(3,:));
    [ed_left_peak, ed_left_frame] = max(com_left_corr(3,:));
    
    %save in matrix es - ed
    left_peaks = [es_left_peak, es_left_frame; ed_left_peak, ed_left_frame];
    
    %Right
    %find max and min
    [es_right_peak, es_right_frame] = min(com_right_corr(3,:));
    [ed_right_peak, ed_right_frame] = max(com_right_corr(3,:));
    
    %save in matrix es - ed
    right_peaks = [es_right_peak, es_right_frame; ed_right_peak, ed_right_frame];
    
    %% Plot
    %plot z-value of CoM as a function of time/frame
    if savePeakPlot
    
        peakFig = figure('visible','off');
        
        % Left
        plot(com_left_corr(3,:));

        hold on

        plot(es_left_frame, es_left_peak, 'r*');

        plot(ed_left_frame, ed_left_peak, 'r*');

        % Right
        plot(com_right_corr(3,:));

        plot(es_right_frame, es_right_peak, 'r*');

        plot(ed_right_frame, ed_right_peak, 'r*');
        
        hold off
        
        %save
        
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
        
        %save figure
        figName = strcat(directoryPath, name,'_peak_detection.png');
        saveas(peakFig, figName);
   
    end
end