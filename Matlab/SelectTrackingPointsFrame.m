%Select the strain tracking points for a frame
%Author: gkiss
%Started 08.07.2020
function [pts_selected, fig] = SelectTrackingPointsFrame(frames, name, cycle)

fig = figure(4);
hold off

stopLoop = 0;
updateFigure = 1;
f = 1;
x = [];
y = [];

while stopLoop <= 0
    if updateFigure > 0
        hold off
        imshow(frames(:,:,f)', [0 255])
        hold on     
        plot(x', y', 'x')
        title (['File: ' name ' cycle ' num2str(cycle), ' frame ' num2str(f)], 'Interpreter','none')
        drawnow
    end
    
    was_a_key = waitforbuttonpress;  
    if was_a_key 
        updateFigure = 1;
        currentKey = get(fig, 'CurrentKey');
        if strcmp(currentKey, 'leftarrow')
            f = f-1;
        elseif strcmp(currentKey, 'rightarrow')
            f = f+1;
        elseif strcmp(currentKey, 's')
            x = [];
            y = [];

            %select the 4 points
            [x,y] = ginput();

            %plot them
            plot(x', y', 'x')
            
            disp(['A number of ' num2str(size(x,1)) ' points was selected']);
            
        elseif strcmp(currentKey, 'a')
            if (~isempty(x))
                stopLoop = 1;
            else
                disp('Points need to be selected before acceptance!')
            end
        end
        
        %ensure circular loop
        if f < 1
            f = size(frames, 3);
        end
        if f > size(frames, 3)
            f = 1;
        end
    
    end
end

%convert to int64
pts_selected(1,:) = x;
pts_selected(2,:) = y;
pts_selected = int64(pts_selected);


