%Group landmark based on classified cardiac view, to compute regional
%mapse for 2C, 4C and ALAX views (and a mean of all views).
%Author: Anders Tasken
%Started 18.09.2020

function LandmarkCardiacViewSelection(fileNames)
    %call the split script for each file
    for f=1:size(fileNames,2)

        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);

         %show progress
        fprintf('Converting: %d/%d. \n', f, size(fileNames,2));

        % Load data
        inputName = [path name];

        data = HdfImport(inputName);
        
        % Load landmark variables
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_all-views_', name);
        load(variablesFilename,...
            'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
        fieldNames = fieldnames(data.MVCenterRotatedVolumes);
        
        %sort fields on rotation degree
        fieldNames = natsort(fieldNames);
        
        % Matrices of landmarks with respective cardiac view
        landmarkLeft3DMatrix_4C = nan(size(landmarkLeft3DMatrix));
        landmarkLeft3DMatrix_2C = nan(size(landmarkLeft3DMatrix));
        landmarkLeft3DMatrix_ALAX = nan(size(landmarkLeft3DMatrix));
        
        landmarkRight3DMatrix_4C = nan(size(landmarkRight3DMatrix));
        landmarkRight3DMatrix_2C = nan(size(landmarkRight3DMatrix));
        landmarkRight3DMatrix_ALAX = nan(size(landmarkRight3DMatrix));
        
        annotatedLeft3DMatrix_4C = nan(size(annotatedLeft3DMatrix));
        annotatedLeft3DMatrix_2C = nan(size(annotatedLeft3DMatrix));
        annotatedLeft3DMatrix_ALAX = nan(size(annotatedLeft3DMatrix));
        
        annotatedRight3DMatrix_4C = nan(size(annotatedRight3DMatrix));
        annotatedRight3DMatrix_2C = nan(size(annotatedRight3DMatrix));
        annotatedRight3DMatrix_ALAX = nan(size(annotatedRight3DMatrix));
        
        for i = 1 : length(fieldNames)
            
            %probability classification array
            probArray = data.MVCenterRotatedVolumes.(fieldNames{i}).cardiac_view_probabilities;
            
            %find class of highest probability
            [~, cardiac_class] = max(probArray);
            
            switch cardiac_class
                case 1 %4C
                    landmarkLeft3DMatrix_4C(:,i,:) = landmarkLeft3DMatrix(:,i,:);
                    landmarkRight3DMatrix_4C(:,i,:) = landmarkRight3DMatrix(:,i,:);
                    annotatedLeft3DMatrix_4C(:,i,:) = annotatedLeft3DMatrix(:,i,:);
                    annotatedRight3DMatrix_4C(:,i,:) = annotatedRight3DMatrix(:,i,:);
                case 2 %2C
                    landmarkLeft3DMatrix_2C(:,i,:) = landmarkLeft3DMatrix(:,i,:);
                    landmarkRight3DMatrix_2C(:,i,:) = landmarkRight3DMatrix(:,i,:);
                    annotatedLeft3DMatrix_2C(:,i,:) = annotatedLeft3DMatrix(:,i,:);
                    annotatedRight3DMatrix_2C(:,i,:) = annotatedRight3DMatrix(:,i,:);
                case 3 %ALAX
                    landmarkLeft3DMatrix_ALAX(:,i,:) = landmarkLeft3DMatrix(:,i,:);
                    landmarkRight3DMatrix_ALAX(:,i,:) = landmarkRight3DMatrix(:,i,:);
                    annotatedLeft3DMatrix_ALAX(:,i,:) = annotatedLeft3DMatrix(:,i,:);
                    annotatedRight3DMatrix_ALAX(:,i,:) = annotatedRight3DMatrix(:,i,:);
                otherwise
                    fprintf('unknown classification of rotated volume: %s', fieldNames{i})
            end
        end
        
        %% Save workspace variables
        directoryPath = strcat(path, 'LandmarkMatricesVariables/');
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_4C_', name);
        landmarkLeft3DMatrix = landmarkLeft3DMatrix_4C; 
        landmarkRight3DMatrix = landmarkRight3DMatrix_4C;
        annotatedLeft3DMatrix = annotatedLeft3DMatrix_4C; 
        annotatedRight3DMatrix = annotatedRight3DMatrix_4C;
        save(variablesFilename, 'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_2C_', name);
        landmarkLeft3DMatrix = landmarkLeft3DMatrix_2C; 
        landmarkRight3DMatrix = landmarkRight3DMatrix_2C;
        annotatedLeft3DMatrix = annotatedLeft3DMatrix_2C; 
        annotatedRight3DMatrix = annotatedRight3DMatrix_2C;
        save(variablesFilename, 'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
        
        variablesFilename = strcat(directoryPath, 'landmarkMatrices_ALAX_', name);
        landmarkLeft3DMatrix = landmarkLeft3DMatrix_ALAX; 
        landmarkRight3DMatrix = landmarkRight3DMatrix_ALAX;
        annotatedLeft3DMatrix = annotatedLeft3DMatrix_ALAX; 
        annotatedRight3DMatrix = annotatedRight3DMatrix_ALAX;
        save(variablesFilename, 'landmarkLeft3DMatrix', 'landmarkRight3DMatrix', 'annotatedLeft3DMatrix', 'annotatedRight3DMatrix');
    end
end