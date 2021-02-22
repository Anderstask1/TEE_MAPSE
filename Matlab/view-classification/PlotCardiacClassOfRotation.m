%Plotting of classification results
%Started 17.02.2021
%Author: Anders Tasken

function PlotCardiacClassOfRotation(fileNames)

    %get path
    [path, ~, ~] = fileparts(fileNames(1).name);

    %create folder for figure
    directoryPath = strcat(path, 'ClassificationFigures/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end

    probArrayStruct = struct();

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

        %parse filename and rotation
        stringSplit = split(name, '_');
        fileName = stringSplit{1};

        % Load data
        inputName = [path name];

        data = HdfImport(inputName);

        fieldNames = fieldnames(data.MVCenterRotatedVolumes);

        for i = 1 : length(fieldNames)

            stringSplit = split(fieldNames{i}, '_');
            rotationDegree = str2num(stringSplit{3});

            %probability classification array
            probArray = data.MVCenterRotatedVolumes.(fieldNames{i}).cardiac_view_probabilities;

            twoChamberArray(rotationDegree/10+1) = probArray(1);
            fourChamberArray(rotationDegree/10+1) = probArray(2);
            alaxArray(rotationDegree/10+1) = probArray(3);
            otherArray(rotationDegree/10+1) = probArray(4);

        end

        probArrayStruct.(fileName).fourChamber = twoChamberArray;
        probArrayStruct.(fileName).twoChamber = fourChamberArray;
        probArrayStruct.(fileName).alax = alaxArray;
        probArrayStruct.(fileName).other = otherArray;

    end

    % Plot results
    files = fieldnames(probArrayStruct);

    for f = 1 : numel(files)

        %plot figure
        fig = figure; hold on;
        plot(probArrayStruct.(files{f}).fourChamber);
        plot(probArrayStruct.(files{f}).twoChamber);
        plot(probArrayStruct.(files{f}).alax);
        plot(probArrayStruct.(files{f}).other);
        legend('4C', '2C', 'ALAX', 'Other');
       
        %figure title
        interpTitleName = strcat('Classification plot of: ', files{f});
        title(interpTitleName)
        
        %create folder for figure
        directoryNamePath = strcat(directoryPath, files{f}, '/');
        if ~exist(directoryNamePath, 'dir')
            % Folder does not exist so create it.
            mkdir(directoryNamePath);
        end

        %save figure
        figName = strcat(directoryNamePath, name,'_classification-fig.fig');
        savefig(fig, figName)
    end
end