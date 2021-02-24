%Copy annotations from one hdf5 file to another, for testing
%Anders Tasken
%21.11. 2020
filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/CurrentAnnotatingData/';
filesPathAnnotated = '/home/anderstask1/Documents/Kyb/Thesis/Annotate_rotated_3d_ultrasound_data/Annotated/';

%find all .h5 files
fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

%call for each file
for f=1:size(fileNames,2)
    %root name from h5 file
    [path, name, ~] = fileparts(fileNames(f).name);

    %load data
    fileName = strcat(name,'.h5'); 
    filePath = strcat(filesPath, fileName);
    hdfdata = HdfImport(filePath);
    
    %load annotated data
    filePathAnnotated = strcat(filesPathAnnotated, fileName);
    hdfdataAnnotated = HdfImport(filePathAnnotated);

    %get all fields from data struct
    fieldsAnnotated = fieldnames(hdfdataAnnotated);
    
    if any(strcmp(fieldsAnnotated,'Annotations'))
        
        subFields = fieldnames(hdfdataAnnotated.Annotations);
        
        for i = 1 : numel(subFields)
            fieldPath = strcat('/Annotations/', subFields{i}, '/ref_coord');
            ref_coord = hdfdataAnnotated.Annotations.(subFields{i}).ref_coord;
            
            h5create(filePath, fieldPath, size(ref_coord));
            h5write(filePath, fieldPath, ref_coord);
        end 
    end
end