%Use annotated hdf5 data of mv center rotated volumes as training data for
%CNN model
%Author: Anders Tasken
%Started 27.10.2020
function PrepareTrainingData3D()
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/3d_ultrasound_data/AnnotateProcessingFiles/';

    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');
    
    %create folder for hdf5 generated files
    directoryPath = strcat(filesPath, 'AnnotatedTrainingData/');
    if exist(directoryPath, 'dir')
        % Cannot overwrite existing files, delete first
        disp('Cannot overwrite existing files in folde. Please delete files or change folder name')
        return
    end
    % Create folder
    mkdir(directoryPath);
    
    %call for each file
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ~] = fileparts(fileNames(f).name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(path, fileName);
        hdfdata = HdfImport(filePath);

        %get all fields from data struct
        fields = fieldnames(hdfdata.MVCenterRotatedVolumes);
        
        %sort fields on rotation degree
        sortedFields = natsort(fields);

        for i = 1 : numel(sortedFields)
            %annotated mapse landmarks
            reference = hdfdata.Annotations.(sortedFields{i}).ref_coord;
            
            %flip coordinates
            reference([1 2 3 4], :) = reference([2 1 4 3], :);
            
            %2d sliced images around mv center
            images = hdfdata.MVCenterRotatedVolumes.(sortedFields{i}).images;
            
            %filename
            degree = erase(erase(sortedFields{i}, 'rotated_by_'), '_degrees');
            hdfFileName = strcat(directoryPath, name, '_', degree, '.h5');
            
            %create new hdf5 file
            h5create(hdfFileName, '/reference', size(reference));
            h5write(hdfFileName, '/reference', reference);
            h5create(hdfFileName, '/images', size(images));
            h5write(hdfFileName, '/images', images);
        end
        
    end
end