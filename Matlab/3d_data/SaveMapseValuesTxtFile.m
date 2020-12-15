%Save computed MAPSE values, and landmark errors, as text file
%Author: Anders Tasken
function SaveMapseValuesTxtFile(filesPath)

    variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/MapseAndErrorMaps');
    load(variablesFilename,...
        'mapse_raw_left_map', 'mapse_raw_right_map', 'mapse_bezier_left_map', 'mapse_bezier_right_map',...
        'mapse_annotated_left_map', 'mapse_annotated_right_map', 'mapse_rejected_left_map', 'mapse_rejected_right_map', 'mapse_mean_rejected_map', ...
        'annotated_error1_left_map', 'annotated_error2_left_map', 'annotated_error1_right_map', 'annotated_error2_right_map', ...
        'annotated_error1_rejected_left_map', 'annotated_error2_rejected_left_map', 'annotated_error1_rejected_right_map',...
        'annotated_error2_rejected_right_map', 'mean_error1_map', 'mean_error2_map');
    
    variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/MapseReferenceMaps');
    load(variablesFilename,...
        'mapse_4c_inf_reference_map','mapse_4c_ant_reference_map',...
        'mapse_2c_inf_reference_map', 'mapse_2c_ant_reference_map',...
        'mapse_3c_inf_reference_map', 'mapse_3c_ant_reference_map',...
        'mapse_mean_reference_map', 'mapse_mean_sd_reference_map');

    %Save results as txt file table
    resultsName = strcat(filesPath, 'MAPSE-values', '.txt');
    fileID = fopen(resultsName,'w');
    
    
    
    fprintf(fileID,'\n\n\n%s\n', '----------------- MAPSE Error -----------------');
    fprintf(fileID,'%s\n\n', 'Mean difference +- standard deviation');
    
    fprintf(fileID,'%s\n', 'Mean reference - Raw left and right:');
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_raw_left_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n', rawLeftMD, rawLeftSD);
    [rawRightMD, rawRightSD] = MDandSD(mapse_raw_right_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n\n\n\n', rawRightMD, rawRightSD);
    
    fprintf(fileID,'%s\n', 'Mean reference - Rejected left and right:');
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_rejected_left_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n', rawLeftMD, rawLeftSD);
    [rawRightMD, rawRightSD] = MDandSD(mapse_rejected_right_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n\n\n\n', rawRightMD, rawRightSD);
    
    fprintf(fileID,'%s\n', 'Mean reference - Bezier left and right:');
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_bezier_left_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n', rawLeftMD, rawLeftSD);
    [rawRightMD, rawRightSD] = MDandSD(mapse_bezier_right_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n\n\n\n', rawRightMD, rawRightSD);
    
    fprintf(fileID,'%s\n', 'Mean reference - Annotated left and right:');
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_annotated_left_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n', rawLeftMD, rawLeftSD);
    [rawRightMD, rawRightSD] = MDandSD(mapse_annotated_right_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n\n\n\n', rawRightMD, rawRightSD);
    
    fprintf(fileID,'%s\n', 'Mean reference - Mean of left and right:');
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_mean_rejected_map, mapse_mean_reference_map);
    fprintf(fileID,'%.4f +- %.4f\n', rawLeftMD, rawLeftSD);
    
    
    
    fprintf(fileID,'\n\n\n%s\n\n', 'MAPSE difference for each file');
    for k = keys(mapse_raw_left_map)
        mapseReference = mapse_mean_reference_map(k{1})*1000;
        mapseEstimate = mapse_raw_left_map(k{1})*1000;
        fprintf(fileID,'\n%s %s %.4f\n', k{1}, 'MAPSE difference:', abs(mapseReference - mapseEstimate));
    end
    
    
    fprintf(fileID,'\n\n\n%s\n', '----------------- MAPSE -----------------');
    fprintf(fileID,'%s\n\n', 'Mean +- standard deviation');
    
    % Reference mean mapse and standard deviation of landmarks
    fprintf(fileID,'%s\n\n', '----------------- REFERENCE -----------------');
    
    % Reference mean mapse and standard deviation for all patients
    fprintf(fileID,'\n\n\n%s\n', 'Mean MAPSE and SD for all patients');
    for k = keys(mapse_mean_reference_map)
        mapseMean = mapse_mean_reference_map(k{1})*1000;
        mapseSD = mapse_mean_sd_reference_map(k{1})*1000;
        
        fprintf(fileID,'\n%s %s\n', k{1}, 'reference mean:');
        fprintf(fileID,'%.4f +- %.4f\n', mapseMean, mapseSD);
    end
   
    
    fprintf(fileID,'\n\n\n\n%s', '----------------- ESTIMATIONS -----------------');
    
    % Mean MAPSE and SD for different estimation techniques
    fprintf(fileID,'\n\n\n\n%s\n', 'Raw left and right:');
    [mapseMeanLeft, mapseSDLeft] = landmarkMeanAndSD(mapse_raw_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanLeft, mapseSDLeft);
    
    [mapseMeanRight, mapseSDRight] = landmarkMeanAndSD(mapse_raw_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanRight, mapseSDRight);
    
    fprintf(fileID,'\n%s\n', 'Rejected left and right:');
    [mapseMeanRejectedLeft, mapseSDRejectedLeft] = landmarkMeanAndSD(mapse_rejected_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanRejectedLeft, mapseSDRejectedLeft);
    
    [mapseMeanRejectedRight, mapseSDRejectedRight] = landmarkMeanAndSD(mapse_rejected_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanRejectedRight, mapseSDRejectedRight);
    
    fprintf(fileID,'\n%s\n', 'Bezier left and right:');
    [mapseMeanRejectedLeft, mapseSDBezierLeft] = landmarkMeanAndSD(mapse_bezier_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanRejectedLeft, mapseSDBezierLeft);
    
    [mapseMeanRejectedRight, mapseSDBezierRight] = landmarkMeanAndSD(mapse_bezier_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanRejectedRight, mapseSDBezierRight);
    
    fprintf(fileID,'\n%s\n', 'Mean of left and right:');
    [mapseMeanLeftRightMean, mapseSDLeftRightMean] = landmarkMeanAndSD(mapse_mean_rejected_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanLeftRightMean, mapseSDLeftRightMean);
    
    
    fprintf(fileID,'\n\n\n\n%s\n', 'Annotated left and right:');
    [mapseMeanAnnotatedLeft, mapseSDAnnotatedLeft] = landmarkMeanAndSD(mapse_annotated_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanAnnotatedLeft, mapseSDAnnotatedLeft);
    
    [mapseMeanAnnotatedRight, mapseSDAnnotatedRight] = landmarkMeanAndSD(mapse_annotated_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', mapseMeanAnnotatedRight, mapseSDAnnotatedRight);
    

    % Estimated Raw Left mean mapse and standard deviation for all patients
    fprintf(fileID,'\n\n\n%s\n', 'Mean MAPSE and SD for all patients');
    for k = keys(mapse_raw_left_map)
        mapseMean = mapse_raw_left_map(k{1})*1000;
        mapseSD = mapse_raw_left_map(k{1})*1000;
        
        fprintf(fileID,'\n%s %s\n', k{1}, 'raw left mean:');
        fprintf(fileID,'%.4f +- %.4f\n', mapseMean, mapseSD);
    end
    
    
    
    
    
    fprintf(fileID,'\n\n\n%s\n', '----------------- Landmark error w.r.t. annotations -----------------');
    
    fprintf(fileID,'%s\n\n', 'Mean error +- standard deviation');
    
    %Mean error and standard deviation of landmarks
    fprintf(fileID,'\n%s\n', 'Raw left and right:');
    [meanErrorLeft, standardDeviationLeft] = landmarkMeanAndSD(annotated_error1_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', meanErrorLeft, standardDeviationLeft);
    
    [meanErrorRight, standardDeviationRight] = landmarkMeanAndSD(annotated_error2_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', meanErrorRight, standardDeviationRight);
    
    fprintf(fileID,'\n%s\n', 'Rejected left and right:');
    [meanErrorRejectedLeft, standardDeviationRejectedLeft] = landmarkMeanAndSD(annotated_error1_rejected_left_map);
    fprintf(fileID,'%.4f +- %.4f\n', meanErrorRejectedLeft, standardDeviationRejectedLeft);
    
    [meanErrorRejectedRight, standardDeviationRejectedRight] = landmarkMeanAndSD(annotated_error2_rejected_right_map);
    fprintf(fileID,'%.4f +- %.4f\n', meanErrorRejectedRight, standardDeviationRejectedRight);
    
    fprintf(fileID,'\n%s\n', 'Mean of left and right:');
    [meanErrorLeftRightMean, standardDeviationLeftRightMean] = landmarkMeanAndSD(mean_error1_map);
    fprintf(fileID,'%.4f +- %.4f\n\n\n', meanErrorLeftRightMean, standardDeviationLeftRightMean);
    
    
    
%     fprintf(fileID,'\n\n\n%s\n', '----------------- MAPSE -----------------');
%     
%     fprintf(fileID,'%s\n', 'left-right values from raw landmarks');
% 
%     for key = keys(mapse_raw_left_map)
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_raw_left_map(key{1})*1000, abs(mapse_raw_left_map(key{1}) - mapse_annotated_left_map(key{1}))*1000);
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_raw_right_map(key{1})*1000, abs(mapse_raw_right_map(key{1}) - mapse_annotated_right_map(key{1}))*1000);
%     end
%     
%     %---rejected--- landmark values
%     fprintf(fileID,'\n\n%s\n', 'MAPSE left-right values from rejected landmarks');
% 
%     for key = keys(mapse_rejected_left_map)
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_rejected_left_map(key{1})*1000, abs(mapse_rejected_left_map(key{1}) - mapse_annotated_left_map(key{1}))*1000);
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_rejected_right_map(key{1})*1000, abs(mapse_rejected_right_map(key{1}) - mapse_annotated_right_map(key{1}))*1000);
%     end
% 
%     % ---bezier--- interpolation values
%     fprintf(fileID,'\n\n%s\n', 'MAPSE left-right values from Bezier interpolation');
% 
%     for key = keys(mapse_bezier_left_map)
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_bezier_left_map(key{1})*1000, abs(mapse_bezier_left_map(key{1}) - mapse_annotated_left_map(key{1}))*1000);
%         fprintf(fileID,'%s MAPSE: %f mm - ERROR: %f mm\n', key{1}, mapse_bezier_right_map(key{1})*1000, abs(mapse_bezier_right_map(key{1}) - mapse_annotated_right_map(key{1}))*1000);
%     end
% 
%     % ---annotated--- interpolation values
%     fprintf(fileID,'\n\n%s\n', 'MAPSE left-right values from Annotated landmarks');
% 
%     for key = keys(mapse_annotated_left_map)
%         fprintf(fileID,'%s: %f mm\n', key{1}, mapse_annotated_left_map(key{1})*1000);
%         fprintf(fileID,'%s: %f mm\n', key{1}, mapse_annotated_right_map(key{1})*1000);
%     end
%     
%     % ---mean and rejected--- landmark values
%     fprintf(fileID,'\n\n%s\n', 'MAPSE values from mean rejected landmarks');
% 
%     for key = keys(mapse_mean_rejected_map)
%         fprintf(fileID,'%s: %f mm\n', key{1}, mapse_mean_rejected_map(key{1})*1000);
%     end
%     
    fprintf(fileID,'\n\n\n%s\n', '----------------- ERROR -----------------');
    
    %left ---error annotated--- values
    fprintf(fileID,'%s\n', 'Mean landmarks left-left from annotation');

    for key = keys(annotated_error1_left_map)
        fprintf(fileID,'%s: %f mm\n', key{1}, annotated_error1_left_map(key{1})*1000);
    end

    %right ---error annotated--- values
    fprintf(fileID,'\n\n%s\n', 'Mean landmarks right-right error  from annotation');
    for key = keys(annotated_error1_right_map)
        fprintf(fileID,'%s: %f mm\n', key{1}, annotated_error2_right_map(key{1})*1000);
    end
    
    %left ---error rejected annotated--- values
    fprintf(fileID,'\n\n%s\n', 'Mean rejected landmarks left-left error from annotation');

    for key = keys(annotated_error1_rejected_left_map)
        fprintf(fileID,'%s: %f mm\n', key{1}, annotated_error1_rejected_left_map(key{1})*1000);
    end

    %right ---error rejected annotated--- values
    fprintf(fileID,'\n\n%s\n', 'Mean rejected landmarks right-right error from annotation');
    for key = keys(annotated_error1_rejected_right_map)
        fprintf(fileID,'%s: %f mm\n', key{1}, annotated_error2_rejected_right_map(key{1})*1000);
    end
    
    %left ---error mean annotated--- values
    fprintf(fileID,'\n\n%s\n', 'Mean mean landmarks mean-mean error from annotation');

    for key = keys(mean_error1_map)
        fprintf(fileID,'%s: %f mm\n', key{1}, (mean_error1_map(key{1}) + mean_error2_map(key{1}))*500);
    end
    
    fclose(fileID);
end

function [landmarkMean, landmarkStandardDeviation] = landmarkMeanAndSD(landmark_map)

    landmarkKeys = keys(landmark_map);
    landmarkArray = zeros(size(landmark_map));
    
    for i = 1 : length(landmark_map)
        landmarkArray(i) = landmark_map(landmarkKeys{i})*1000;
    end
    
    landmarkArray = landmarkArray(~isnan(landmarkArray));
    
    landmarkMean = mean(landmarkArray);
    landmarkStandardDeviation = std(landmarkArray);
end