%Read FIRI-2018 data
FIRI_read_data;
%% Reshape data and check correctness of data indexing
%Data reshaping
A1 = reshape(FIRIdata,96,11,5,12,3);
isequal(A1(5,7,1,1,1),FIRIdata(5,7))
isequal(A1(2,3,4,7,2),FIRIdata(2,3+11*(4-1)+55*(7-1)+660*(2-1)))
isequal(A1(8,6,3,12,3),FIRIdata(8,6+11*(3-1)+55*(12-1)+660*(3-1)))
%Header rehaping
A2 = reshape(FIRIheader,5,11,5,12,3);

%Check correctness on the header:
%1: Month = 1
%-- DOY ----
%7: Chi = 85
%1: Lat = 0
%1: F107 = 75
[A2(:,7,1,1,1),FIRIheader(:,7)]

%7: Month = 7
%-- DOY ----
%3: Chi = 45
%4: Lat = 45
%2: F107 = 130
[A2(:,3,4,7,2),FIRIheader(:,3+11*(4-1)+55*(7-1)+660*(2-1))]

%12: Month = 12
%-- DOY ----
%9: Chi = 95
%3: Lat = 30
%3: F107 = 200
[A2(:,9,3,12,3),FIRIheader(:,9+11*(3-1)+55*(12-1)+660*(3-1))]

%% Make interpolant object
%Argument vectors
Chi = [0 30 45 60 75 80 85 90 95 100 130]';
Height = (55:150)';
Lat = [0 15 30 45 60]';
Month = (1:12)';
F107 = [75 130 200]';
%Gridded 5-D arguments
[Height1,Chi1,Lat1,Month1,F1071] = ndgrid(Height,Chi,Lat,Month,F107);
%Interpolant object
FIRI2018 = griddedInterpolant(Height1,Chi1,Lat1,Month1,F1071,A1,'linear','nearest');

%save(fullfile(FIRIpath,'FIRI2018data.mat'),'FIRI2018')