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

%% Create struct of classified views by model - 3D data - classification
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
        fourChamberArray(rotationDegree/10+1) = probArray(2);
        twoChamberArray(rotationDegree/10+1) = probArray(3);
        alaxArray(rotationDegree/10+1) = probArray(4);
        
        [class_conf, class_idx] = max(probArray);
        
        if class_conf > 0.9
            classifiedArray(i) = class_idx - 1;
        end
        
        referenceArray(i) = reference(1);
        
    end
    
    probArrayStruct.(fileName).fourChamber = fourChamberArray;
    probArrayStruct.(fileName).twoChamber = twoChamberArray;
    probArrayStruct.(fileName).alax = alaxArray;
    probArrayStruct.(fileName).other = otherArray;
    
    classifiedStruct.(fileName) = classifiedArray;
    
    annotatedStruct.(fileName) = referenceArray;
        
end

%% Statistics - classification
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

%% Plot results - classification
files = fieldnames(probArrayStruct);

for f = 1 : numel(files)
   
   figure; hold on;
   plot(probArrayStruct.(files{f}).fourChamber);
   plot(probArrayStruct.(files{f}).twoChamber);
   plot(probArrayStruct.(files{f}).alax);
   plot(probArrayStruct.(files{f}).other);
   title(files{f});
   legend('Other', '4C', '2C', 'ALAX');
end


%% Create struct of classified views by model - 3D data - regression
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentClassifyingData/';
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated/';

%degree of rotation between each 2d image
stepDegree = 10;

%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

classifiedStruct = struct();
%annotatedStruct = struct();
probArrayStruct = struct();

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);
    
    %only files in given folder
    if contains(name, '\')
        continue
    end

    %show progress    
    disp(name)
    
    %parse filename and rotation
    stringSplit = split(name, '_');
    fileName = stringSplit{1};

    % Load data
    inputName = [path name];
    filename = strcat(inputName, '.h5');

    %data = HdfImport(inputName);
    
    %fieldNames = fieldnames(data.MVCenterRotatedVolumes);

    infoMVCenterRotatedVolumes = h5info(filename, '/MVCenterRotatedVolumes');
    rotations = length(infoMVCenterRotatedVolumes.Groups);
    
    classifiedArray = nan(1, rotations);
    %referenceArray = nan(1, rotations);
    twoChamberArray = zeros(1, rotations);
    fourChamberArray = zeros(1, rotations);
    alaxArray = zeros(1, rotations);
    
    for i = 1 : stepDegree : rotations
        
        fieldName = strcat('rotated_by_', num2str(i-1), '_degrees');
        
        ds = strcat('/MVCenterRotatedVolumes/', fieldName, '/cardiac_view_probabilities/');
        try
            probArray = h5read(filename, ds);
        catch
            disp('fuck')
        end
        %ds = strcat('/MVCenterRotatedVolumes/', fieldName, '/reference/');
        %reference = h5read(filename, ds);
        
        fourChamberArray(i) = probArray(1);
        twoChamberArray(i) = probArray(2);
        alaxArray(i) = probArray(3);
        
        [class_conf, class_idx] = max(probArray);
        
        %
        if class_conf > 0.4
            classifiedArray(i) = class_idx;
        else
            classifiedArray(i) = 0;
        end
        %{
        classifiedArray(i) = class_idx;
        %}
        
        %referenceArray(i) = reference(1);
        
    end
    
    probArrayStruct.(fileName).fourChamber = fourChamberArray;
    probArrayStruct.(fileName).twoChamber = twoChamberArray;
    probArrayStruct.(fileName).alax = alaxArray;
    
    classifiedStruct.(fileName) = classifiedArray;
    
    %annotatedStruct.(fileName) = referenceArray;
        
end


%% Create struct of classified views by model - 3D data - regression
folderPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_data_annotated/test/';
%find all .h5 files
fileNames = parseDirectoryLinux(folderPath, 1, '.h5');

probArrayReferenceStruct = struct();
annotatedStruct = struct();

fourChamberReferenceArray = zeros(1, rotations);
twoChamberReferenceArray = zeros(1, rotations);
alaxReferenceArray = zeros(1, rotations);

referenceArray = zeros(1, rotations);

%call the split script for each file
for f=1:size(fileNames,2)

    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);
    
    disp(name);
    
    %only files in given folder
    if contains(name, '\')
        continue
    end
    
    %parse filename and rotation
    stringSplit = split(name, '_');
    fileName = stringSplit{1};
    rotation = str2num(stringSplit{4}) + 1;

    % Load data
    inputName = [path name];
    filename = strcat(inputName, '.h5');        

    try
        reference = h5read(filename, '/reference');
    catch
        disk('Error. Failed do load data.')
    end
    
    classIdx = 0;
    
    if reference(1,1) == 1.0
       classIdx = 1;
    elseif reference(2,1) == 1.0
       classIdx = 2;
    elseif reference(3,1) == 1.0
       classIdx = 3;
    end
    
    if classIdx ~= 0
        for i = (rotation - 10) : stepDegree : (rotation + 10)
            if i < 1
                referenceArray(360 + i) = classIdx;
            else
                referenceArray(i) = classIdx;
            end
        end
    end

    fourChamberReferenceArray(rotation) = reference(1,1);
    twoChamberReferenceArray(rotation) = reference(2,1);
    alaxReferenceArray(rotation) = reference(3,1);
    
    probArrayReferenceStruct.(fileName).fourChamber = fourChamberReferenceArray;
    probArrayReferenceStruct.(fileName).twoChamber = twoChamberReferenceArray;
    probArrayReferenceStruct.(fileName).alax = alaxReferenceArray;
    
    annotatedStruct.(fileName) = referenceArray;
        
end

%% Statistics - regression
fn = fieldnames(classifiedStruct);

true = 0;
false = 0;
noise = 0;

for i = 1 : numel(fn)
    for j = 1 : length(annotatedStruct.(fn{i}))
        %if  ~annotatedStruct.(fn{i})(j) == 0
            if annotatedStruct.(fn{i})(j) == classifiedStruct.(fn{i})(j)
                true = true + 1;
            else 
                false = false + 1;
            end
        %else
            %noise = noise + 1;
        %end
    end
end

fprintf('Classification hit rate: %0.1f%% \n',true/(true + false) * 100);

fprintf('Number of annotated noise: %0.1f%% \n',noise/(noise + true + false) * 100);


%% Plot results - regression
files = fieldnames(probArrayStruct);

for f = 1 : numel(files)
   
   figure; hold on;
   
   plot(probArrayStruct.(files{f}).fourChamber, 'r');
   plot(probArrayStruct.(files{f}).twoChamber, 'b');
   plot(probArrayStruct.(files{f}).alax, 'g');
   
   plot(probArrayReferenceStruct.(files{f}).fourChamber, 'r--');
   plot(probArrayReferenceStruct.(files{f}).twoChamber, 'b--');
   plot(probArrayReferenceStruct.(files{f}).alax, 'g--');
   
   title(files{f});
   legend('4C', '2C', 'ALAX', '4C reference', '2C reference', 'ALAX reference');
end