%Evaluation of classification results
%Started 4.02.2021
%Author: Anders Tasken

addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab')
addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab/dirParsing')


%% Create struct of annotated views
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated/';
foldersStruct = dir(fullfile(folderPath,'*'));
folderNames = setdiff({foldersStruct([foldersStruct.isdir]).name},{'.','..'});

annotated_struct = struct();

for i = 1:numel(folderNames)
    
    filesPath = strcat(folderPath, folderNames{i}, '/');
    
    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');
    
    %call the split script for each file
    for f=1:size(fileNames,2)
        
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);
        
         %show progress
        fprintf('Annotated %s: %d/%d. \n', folderNames{i}, f, size(fileNames,2));

        %% Load data
        inputName = [path name];

        data = HdfImport(inputName);
        
        classIdx = data.reference;
        
        annotated_struct.(name) = classIdx(1);
    
    end
end


%% Create struct of classified views by model
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/';

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

classified_struct = struct();

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Classified: %d/%d. \n', f, size(fileNames,2));

    %% Load data
    inputName = [path name];

    data = HdfImport(inputName);

    classIdx = data.detected_cardiac_view;

    classified_struct.(name) = classIdx;

end

fn = fieldnames(classified_struct);

true = 0;
false = 0;

for i = 1 : numel(fn)
    if annotated_struct.(fn{1}) == classified_struct.(fn{1}) 
        true = true + 1;
    else 
        false = false +1;
    end
end

fprintf('Classification hit rate: %d%% \n',true/numel(fn) * 100);
fprintf('Classification miss rate: %d%% \n',false/numel(fn) * 100);