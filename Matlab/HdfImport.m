function data = HdfImport (filename)
% Imports and parses HDF files into a matlab datastructure.
% by Fredrik Orderud, 2008

% read first group in HDF file
hinfo = hdf5info(filename);
data  = read_group(filename, hinfo.GroupHierarchy(1));


function data = read_group (filename, group)
for i = 1:length(group.Datasets)
    % parse fields in struct
    name_str = group.Datasets(i).Name;
    value    = hdf5read(filename, name_str);
    
    if ~isnumeric(value)
        value = value.Data;
    end
    
    field_name = parse_dataset_name(name_str);
    data.(field_name) = value;
end
for i = 1:length(group.Groups)
    % recursive parsing
    name_str = group.Groups(i).Name(2:end);
    
    field_name = parse_dataset_name(name_str);
    data.(field_name) = read_group(filename, group.Groups(i));
end

function name = parse_dataset_name (hdf_path)
idxs = findstr(hdf_path,'/');
if isempty(idxs)
    idxs = 0;
end
name = hdf_path(idxs(end)+1:end);
