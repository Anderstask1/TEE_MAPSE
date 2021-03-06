%Annotation of class for all files in given folder by US rotation angle
%Started 28.01.2021
%Author: Anders Tasken

addpath('/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/Matlab')

%create folder for transformation matrices
directoryPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data_annotated';
if ~exist(directoryPath, 'dir')
    % Folder does not exist so create it.
    mkdir(directoryPath);
end

folderPath = '/home/anderstask1/Documents/Kyb/Thesis/Trym_data/';
foldersStruct = dir(fullfile(folderPath,'*'));
folderNames = setdiff({foldersStruct([foldersStruct.isdir]).name},{'.','..'});

% load txt file with US rotation angle info
fileName = strcat(folderPath, 'dump_DL1_Bmode.txt');
angleTableDL1 = readtable(fileName,'Delimiter',' ');
angleTableDL1.Properties.VariableNames = {'folderName', 'angle', 'filePath'};

fileName = strcat(folderPath, 'dump_DL2_Bmode.txt');
angleTableDL2 = readtable(fileName,'Delimiter',' ');
angleTableDL2.Properties.VariableNames = {'folderName', 'angle', 'filePath'};

for i = 1:numel(folderNames)
    subFoldersStruct = dir(fullfile(strcat(folderPath, folderNames{i}),'*'));
    subFolderNames = setdiff({subFoldersStruct([subFoldersStruct.isdir]).name},{'.','..'});

    %use text file table for current folder
    angleTable = angleTableDL1;
    if i == 2
        angleTable = angleTableDL2;
    end

    %annotate all data from text file table
    for j = 1:length(angleTable{:,3})
        currentFolderName = split(angleTable{j,3}, '\');
        currentFolderName = currentFolderName(1);
        if any(strcmp(subFolderNames,currentFolderName{1}))
            fileName = erase(angleTable{j,3}, '.dcm');
            fileName = strcat(fileName, '.h5');
            fileName = strrep(fileName,'\','/');
            filePath = fullfile(folderPath,folderNames{i},fileName{1});

            %get clean filename
            cleanFileName = split(fileName, '/');
            cleanFileName = erase(cleanFileName{2}, '.h5');


            %find files from same US scan
            idx = ismember(angleTable.folderName, angleTable{j,1});
            sameScanAngleTable = angleTable(idx,:);

            currentFolderName = strcat(currentFolderName{1}, '\', cleanFileName, '.dcm');
            [~, idx] =ismember(currentFolderName, sameScanAngleTable.filePath);
            
            %correct if to US scans have same folder name
            if size(sameScanAngleTable,1) && idx > 3
                idx = idx - 3;
            end

            %Load data
            data = HdfImport(filePath);
            
            %Create new hdf5 file to store annotated data
            s = struct('images', permute(data.tissue.data, [3 2 1]));
            referenceArray = zeros(1,size(data.tissue.data, 1),'int64');

            switch idx
                case 1
                    referenceArray(:) = 1; %4C
                    s.reference = referenceArray;
                case 2
                    referenceArray(:) = 2; %'2C'
                    s.reference = referenceArray;
                case 3
                    referenceArray(:) = 3; %'ALAX'
                    s.reference = referenceArray;
                otherwise
                    fprintf('Error - did not find class to file: %s \n', filePath)
            end

            %save new file
            %new filename
            outName = strcat(directoryPath, '/', cleanFileName,'.h5');
            HdfExport(outName, s);

        else
            fprintf('Did not find folder: %s \n', currentFolderName{1});
        end
    end
end