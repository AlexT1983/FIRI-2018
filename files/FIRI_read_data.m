%Folder of the this script
FIRIpath = erase(mfilename('fullpath'),mfilename);
%File with FIRI-2018 data
DataFileName = 'FIRI_data.xlsx';

%Import data
%Set up the Import Options and import the data
opts1 = spreadsheetImportOptions("NumVariables", 1980);

%Specify sheet and range
opts1.Sheet = "FIRI-new_vs_altitude";
opts1.DataRange = "B9:BXE104";
opts1.VariableTypes = repmat({'double'},1,1980);

opts2 = opts1;
opts2.DataRange = "B3:BXE7";

%Import the data
FIRIdata = readtable(fullfile(FIRIpath,DataFileName),...
    opts1, "UseExcel", false);
FIRIheader = readtable(fullfile(FIRIpath,DataFileName),...
    opts2, "UseExcel", false);

%Convert to output type
FIRIdata = table2array(FIRIdata);
FIRIheader = table2array(FIRIheader);

%Clear temporary variables
clear opts1 opts2 DataFileName