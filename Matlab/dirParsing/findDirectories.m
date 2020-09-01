%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%parse the content of one directory
%save all the regular file names
%if recursive > 0 parse recursively
%if filetype is specified then look for specific files
%if ending is specified checks if the filename ends in ending
%%Author: G. Kiss  02.2011

function dirNames = findDirectories (directoryName)

%build the filename list
files = dir(directoryName);

%filenames in the current directory
dirNames = struct ('name',{}, 'folder',{});

%look for other directories
for f=1:size(files,1)
    %if directory
    if (files(f).isdir)
       dirNames(end+1).name = files(f).name;
       dirNames(end).folder = files(f).folder;
    end
    
end

