%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%parse the content of one directory
%save all the regular file names
%if recursive > 0 parse recursively
%if filetype is specified then look for specific files
%if ending is specified checks if the filename ends in ending
%%Author: G. Kiss  02.2011
%Modified by Anders Tasken for Linux

function fileNames = parseDirectoryLinux (directoryName, recursive, filetype, ending)

%build the filename list
files = dir(directoryName);

%filenames in the current directory
fileNames = struct ('name',{});

%recursively found filenames
recursiveFileNames = struct ('name',{});

%look for other directories
for f=1:size(files,1)
    %if directory
    if (files(f).isdir)
        
        %if recursive parsing
        if (recursive > 0)
            %check if not '.' and'..'
            if ( ~(strcmp(files(f).name, '.') || strcmp(files(f).name, '..')))
                %temp names
                if (exist ('filetype', 'var') > 0 )
                    if (exist ('ending', 'var') > 0 )
                        tempFileNames = parseDirectory ([directoryName '/' files(f).name], recursive, filetype, ending);
                    else
                        tempFileNames = parseDirectory ([directoryName '/' files(f).name], recursive, filetype);
                    end
                else
                    tempFileNames = parseDirectory ([directoryName '/' files(f).name], recursive);
                end
                
                %append to the recursive names
                recursiveFileNames(end+1:end+size(tempFileNames,2)) = tempFileNames;
            end
        end
    else
        filename = [directoryName '/' files(f).name];
        
        if (exist ('filetype', 'var') > 0 )
            [path, file, extension] = fileparts(filename);
            
            %check if the file has the desired extension
            if strcmp(extension, filetype)
                if (exist ('ending', 'var') > 0 )
                    %make sure file contains the ending and the position of
                    %it is at the end
                     pos = strfind(file,ending);                 
                     if (length(pos) > 0 && pos(end) == length(file)-length(ending)+1)
                        fileNames(end+1).name = filename;
                     end
                else
                    %if ordinary file save its name
                    fileNames(end+1).name = filename;
                end
            end
        else
            %if ordinary file save its name
            fileNames(end+1).name = filename;
        end
        
    end
    
end

%if there were any recursive files append them
if (size(recursiveFileNames,2) > 0)
    fileNames (end+1:end+size(recursiveFileNames,2)) = recursiveFileNames;
end

