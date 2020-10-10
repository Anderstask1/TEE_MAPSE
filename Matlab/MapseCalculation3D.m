function [mapse_left, mapse_right] = MapseCalculation(left_peaks, right_peaks)

    %% Compute distance between peaks
    % Left
    mapse_left = left_peaks(2,1) - left_peaks(1,1);
    
    % Right
    mapse_right = right_peaks(2,1) - right_peaks(1,1);
end