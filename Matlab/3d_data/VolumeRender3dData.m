%Volume rendering using Volume Viewer App
%Author: Anders Tasken
%Started 11.09.2020

function VolumeRender3dData()
    filesPath = '/home/anderstask1/Documents/Kyb/Thesis/TEE_MAPSE/test_rotated/';

    hdfFileName = 'J65BP22M';

    %load data
    fileName = strcat(hdfFileName,'.h5'); 
    filePath = strcat(filesPath, fileName);
    hdfData = HdfImport(filePath);

    %extract volume data from struct
    data = hdfData.CartesianVolumes.vol01;

    %visualize 3d data with Vlume Viewer App within Matlab in "Apps"
    volumeViewer(data);

end