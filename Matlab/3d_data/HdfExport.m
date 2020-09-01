function HdfExport (filename, data)
% Writes datastructure to HDF
% WARNING: Does not support cells!
% by Fredrik Orderud, 2008

% Write data to file
writeparams(data, '/', filename, false);

function file_created = writeparams (outparams, location, filename, file_created)
f = fieldnames(outparams);
for t=1:length(f);
    % extract field name and value
    name  = f{t};
    value = outparams.(name);
    
    if isstruct(value)
        % recursive parsing of structs
        file_created = writeparams(value, [location '/' name], filename, file_created);
    else
        % write field to file
        details.Location = location;
        details.Name     = name;
        if ~file_created
            hdf5write(filename, details, value);
            file_created = true;
        else
            hdf5write(filename, details, value, 'WriteMode', 'append');
        end
    end
end
