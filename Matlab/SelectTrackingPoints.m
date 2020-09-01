%Select the strain tracking points for a recording, split the recording into the ECG cycles
%Author: gkiss
%Started 08.07.2020

clear all
close all


filenameRoot = 'd:\dl\MAPSE\Data\test\KWA03_70';
dirOut = 'c:\temp\';

disp(['Processing file ' filenameRoot])

%read data
hdfdata = HdfImport([filenameRoot '.h5']);
[~, name, ~] = fileparts([filenameRoot '.h5']);

%get ECG data
ecgData = double(hdfdata.ecg.ecg_data);
ecgTimes = double(hdfdata.ecg.ecg_times);

%compute the peaks in the ECG
[~, ecgPeakIndex] = pan_tompkin(ecgData, round(1/(ecgTimes(2)-ecgTimes(1))), 0);
ecgPeakTimes = ecgTimes(ecgPeakIndex);

%get the closest image frames to the ecgPeakTimes
cycleIdx = zeros(size(ecgPeakTimes,1),1);
for i=1:size(ecgPeakTimes,1)
    [~,cycleIdx(i,1)]=min(abs(hdfdata.tissue.times-ecgPeakTimes(i)));
end

%process all ECG cycles
ecgCycles = size (ecgPeakTimes,1)-1;
disp(['Detected ECG cycles ' num2str(ecgCycles)])

%make data readt for plotting
tissuedata =  permute(hdfdata.tissue.data,[3 2 1]);
  
%split the file up into the cycles and select the tracking points
c=1;
while c <= ecgCycles
    frames = tissuedata(:,:,cycleIdx(c,1):cycleIdx(c+1,1)-1);
    
    %select points for this cycle
    pts_selected = SelectTrackingPointsFrame(frames, name, c);
    
    %check if the user is happy with the selected points
    %answer = questdlg('Accept selected points?', 'Tracking points quality', 'Accept','Reselect','Accept');
    %switch answer
    %    case 'Accept'
    %end
     
    %get the tissue required info for this cycle
    hdfdataout.tissue.data = tissuedata(:,:,cycleIdx(c,1):cycleIdx(c+1,1)-1);
    hdfdataout.tissue.times = hdfdata.tissue.times(cycleIdx(c,1):cycleIdx(c+1,1)-1,:,:);
    hdfdataout.tissue.dirx = hdfdata.tissue.dirx;
    hdfdataout.tissue.diry = hdfdata.tissue.diry;
    hdfdataout.tissue.origin = hdfdata.tissue.origin;
    hdfdataout.tissue.pixelsize = hdfdata.tissue.pixelsize;
    hdfdataout.tissue.det_track_points = pts_selected;
    
    %get the ecg info for this cycle
    hdfdataout.ecg.ecg_data = hdfdata.ecg.ecg_data(ecgPeakIndex(c):ecgPeakIndex(c+1)-1);
    hdfdataout.ecg.ecg_times = hdfdata.ecg.ecg_times(ecgPeakIndex(c):ecgPeakIndex(c+1)-1);
    
    %save HDF file
    filenameOut = [dirOut name '_' num2str(c) '.h5'];
    HdfExport(filenameOut, hdfdataout);
    
    %move to next cycle
    c = c+1;  
end
