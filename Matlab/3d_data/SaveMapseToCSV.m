%Save computed MAPSE values as CSV file
%Author: Anders Tasken
function SaveMapseToCSV(filesPath)
    variablesFilename = strcat(filesPath, 'LandmarkMatricesVariables/MapseAndErrorMaps');
    load(variablesFilename,...
        'mapse_raw_left_map', 'mapse_raw_right_map', 'mapse_bezier_left_map', 'mapse_bezier_right_map',...
        'mapse_annotated_left_map', 'mapse_annotated_right_map', 'mapse_rejected_left_map', 'mapse_rejected_right_map', 'mapse_mean_rejected_map', ...
        'annotated_error1_left_map', 'annotated_error2_left_map', 'annotated_error1_right_map', 'annotated_error2_right_map', ...
        'annotated_error1_rejected_left_map', 'annotated_error2_rejected_left_map', 'annotated_error1_rejected_right_map',...
        'annotated_error2_rejected_right_map', 'mean_error1_map', 'mean_error2_map');
    
    [rawLeftMD, rawLeftSD] = MDandSD(mapse_raw_left_map, mapse_annotated_left_map);
    [rawRightMD, rawRightSD] = MDandSD(mapse_raw_right_map, mapse_annotated_right_map);
    
    [rejectedLeftMD, rejectedLeftSD] = MDandSD(mapse_rejected_left_map, mapse_annotated_left_map);
    [rejectedRightMD, rejectedRightSD] = MDandSD(mapse_rejected_right_map, mapse_annotated_right_map);
    
    [bezierLeftMD, bezierLeftSD] = MDandSD(mapse_bezier_left_map, mapse_annotated_left_map);
    [bezierRightMD, bezierRightSD] = MDandSD(mapse_bezier_right_map, mapse_annotated_right_map);

    rowNames = {'Left Landmark Detector'; 'Right Landmark Detector'; 'Outlier-rejected Left Landmark Detector'; 'Outlier-rejected Right Landmark Detector'; ...
                'Bezier of Left Landmark Detector'; 'Bezier of Right Landmark Detector'};
    
    MeanDifferenceMAPSE = [rawLeftMD; rawRightMD; rejectedLeftMD; rejectedRightMD; bezierLeftMD; bezierRightMD];
    StandardDeviationMAPSE = [rawLeftSD; rawRightSD; rejectedLeftSD; rejectedRightSD; bezierLeftSD; bezierRightSD];
            
    T = table(MeanDifferenceMAPSE, StandardDeviationMAPSE, 'RowNames', rowNames);
    tableName = strcat(filesPath, 'MAPSE_MD_SD.csv');
    writetable(T,tableName, 'WriteRowNames', true, 'Delimiter', ',');
    
end