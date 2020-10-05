%Save slice as image
%Author: Anders Tasken
%Started 05.10.2020
function SaveImageSlice(fieldData, mapseLandmarks, name, field, filesPath)

    %create folder for images
    directoryPath = strcat(filesPath, 'PostProcessMapseImage', '/');
    if ~exist(directoryPath, 'dir')
        % Folder does not exist so create it.
        mkdir(directoryPath);
    end
    
    %get image from first frame in sequence, remove dimension of length 1
    slice = squeeze(fieldData(:,:,1)');

    %plot image
    imshow(slice, [0 255]);
        
    hold on

    %plot landmarks (left and right)
    if ~isnan(mapseLandmarks(1,1))
        plot(mapseLandmarks(1,1), mapseLandmarks(1,2), 'gx', 'LineWidth', 2);
    end
    if ~isnan(mapseLandmarks(1,3))
        plot(mapseLandmarks(1,3), mapseLandmarks(1,4), 'bx', 'LineWidth', 2);
    end

    hold off

    drawnow

    %save image
    fileName = strcat(directoryPath, name,'_',string(field),'.png');
    saveas(gcf, fileName);

end