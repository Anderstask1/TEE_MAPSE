%Postprocess the deep learning results for STRAIN
%Author: gkiss
%Started 09.07.2020
function PostProcessStrainRecording(rootName, xlsfile, saveTrackingMovie, saveTrackingPlot, saveXls)

disp("Processing file: " + rootName)

%scaling ECG values
ecgScaleFactor = 0.3;

%load dataset
hdfdata = HdfImport([rootName '.h5']);

%if this is isotropic (as is by default) should simplify some computations later
pixelSize = hdfdata.tissue.pixelsize*1000;

imageData = hdfdata.tissue.data;
imageTimes = hdfdata.tissue.times;

strainLandmarks = hdfdata.STRAIN_tracked_points;

%convert from pixels to mm
strainDistLeft = hdfdata.STRAIN_left_dist'.*pixelSize(2);
strainDistRight = hdfdata.STRAIN_right_dist'.*pixelSize(2);

%get ECG data
ecgData = double(hdfdata.ecg.ecg_data);
ecgTimes = double(hdfdata.ecg.ecg_times);

% %process the left and right STRAIN curves
[strainEstimateLeft, strainMinIndexLeft, strainMaxIndexLeft] = PostProcessStrainCurve(strainDistLeft);
[strainEstimateRight, strainMinIndexRight, strainMaxIndexRight] = PostProcessStrainCurve(strainDistRight);

%strain values fr left and right walls
maxLeft = strainDistLeft(strainMaxIndexLeft);
strainLeft = (strainDistLeft-maxLeft)./maxLeft*100;
maxRight = strainDistRight(strainMaxIndexRight);
strainRight = (strainDistRight-maxRight)./maxRight*100;

%plot stuff

%plot the images with landmarks and save as movie
if saveTrackingMovie > 0 
    SaveStrainMovieAsMp4(rootName, imageData, strainLandmarks)
end
  
%plot the curves
if saveTrackingPlot > 0
    fig = figure('Position', [40, 40, 1000, 1400]);
    clf(fig)
    hold on
    
    subplot(2,1,1)
    hold on
    plot(imageTimes, strainLeft, 'g', 'LineWidth', 2);
    plot(imageTimes(strainMinIndexLeft), strainLeft(strainMinIndexLeft), 'or')
    plot(imageTimes(strainMaxIndexLeft), strainLeft(strainMaxIndexLeft), 'xr')

    plot(imageTimes, strainRight, 'b', 'LineWidth', 2);
    plot(imageTimes(strainMinIndexRight), strainRight(strainMinIndexRight), 'or')
    plot(imageTimes(strainMaxIndexRight), strainRight(strainMaxIndexRight), 'xr')
    
    %custom legend explains just the lines
    h = zeros(2, 1);
    h(1) = plot(NaN,NaN,'-g');
    h(2) = plot(NaN,NaN,'-b');
    legend(h, 'left wall', 'right wall');

    [~, name, ~] = fileparts(rootName);
    title (['Strain plot, value left ', num2str(strainEstimateLeft*100), ' right ', num2str(strainEstimateRight*100), ' file: ' name], 'Interpreter', 'none')
    ylim([-50 10])
    
    subplot(2,1,2)
    hold on
    plot(ecgTimes, ecgScaleFactor.*ecgData, 'black')
    title ("ECG plot")
    ylim([-100 100])

    %save figure to PNG
    saveas(fig, [rootName '_strain.png'])
    close(fig)

end
 
%save the XLS file
if saveXls > 0
    SaveStrainToXls(xlsfile, rootName, strainEstimateLeft, strainEstimateRight);
end

