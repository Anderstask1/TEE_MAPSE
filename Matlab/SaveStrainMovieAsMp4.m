%Write strain movie as MP4
%Author: gkiss
%Started 09.07.2020
function SaveStrainMovieAsMp4(rootName, imageData, strainLandmarks)

disp(['Saving tracking video to: ', rootName, '.mp4'])

%open mp4
mapseVideo = VideoWriter([rootName '_Strain.mp4'], 'MPEG-4');
mapseVideo.FrameRate = 25;
mapseVideo.Quality = 100;
open(mapseVideo)

%loop through the images
sz = size(imageData);
fig = figure;

for s = 1:sz(3)    
    imshow(squeeze(imageData(:,:,s))', [0 255])
    hold on
    
    %plot landmarks (left and right)
    landmarks = squeeze(strainLandmarks(:,:,s));
    plot(landmarks(1,:), landmarks(2,:), 'x', 'LineWidth', 2)
    hold off
    
    drawnow
    
    frame = getframe(gcf);
    writeVideo(mapseVideo, frame);
end

%cleanup
close(mapseVideo)
close(fig)
