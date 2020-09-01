%Split a 2D recording into several heart cycles, they will be saved as _1, _2, ...
%Author: gkiss
%Started 23.07.2020
function SplitRecordingIntoHeartCycles(rootName, outputDir, minImageFrames)

disp("Processing file: " + rootName)

%load dataset
hdfdata = HdfImport([rootName '.h5']);

%get image times
imageTimes = hdfdata.tissue.times;

%get ECG data
ecgData = double(hdfdata.ecg.ecg_data);
ecgTimes = double(hdfdata.ecg.ecg_times);

%compute the peaks in the ECG
[~, ecgPeakIndex] = pan_tompkin(ecgData, round(1/mean(diff(ecgTimes))), 0);
ecgPeakTimes = ecgTimes(ecgPeakIndex);

%get the closest image frames to the ecgPeakTimes
imageIdx = zeros(size(ecgPeakTimes,1),1);
for i=1:size(ecgPeakTimes,1)
    [~,imageIdx(i,1)]=min(abs(imageTimes-ecgPeakTimes(i)));
end

figure (1)
plot(ecgTimes, ecgData)
hold on
plot(ecgPeakTimes, ecgData(ecgPeakIndex),'xb')
%process all ECG cycles
ecgCycles = size (ecgPeakTimes,1)-1;
disp(['Detected ECG cycles ' num2str(ecgCycles)])

%get the name of the file
[~, name, ~] = fileparts([rootName '.h5']);

if (ecgCycles <= 1)
    %nothing to split, just save the hdfdata as _1
    outName = [outputDir name '_1.h5'];
    HdfExport(outName, hdfdata)
else
    %actual splitting
    
    %sometimes the ecg is longer than the data!
    cycleNo = 1;
    
    for i=1:ecgCycles
        if size(hdfdata.tissue.times(imageIdx(i)+1:imageIdx(i+1)),1) > minImageFrames
            outdata = hdfdata;

            outdata.ecg.ecg_data = hdfdata.ecg.ecg_data(ecgPeakIndex(i)+1:ecgPeakIndex(i+1)) ;
            outdata.ecg.ecg_times = hdfdata.ecg.ecg_times(ecgPeakIndex(i)+1:ecgPeakIndex(i+1));

            outdata.tissue.data = hdfdata.tissue.data(imageIdx(i)+1:imageIdx(i+1),:,:);
            outdata.tissue.times = hdfdata.tissue.times(imageIdx(i)+1:imageIdx(i+1)) ;

            outName = [outputDir name '_' num2str(cycleNo) '.h5'];
            cycleNo = cycleNo + 1;
            HdfExport(outName, outdata);
        end
    end    
    
    %check if there are enough slices in the from the last ECG detection 
    %if so save the last cycle as well
    if size(hdfdata.tissue.times(imageIdx(end):end),1) > minImageFrames
        outdata = hdfdata;
        
        outdata.ecg.ecg_data = hdfdata.ecg.ecg_data(ecgPeakIndex(end)+1:end) ;
        outdata.ecg.ecg_times = hdfdata.ecg.ecg_times(ecgPeakIndex(end)+1:end) ;
      
        outdata.tissue.data = hdfdata.tissue.data(imageIdx(end)+1:end,:,:) ;
        outdata.tissue.times = hdfdata.tissue.times(imageIdx(end)+1:end) ;
        
        outName = [outputDir name '_' num2str(cycleNo) '.h5'];
        HdfExport(outName, outdata)
        
        disp('Extra cycle saved!');
    end
end
