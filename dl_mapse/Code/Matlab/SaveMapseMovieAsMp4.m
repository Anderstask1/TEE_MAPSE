%Write MAPSE movie as MP4
%Author: gkiss
%Started 03.07.2020
function SaveMapseMovieAsMp4(rootName, imageData, mapseLandmarks)

disp(['Saving tracking video to: ', rootName, '.mp4'])

%open mp4
mapseVideo = VideoWriter([rootName '_MAPSE.mp4'], 'MPEG-4'); % New
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
    if ~isnan(mapseLandmarks(s,1))
        plot(mapseLandmarks(s,1), mapseLandmarks(s,2), 'x', 'LineWidth', 2)
    end
    if ~isnan(mapseLandmarks(s,3))
        plot(mapseLandmarks(s,3), mapseLandmarks(s,4), 'x', 'LineWidth', 2)
    end
    
    hold off
    
    drawnow
    
    frame = getframe(gcf);
    writeVideo(mapseVideo, frame);
end

%cleanup
close(mapseVideo)
close(fig)
