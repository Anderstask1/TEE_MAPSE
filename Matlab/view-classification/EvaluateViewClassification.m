%Evaluation of classification results
%Started 4.02.2021
%Author: Anders Tasken

addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab')
addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab/dirParsing')


%% Evaluate classification compared to annotation - 2D data
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/ResNext/';

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

true = 0;
false = 0;

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);
    
    %show progress
    fprintf('Classified: %d/%d. \n', f, size(fileNames,2));

    % Load data
    inputName = [path name];

    data = HdfImport(inputName);

    annotatedClass = data.reference(1);

    probArray = data.cardiac_view_probabilities;
    
    %find most index of the element with highest value
    [~, classifiedClass] = max(probArray);
    classifiedClass = classifiedClass - 1; %zero index
    
    if annotatedClass == classifiedClass
        true = true + 1;
    else
        false = false + 1;
    end

end

fprintf('Classification hit rate: %0.1f%% \n',true/size(fileNames,2) * 100);
fprintf('Classification miss rate: %0.1f%% \n',false/size(fileNames,2) * 100);

%% Create struct of classified views by model - 3D data
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/';

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

classifiedStruct = struct();
annotatedStruct = struct();
probArrayStruct = struct();

classifiedArray = nan(1, 37);

referenceArray = nan(1, 37);

twoChamberArray = zeros(1, 37);
fourChamberArray = zeros(1, 37);
alaxArray = zeros(1, 37);
otherArray = zeros(1, 37);

true = 0;
false = 0;

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %show progress
    fprintf('Classified: %d/%d. \n', f, size(fileNames,2));
    
    disp(name)
    
    %parse filename and rotation
    stringSplit = split(name, '_');
    fileName = stringSplit{1};

    % Load data
    inputName = [path name];

    data = HdfImport(inputName);
    
    fieldNames = fieldnames(data.MVCenterRotatedVolumes);
    
    for i = 1 : length(fieldNames)
        
        disp(fieldNames{i})
        
        stringSplit = split(fieldNames{i}, '_');
        rotationDegree = str2num(stringSplit{3});
        
        %probability classification array
        probArray = data.MVCenterRotatedVolumes.(fieldNames{i}).cardiac_view_probabilities;
        
        reference = data.MVCenterRotatedVolumes.(fieldNames{i}).reference;
        
        otherArray(rotationDegree/10+1) = probArray(1);
        twoChamberArray(rotationDegree/10+1) = probArray(2);
        fourChamberArray(rotationDegree/10+1) = probArray(3);
        alaxArray(rotationDegree/10+1) = probArray(4);
        
        [class_conf, class_idx] = max(probArray);
        
        if class_conf > 0.9
            classifiedArray(i) = class_idx - 1;
        end
        
        referenceArray(i) = reference(1);
        
    end
    
    probArrayStruct.(fileName).fourChamber = twoChamberArray;
    probArrayStruct.(fileName).twoChamber = fourChamberArray;
    probArrayStruct.(fileName).alax = alaxArray;
    probArrayStruct.(fileName).other = otherArray;
    
    classifiedStruct.(fileName) = classifiedArray;
    
    annotatedStruct.(fileName) = referenceArray;
        
end

%% Statistics
fn = fieldnames(classifiedStruct);

true = 0;
false = 0;
noise = 0;
true_noise = 0;

for i = 1 : numel(fn)
    for j = 1 : length(annotatedStruct.(fn{i}))
        if  classifiedStruct.(fn{i})(j) == 0
            noise = noise + 1;
            if annotatedStruct.(fn{i})(j) == 0
                true_noise = true_noise + 1;
            end
        end
        if ~isnan(classifiedStruct.(fn{i})(j))
            if annotatedStruct.(fn{i})(j) == classifiedStruct.(fn{i})(j)
                true = true + 1;
            else 
                false = false +1;
            end
        end
    end
end

fprintf('Classification hit rate: %0.1f%% \n',true/(true + false) * 100);
fprintf('Noise hit rate: %0.1f%% \n',true_noise/(noise) * 100);
fprintf('Noise rate: %0.1f%% \n',noise/(true + false) * 100);

%% Plot results
files = fieldnames(probArrayStruct);

for f = 1 : numel(files)
   
   figure; hold on;
   plot(probArrayStruct.(files{f}).fourChamber);
   plot(probArrayStruct.(files{f}).twoChamber);
   plot(probArrayStruct.(files{f}).alax);
   plot(probArrayStruct.(files{f}).other);
   title(files{f});
   legend('4C', '2C', 'ALAX', 'Other');
end