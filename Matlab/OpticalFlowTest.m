clear all
close all

addpath('SmoothN')

%set up an optical flow object to do the estimate.
opticFlow = opticalFlowFarneback%('NumPyramidLevels', 2, 'NumIterations', 15, 'NeighborhoodSize', 7, 'FilterSize', 15);

%hdfdata = HdfImport('c:/test2/KWA22_82_3.h5');
hdfdata = HdfImport('c:\DL2_Bmode\converted\_D113950\J49BJSHo.h5');

aa = imread('Palette.bmp');
lookup = squeeze(aa(1,:,1));

%open mp4
mapseVideo = VideoWriter('d:/opf.mp4', 'MPEG-4'); % New
mapseVideo.FrameRate = 25;
mapseVideo.Quality = 100;
open(mapseVideo)

frames = hdfdata.tissue.data;
frames = permute(frames,[3,2,1]);

f = 1;
init = 0;

while f <= 20 %size(frames,3)
    currentFrame = squeeze(frames(:,:,f))';
    %data_lookup = lookup(uint8(currentFrame(:))+1);
    %currentFrame = reshape (data_lookup, size(currentFrame));

    flow = estimateFlow(opticFlow,double(currentFrame)./255);
    if init <=0
        init = 1;

        imshow(currentFrame, [0 256]) 
        [x,y] = ginput();

%         points(1,:) = x;
%         points(2,:) = y;
%         
%         d0(1) = norm(points(:,1)-points(:,2));
%         d0(2) = norm(points(:,3)-points(:,4));
%         
%         s0 (1,1) = 0;
%         s0 (2,1) = 0;
    else
        %xint = int64(round(x));
        %yint = int64(round(y));
        %x = x+flow.Vx(yint,xint);
        %y = y+flow.Vy(yint,xint);
         
        
        
        vx = interp2(flow.Vx, x,y);
        vy = interp2(flow.Vy, x,y);
        
        Vs = smoothn({flow.Vx,flow.Vy},'robust'); % automatic smoothing
        vx = interp2(Vs{1}, x,y);
        vy = interp2(Vs{2}, x,y);
        
        x = x+vx;
        y = y+vy;       
%         
%         points(1,:) = x;
%         points(2,:) = y;
%         
%         d(1) = norm(points(:,1)-points(:,2));
%         d(2) = norm(points(:,3)-points(:,4));
%         
%         s0 (1,f) = (d(1)-d0(1))/d0(1);
%         s0 (2,f) = (d(2)-d0(2))/d0(2);
        
        imshow(currentFrame, [0 256]) 
        hold on
        plot(x', y', 'x', 'LineWidth', 4)
        %plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
        hold off 

        drawnow

         
        frame = getframe(gcf);
        writeVideo(mapseVideo, frame);
        
        pause(10^-3)        
    end
    f=f+1;
    %if f > size(frames,3)
    %    f = 1;
    %end
 
end
close(mapseVideo)
figure(2)
plot(1:size(frames,3), s0(1,:).*100, 'g')
hold on
plot(1:size(frames,3), s0(2,:).*100, 'b')
