function CopyAnnotations()
    %% Load data
    filePath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated_J65BP22K_newCNN/J65BP22K.h5';
    filePathAnnotated = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated_annotated_J65BP22K/J65BP22K.h5';
    
    hdfdataAnnotated = HdfImport(filePathAnnotated);
    annotationFields = fields(hdfdataAnnotated.Annotations);
    
    %iterate over all fields
    for i = 1 : length(annotationFields)
        %get coordinates
        ref_coord = hdfdataAnnotated.Annotations.(annotationFields{i}).ref_coord;
        
        %save in hdf5 file structure
        fieldName = strcat('/Annotations/', annotationFields{i}, '/', 'ref_coord');
        h5create(filePath, fieldName, size(ref_coord));
        h5write(filePath, fieldName, ref_coord);
    end
    
    
end