%Extract MV Landmarks and plot all points of MV Annulus - first frame
%Author: Anders Tasken
%Started 29.09.2020

function MitralAnnulus3DRendering

    %% Load data
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';
    
    %find all .h5 files
    fileNames = parseDirectoryLinux(filesPath, 1, '.h5');

    %iterate over all .h5 files in directory
    for f=1:size(fileNames,2)
        %root name from h5 file
        [path, name, ext] = fileparts(fileNames(f).name);
        
        %show progress
        fprintf('Loaded file with name: %s. \n', name);
        
        %load data
        fileName = strcat(name,'.h5'); 
        filePath = strcat(filesPath, fileName);
        hdfdata = HdfImport(filePath);
        
        %% Extract mapse landmark for all rotations and images
        %get all fields from data struct
        fields = fieldnames(hdfdata.MVCenterRotatedVolumes);

        %store mapse coordinates in matrix
        mapseLeft3DMatrix = zeros(4, numel(fields));
        mapseRight3DMatrix = zeros(4, numel(fields));
        
        %iterate over all fields
        for i = 1 : numel(fields)

            %get landmark coordinates, left landmark: x-y, right landmark
            %x-y, for all frames
            mapseLandmarks = hdfdata.MVCenterRotatedVolumes.(fields{i}).MAPSE_detected_landmarks';
            
            %compute y coordinate value
            volume = hdfdata.CartesianVolumes.('vol01');
            y = size(volume,2)/2;
            
            %create 3d vector from coordinates, only 1st frame
            mapseLeft3D = [mapseLandmarks(1,1); y; mapseLandmarks(1,2); 1];
            mapseRight3D = [mapseLandmarks(1,3); y; mapseLandmarks(1,4); 1];
            
            %% Inverse transform to original coordinate system
            %load transformation matrix
            trfFileName = strcat(filesPath,'Transformation-matrices_mv-center/','trf_matrix_mv-center-', fields{i},'.mat');
            trf = load(trfFileName, 'trf').trf; %received signal from beam k
            
            %inverse transformation matrix, to transform coordinates back to
            %original system
            inverse_trf = inv(trf);
            
            %inverse transform
            mapseLeft3D_inv_trf = inverse_trf * mapseLeft3D;
            mapseRight3D_inv_trf = inverse_trf * mapseRight3D;
            
            %save
            mapseLeft3DMatrix(:, i) = mapseLeft3D_inv_trf;
            mapseRight3DMatrix(:, i) = mapseRight3D_inv_trf;
            
        end

        %% Use 3d coordinates of right and left mv landmark for 180 degrees rotation to construct 3d render of Mitral Annulus
        
    end

end