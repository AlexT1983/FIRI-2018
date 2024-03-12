%FIRI2018 is a model of electron density in lower ionosphere.
%You can read about in:
%1. Friedrich M. Handbook of Lower Ionosphere. / Friedrich M. – Graz: 
%   Verlag der Technischen Universität Graz, 2016. – 168 p.
%2.	Friedrich M. FIRI-2018, an updated empirical model of the lower 
%   ionosphere. / Friedrich M., Pock C., Torkar K. // Journal of 
%   Geophysical Research. – 2018. – № 123. – P. 6737–6751.

%There are several files in the package:
%1. FIRI_data.xlsx - raw data file from the article [1].
%2. FIRI2018data.mat - MAT-file with saved gridded interpolant object
%FIRI2018.
%3. FIRI2018func.m - advanced function for using FIRI2018 object.

%Gridded interpolant object FIRI2018 perfoms linear interpolation and
%nearest neighbour extrapolation. Inner data is a 5D array:
%[Height,Chi,Lat,Month,F107]
%1. Height - heights above the ground from 55 to 150 km.
%2. Chi - Solar zenith angle [0 30 45 60 75 80 85 90 95 100 130] degrees.
%3. Lat - Latitude [0 15 30 45 60] degrees.
%4. Month - month from 1 to 12. Model valid for the Nothern hemisphere. But
%it's validity suggested for the Southern hemisphere. For the Southern 
%hemisphere it is necessary to add 6 month.
%5. F107 - solar activity index [75 130 200].

%% FIRI2018 interpolant object
%You can use FIRI2018 gridded interpolant object directly.
%Example:
%1. Load it from the MAT-file
FIRIpath = 'C:\FIRI2018\'; %write here path to FIRI files
FIRIDataFile = 'FIRI2018data.mat'; %name of the MAT-file
load(fullfile(FIRIpath,FIRIDataFile),'FIRI2018')
%2. Enter input arguments
Height = (55:150)';
Chi = 0 + zeros(size(Height2));
Lat = 40 + zeros(size(Height2));
Month = 4 + zeros(size(Height2));
F107 = 100 + zeros(size(Height2));
%3. Use FIRI2018 object
prf = FIRI2018(Height,Chi,Lat,Month,F107);
%4. Plot profile
semilogx(prf,Height)
title('FIRI-2018 electron density profile')
xlabel('Electron density, electrons/m^3')
ylabel('Height, km')

%You can build FIRI2018 gridded interpolant object by yourself. See and run
%FIRI_make.m script.

%% FIRI2018func
%To make several profiles use function FIRI2018func. This function must be
%located in the same folder, where located FIRI2018data.mat.
%Input data:
Height = (45:150)';
Chi = [-30,81];
Lat = [-15, 30, 68];
Month = [1 2 10];
F107 = [30 125 210];
%Enable exponential decay for heights < 55 km
eDecay = true;
%There are two calculation methods: 'straight' and 'all'. 
%Default method is 'straight'.
%If you choose method 'straight', then 
%will be calculated profiles with the same indexes of Chi, Lat, Month
%and F107 variables. Chi, Lat, Month and F107 must be the same length.
%For example, if
%Chi = [-30,48,81];
%Lat = [-15, 30, 68];
%Month = [1 2 10];
%F107 = [30 125 210];
%then will be calculated three profiles with parameters:
%1. Chi = -30; Lat = -15; Month = 1;  F107 = 30;
%2. Chi = 48;  Lat = 30;  Month = 2;  F107 = 125;
%3. Chi = 81;  Lat = 68;  Month = 10; F107 = 210;
%If you choose 'method', 'all', then 
%will be calculated profiles for all combinations of Chi, Lat, Month
%and F107 values. Chi, Lat, Month and F107 may have arbitrary length.

%Call function
FIRIprofiles = FIRI2018func(Height,Chi,Lat,Month,F107,eDecay,'method','all');

%Plot example profile, #3
semilogx(FIRIprofiles(3).prf,FIRIprofiles(3).Height)
title({'FIRI-2018 electron density profile with exponential extrapolation:',...
    ['\chi = ', num2str(FIRIprofiles(3).Chi),...
    '; Latitude = ',num2str(FIRIprofiles(3).Lat),...
    '; Month = ',num2str(FIRIprofiles(3).Month),...
    '; F10.7 = ',num2str(FIRIprofiles(3).F107)]})
xlabel('Electron density, electrons/m^3')
ylabel('Height, km')

%If you want to use 'straight' calculation method,
%you need to update Chi:
Chi = [-30,43,81];
%Call function
FIRIprofiles = FIRI2018func(Height,Chi,Lat,Month,F107,eDecay,...
    'method','straight');
%Plot profiles
semilogx(FIRIprofiles(1).prf,FIRIprofiles(1).Height,...
    FIRIprofiles(2).prf,FIRIprofiles(2).Height,...
    FIRIprofiles(3).prf,FIRIprofiles(3).Height)
xlabel('Electron density, electrons/m^3')
ylabel('Height, km')
legend({['\chi = ',num2str(FIRIprofiles(1).Chi),'\circ',...
    '; Lat = ', num2str(FIRIprofiles(1).Lat),'\circ',...
    '; Month = ', num2str(FIRIprofiles(1).Month),...
    '; F10.7 = ', num2str(FIRIprofiles(1).F107)],....
    ['\chi = ',num2str(FIRIprofiles(2).Chi),'\circ',...
    '; Lat = ', num2str(FIRIprofiles(2).Lat),'\circ',...
    '; Month = ', num2str(FIRIprofiles(2).Month),...
    '; F10.7 = ', num2str(FIRIprofiles(2).F107)],....
    ['\chi = ',num2str(FIRIprofiles(3).Chi),'\circ',...
    '; Lat = ', num2str(FIRIprofiles(3).Lat),'\circ',...
    '; Month = ', num2str(FIRIprofiles(3).Month),...
    '; F10.7 = ', num2str(FIRIprofiles(3).F107)]},'Location','best')