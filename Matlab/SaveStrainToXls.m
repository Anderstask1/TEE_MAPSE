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

disp(['Updating XLS file: ' xlsfile ' file ' name])

%check is the filename exists
if exist(xlsfile,'file') > 0
  %read the file
  [data, ~, cellArray] = xlsread(xlsfile);

   %compute the current line
   currentLine = size(data,1)+3;

else
  %create an empty cell array
  cellArray = CreateEmptyCellArrayStrain ();

  %set current line
  currentLine = 3;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fill out excel
cellArray{currentLine, 1} = name;   

%fill the left and right strain valeus
cellArray{currentLine, 2} = roundDecimals(strainLeft*100, 2);

cellArray{currentLine, 3} = roundDecimals(strainRight*100, 2);

%time
cellArray{currentLine, 4} =  datestr(now);

%write the file
try
    %write the .xls file
    xlswrite(xlsfile, cellArray);
catch
    questdlg('There was an error while saving the excel file! Most probably it is open in Excel.','Error','Ok','Ok');
end


