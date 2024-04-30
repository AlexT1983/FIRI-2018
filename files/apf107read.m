function apf107data = apf107read

%Folder of the this function
FIRIpath = erase(mfilename('fullpath'),mfilename);
%File with FIRI-2018 data
DataFileName = 'apf107.dat';

%Import data
%Set up the Import Options and import the data
numvars = 16;
opts = fixedWidthImportOptions('NumVariables',numvars);
opts.VariableNames = {'year','month','day','Ap0_3','Ap3_6','Ap6_9','Ap9_12',...
    'Ap12_15','Ap15_18','Ap18_21','Ap21_24','ApDay','dummy','F107day','F107_81','F107_365'};
opts.VariableTypes = repmat({'double'},1,numvars);
opts.VariableWidths = [3 3 3 3 3 3 3 3 3 3 3 3 3 5 5 5];

%Import the data
apf107data = readtable(fullfile(FIRIpath,DataFileName),opts);
end

