%Display a loop and select a given frame (used for ES frame selection)
function DisplayLoop (filename)

hdfdata = HdfImport(filename);

close all
figure (33)
fig = gcf;

vol = 1;
volNo = hdfdata.ImageGeometry.frameNumber;
stopLoop = 0;
updateFigure = 1;

saveText = '';

while stopLoop <= 0
    if updateFigure > 0
        [filepath,name,ext] = fileparts(filename);
        
        updatePath = strrep(filepath,'\','/');
        
        %text to be saved in the file
        saveText = sprintf("%s/%s, %d\n", updatePath, name, vol); 
        
        %get data
        volName = sprintf('vol%02d', vol);
        imageData = hdfdata.CartesianVolumes.(volName);   
    
        %sax slice
        subplot(1,3,1);
        slice = squeeze(imageData(:,round(end/2),:));
        imshow(slice, [0 255])

        %lax1
        subplot(1,3,2); 
        slice = squeeze(imageData(round(end/2),:,:));
        imshow(slice, [0 255])

        %lax2
        subplot(1,3,3); 
        slice = squeeze(imageData(:,:,round(end/2)));
        imshow(slice, [0 255])
        
        suptitle(sprintf('%s, %d', name, vol))
    end
    
    was_a_key = waitforbuttonpress;  
    if was_a_key 
        updateFigure = 1;
        currentKey = get(fig, 'CurrentKey');
        if strcmp(currentKey, 'leftarrow')
            vol = vol-1;
        elseif strcmp(currentKey, 'rightarrow')
            vol = vol+1;
        elseif strcmp(currentKey, 'w')
            fid = fopen('d:/ES_frames.txt', 'a+');
            fprintf(fid, saveText);
            fclose(fid);
        elseif strcmp(currentKey, 'q')
            stopLoop = 1;
        end
        
        %ensure circular loop
        if vol < 1
            vol = volNo;
        end
        if vol > volNo
            vol = 1;
        end
    
    end
end


