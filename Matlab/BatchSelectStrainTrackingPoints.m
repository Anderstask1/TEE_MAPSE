%Select the strain tracking points for folder, assumes that the recordings
%are already split into the cardiac cycles
%Author: gkiss
%Started 03.08.2020

addpath('dirParsing')

clear all
close all

dirIn = 'h:\AndreasSelectedConvertedSplitStrainTemp\';
dirOut = 'h:\AndreasSelectedConvertedSplitStrain\';


%find all .h5 files
fileNames = parseDirectory (dirIn, 1, '.h5');


%call the split script for each file
for f=1:size(fileNames,2)
    display (['Active recording: ' fileNames(f).name])
    
    %read data
    hdfdata = HdfImport(fileNames(f).name);
    
    %root name from h5 file
    [path, name, ext] = fileparts(fileNames(f).name);
    rootName = [path '/' name];

    %make data readt for plotting
    tissuedata =  permute(hdfdata.tissue.data,[3 2 1]);

    %select points for this cycle
    pts_selected = SelectTrackingPointsFrame(tissuedata, name, 1);
        
    %get the tissue required info for this cycle
    hdfdataout.tissue.data = tissuedata;
    hdfdataout.tissue.times = hdfdata.tissue.times;
    hdfdataout.tissue.dirx = hdfdata.tissue.dirx;
    hdfdataout.tissue.diry = hdfdata.tissue.diry;
    hdfdataout.tissue.origin = hdfdata.tissue.origin;
    hdfdataout.tissue.pixelsize = hdfdata.tissue.pixelsize;
    hdfdataout.tissue.det_track_points = pts_selected;
    
    %get the ecg info for this cycle
    hdfdataout.ecg.ecg_data = hdfdata.ecg.ecg_data;
    hdfdataout.ecg.ecg_times = hdfdata.ecg.ecg_times;
    
    %save HDF file
    filenameOut = [dirOut name '.h5'];
    HdfExport(filenameOut, hdfdataout);

end

