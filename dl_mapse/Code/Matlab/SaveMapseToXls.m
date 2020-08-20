%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SaveMapseToXls.m = write MAPSE values to XLS
%
%% Author    : Gabriel Kiss 
%% Started   : 06-July-2020  
%Note 2018: to avoid crashes Open excel> office button>excel options>add ins>Manage>COM Add-inns(choose the 'COM Add-ins')>Go>uncheck the addins there.

function SaveMapseToXls(xlsfile, fileRoot, mapseLeft, mapseRight, mapseCycleEstimatesLeft, mapseCycleEstimatesRight)

disp(['Updating XLS file: ' xlsfile])

%make sure to update the header if more cycles are needed!
maxSavedCycles = 5;

%check is the filename exists
if exist(xlsfile,'file') > 0
  %read the file
  [data, ~, cellArray] = xlsread(xlsfile);
  
  %compute the current line
  currentLine = size(data,1)+3;
else
  %create an empty cell array
  cellArray = CreateEmptyCellArrayMapseStrain ();

  %set current line
  currentLine = 3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fill out values
[~, patientName, ~] = fileparts(fileRoot);

mapseNansLeft = isnan(mapseLeft);
mapseNansRight = isnan(mapseRight);

mapseHitsLeft = 100*(1-sum(mapseNansLeft(:))/size(mapseLeft,2));
mapseHitsRight = 100*(1-sum(mapseNansRight(:))/size(mapseRight,2));


mapseLeftAvg = mean(mapseCycleEstimatesLeft(:));
mapseRightAvg = mean(mapseCycleEstimatesRight(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fill out excel
m = 1;

cellArray{currentLine, m} = patientName;   
m = m+1;

cellArray{currentLine, m} = roundDecimals(mapseHitsLeft, 2);
m = m+1; 
cellArray{currentLine, m} = roundDecimals(mapseHitsRight, 2);
m = m+1;

cellArray{currentLine, m} = roundDecimals(mapseLeftAvg, 2);
m = m+1;
cellArray{currentLine, m} = roundDecimals(mapseRightAvg, 2);
m = m+1;

for c =1:maxSavedCycles
    if (c<=size(mapseCycleEstimatesLeft,2))
        cellArray{currentLine, m} = roundDecimals(mapseCycleEstimatesLeft(1,c), 2);
    end
    m = m+1;
end

for c =1:maxSavedCycles
    if (c<=size(mapseCycleEstimatesRight,2))
        cellArray{currentLine, m} = roundDecimals(mapseCycleEstimatesRight(1,c), 2);
    end
    m = m+1;
end

%time
cellArray{currentLine, m} =  datestr(now);

%write the file
try
    %write the .xls file
    xlswrite(xlsfile, cellArray);
catch
    questdlg('There was an error while saving the excel file! Most probably it is open in Excel.','Error','Ok','Ok');
end


