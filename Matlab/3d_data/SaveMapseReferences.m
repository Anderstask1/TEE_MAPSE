%Save clinical reference MAPSE values in matlab workspace variable
function SaveMapseReferences(path)
    
    %% Apical 4 chamber	
    %Inferoseptal
    mapse_4c_inf_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_4c_inf_reference_map('J65BP12E') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1A0') = 9.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1I4') = 8.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1R0') = 9.0 / 1000;
    mapse_4c_inf_reference_map('J65BP22K') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2AQ') = 5.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2IQ') = 13.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2QK') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP33A') = 8.0 / 1000;
    mapse_4c_inf_reference_map('J65BP3A4') = 6.0 / 1000;
    
    mapse_4c_inf_reference_map('J65BP12G') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1A4') = 9.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1I6') = 8.0 / 1000;
    mapse_4c_inf_reference_map('J65BP1R2') = 9.0 / 1000;
    mapse_4c_inf_reference_map('J65BP22M') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2B0') = 5.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2IU') = 13.0 / 1000;
    mapse_4c_inf_reference_map('J65BP2QM') = 10.0 / 1000;
    mapse_4c_inf_reference_map('J65BP338') = 8.0 / 1000;
    mapse_4c_inf_reference_map('J65BP3A8') = 6.0 / 1000;
    
    %Anterolateral
    mapse_4c_ant_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_4c_ant_reference_map('J65BP12E') = 16.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1A0') = 15.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1I4') = 8.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1R0') = 8.0 / 1000;
    mapse_4c_ant_reference_map('J65BP22K') = 9.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2AQ') = 2.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2IQ') = 13.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2QK') = 21.0 / 1000;
    mapse_4c_ant_reference_map('J65BP33A') = 7.0 / 1000;
    mapse_4c_ant_reference_map('J65BP3A4') = 7.0 / 1000;
    
    mapse_4c_ant_reference_map('J65BP12G') = 16.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1A4') = 15.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1I6') = 8.0 / 1000;
    mapse_4c_ant_reference_map('J65BP1R2') = 8.0 / 1000;
    mapse_4c_ant_reference_map('J65BP22M') = 9.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2B0') = 2.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2IU') = 13.0 / 1000;
    mapse_4c_ant_reference_map('J65BP2QM') = 21.0 / 1000;
    mapse_4c_ant_reference_map('J65BP338') = 7.0 / 1000;
    mapse_4c_ant_reference_map('J65BP3A8') = 7.0 / 1000;
    
    %% Apical 2 chamber	
    %inferior
    mapse_2c_inf_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_2c_inf_reference_map('J65BP12E') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1A0') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1I4') = 9.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1R0') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP22K') = 10.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2AQ') = 4.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2IQ') = 12.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2QK') = nan;
    mapse_2c_inf_reference_map('J65BP33A') = 7.0 / 1000;
    mapse_2c_inf_reference_map('J65BP3A4') = 7.0 / 1000;
    
    mapse_2c_inf_reference_map('J65BP12G') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1A4') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1I6') = 9.0 / 1000;
    mapse_2c_inf_reference_map('J65BP1R2') = 11.0 / 1000;
    mapse_2c_inf_reference_map('J65BP22M') = 10.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2B0') = 4.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2IU') = 12.0 / 1000;
    mapse_2c_inf_reference_map('J65BP2QM') = nan;
    mapse_2c_inf_reference_map('J65BP338') = 7.0 / 1000;
    mapse_2c_inf_reference_map('J65BP3A8') = 7.0 / 1000;
    
    %anterior
    mapse_2c_ant_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_2c_ant_reference_map('J65BP12E') = 12.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1A0') = 9.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1I4') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1R0') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP22K') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2AQ') = 3.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2IQ') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2QK') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP33A') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP3A4') = 6.0 / 1000;
    
    mapse_2c_ant_reference_map('J65BP12G') = 12.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1A4') = 9.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1I6') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP1R2') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP22M') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2B0') = 3.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2IU') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP2QM') = 8.0 / 1000;
    mapse_2c_ant_reference_map('J65BP338') = 7.0 / 1000;
    mapse_2c_ant_reference_map('J65BP3A8') = 6.0 / 1000;
    
    %% Apical long axis (3 chamber)	
    %inferolateral
    mapse_3c_inf_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_3c_inf_reference_map('J65BP12E') = 13.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1A0') = 8.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1I4') = 10.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1R0') = 10.0 / 1000;
    mapse_3c_inf_reference_map('J65BP22K') = 8.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2AQ') = 3.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2IQ') = 12.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2QK') = 20.0 / 1000;
    mapse_3c_inf_reference_map('J65BP33A') = 9.0 / 1000;
    mapse_3c_inf_reference_map('J65BP3A4') = 8.0 / 1000;
    
    mapse_3c_inf_reference_map('J65BP12G') = 13.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1A4') = 8.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1I6') = 10.0 / 1000;
    mapse_3c_inf_reference_map('J65BP1R2') = 10.0 / 1000;
    mapse_3c_inf_reference_map('J65BP22M') = 8.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2B0') = 3.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2IU') = 12.0 / 1000;
    mapse_3c_inf_reference_map('J65BP2QM') = 20.0 / 1000;
    mapse_3c_inf_reference_map('J65BP338') = 9.0 / 1000;
    mapse_3c_inf_reference_map('J65BP3A8') = 8.0 / 1000;
    
    %anteroseptal
    mapse_3c_ant_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_3c_ant_reference_map ('J65BP12E') = 10.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1A0') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1I4') = 9.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1R0') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP22K') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2AQ') = 4.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2IQ') = 6.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2QK') = 5.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP33A') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP3A4') = 6.0 / 1000;
    
    mapse_3c_ant_reference_map ('J65BP12G') = 10.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1A4') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1I6') = 9.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP1R2') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP22M') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2B0') = 4.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2IU') = 6.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP2QM') = 5.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP338') = 7.0 / 1000;
    mapse_3c_ant_reference_map ('J65BP3A8') = 6.0 / 1000;
    
    %% Create map of mean and SD of all patients
    mapse_mean_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    mapse_mean_sd_reference_map = containers.Map('KeyType', 'char', 'ValueType', 'double');
    for k = keys(mapse_4c_inf_reference_map)
        mapseArray = [mapse_4c_inf_reference_map(k{1}), mapse_4c_ant_reference_map(k{1}),...
                      mapse_2c_inf_reference_map(k{1}), mapse_2c_ant_reference_map(k{1}),...
                      mapse_3c_inf_reference_map(k{1}), mapse_3c_ant_reference_map(k{1})];
        mapseMean = nanmean(mapseArray);
        mapseSD = nanstd(mapseArray);
        mapse_mean_reference_map(k{1}) = mapseMean;
        mapse_mean_sd_reference_map(k{1}) = mapseSD;
    end
    
    %% Save workspace variables
    %create folder for figure
    directoryPath = strcat(path, 'LandmarkMatricesVariables/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end

    variablesFilename = strcat(directoryPath, 'MapseReferenceMaps');
    save(variablesFilename, ...
        'mapse_4c_inf_reference_map','mapse_4c_ant_reference_map',...
        'mapse_2c_inf_reference_map', 'mapse_2c_ant_reference_map',...
        'mapse_3c_inf_reference_map', 'mapse_3c_ant_reference_map',...
        'mapse_mean_reference_map', 'mapse_mean_sd_reference_map');
end