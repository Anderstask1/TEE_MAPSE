addpath('dirParsing')

%input dir
dirIn = 'd:\GE\DataStOlavs9-18\Converted\';
dirIn = 'd:\GE\DataStOlavs19-28\Converted\';
dirIn = 'd:\GE\DataStOlavs1-8\Converted\'

%find all dcm files
fileNames = parseDirectory (dirIn, 1, '.h5');

 
%call display loop for all files
for f=1:size(fileNames,2)
    nameHdf = fileNames(f).name
    DisplayLoop(nameHdf)
    
end

