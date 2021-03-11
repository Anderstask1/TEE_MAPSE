%delete specified group and correponding dataset in hdf5 files
%Started 2.03.2021, Anders Tasken 
    
filesPath = '/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call the split script for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %show progress
    fprintf('File: %s. \n', name);

    %% Load data
    inputName = [path name];

    data = HdfImport(inputName);

    if isfield(data, 'ClassAnnotations')

        data = rmfield(data, 'ClassAnnotations');

        %new filename
        outName = strcat(inputName,'.h5');

        HdfExport(outName, data);
    end
end