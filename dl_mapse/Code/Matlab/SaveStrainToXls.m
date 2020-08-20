%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SaveMapseToXls.m = write strain values to XLS, gets cycle values and a
%                    filename of the form name_x with x the current cycle
%
%% Author    : Gabriel Kiss 
%% Started   : 10-July-2020  
%Note 2018: to avoid crashes Open excel> office button>excel options>add ins>Manage>COM Add-inns(choose the 'COM Add-ins')>Go>uncheck the addins there.

function SaveStrainToXls(xlsfile, fileRoot, strainLeft, strainRight)

%make sure to update the header if more cycles are needed!
maxSavedCycles = 5;
strainRowOffset = 17;
strainTimeDateRowOffset = 29;

%get the filename and cycle
[~, name, ~] = fileparts(fileRoot);
cycle = str2num(name(end:end))
name = name(1:end-2)

disp(['Updating XLS file: ' xlsfile ' file ' name ' strain cycle ' num2str(cycle)])

%is there a line with the current filename
xlsEntryFound = 0;

%check is the filename exists
if exist(xlsfile,'file') > 0
  %read the file
  [data, ~, cellArray] = xlsread(xlsfile);

  %try to find the patient name
  lineNo = size(cellArray,1);
  for l =1:lineNo
      if strcmp(cellArray{l,1},name) == 1
        xlsEntryFound = 1;
        currentLine = l;
      end
  end
    
  %name not found so make a new line  
  if (xlsEntryFound == 0) 
      %compute the current line
      currentLine = size(data,1)+3;
  
  end    
else
  %create an empty cell array
  cellArray = CreateEmptyCellArrayMapseStrain ();

  %set current line
  currentLine = 3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fill out excel
if xlsEntryFound == 0
    cellArray{currentLine, 1} = patientName;   
end

%fill the left and right strain valeus
mLeft = strainRowOffset+1+cycle;
cellArray{currentLine, mLeft} = roundDecimals(strainLeft*100, 2);

mRight = strainRowOffset+1+maxSavedCycles+cycle;
cellArray{currentLine, mRight} = roundDecimals(strainRight*100, 2);

%update the average strain values
mLeftVals = strainRowOffset+1;
noVals = 0;
sum = 0;
for c = 1:maxSavedCycles
    val = cellArray{currentLine, mLeftVals+c};
    if ~isnan(val)
        sum = sum+val;
        noVals = noVals+1;
    end
end

if (noVals >0)
    avgLeftStrain = sum/noVals;
else
    avgLeftStrain = NaN;
end

mRightVals = strainRowOffset+maxSavedCycles+1;
noVals = 0;
sum = 0;
for c = 1:maxSavedCycles
    val = cellArray{currentLine, mRightVals+c};
    if ~isnan(val)
        sum = sum+val;
        noVals = noVals+1;
    end
end

if (noVals >0)
    avgRightStrain = sum/noVals;
else
    avgRightStrain = NaN;
end

%fill them in the XLS file
mLeft = strainRowOffset;
cellArray{currentLine, mLeft} = avgLeftStrain;

mRight = strainRowOffset+1;
cellArray{currentLine, mRight} = avgRightStrain;

%time
cellArray{currentLine, strainTimeDateRowOffset} =  datestr(now);

%write the file
try
    %write the .xls file
    xlswrite(xlsfile, cellArray);
catch
    questdlg('There was an error while saving the excel file! Most probably it is open in Excel.','Error','Ok','Ok');
end


