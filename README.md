# FIRI-2018
 Matlab implementation for the lower ionosphere model

FIRI2018 is a model of electron density in lower ionosphere.
You can read about in:
1. Friedrich M. Handbook of Lower Ionosphere. / Friedrich M. – Graz: Verlag der Technischen Universitat Graz, 2016. – 168 p.
2. Friedrich M. FIRI-2018, an updated empirical model of the lower ionosphere. / Friedrich M., Pock C., Torkar K. // Journal of Geophysical Research. – 2018. – No. 123. – P. 6737–6751.

There are several files in the package:
1. FIRI_data.xlsx - raw data file from the article [1].
2. FIRI2018data.mat - MAT-file with saved gridded interpolant object FIRI2018.
3. FIRI2018func.m - advanced function for using FIRI2018 object.

Gridded interpolant object `FIRI2018` perfoms linear interpolation and nearest neighbour extrapolation.
Inner data is a 5D array: `[Height,Chi,Lat,Month,F107]`
1. Height - heights above the ground from 55 to 150 km.
2. Chi - Solar zenith angle [0 30 45 60 75 80 85 90 95 100 130] degrees.
3. Lat - Latitude [0 15 30 45 60] degrees.
4. Month - month from 1 to 12. Model valid for the Nothern hemisphere. But it's validity suggested for the Southern hemisphere. For the Southern hemisphere it is necessary to add 6 month.
5. F107 - solar activity index [75 130 200].

## FIRI2018 interpolant object
You can use `FIRI2018` gridded interpolant object directly.
Example:
```
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
```
You can build FIRI2018 gridded interpolant object by yourself. See and run FIRI_make.m script.

## FIRI2018func
To make several profiles use function `FIRI2018func`. This function must be located in the same folder, where located `FIRI2018data.mat`.
```
%Input data:
Height = (45:150)';
Chi = [-30,81];
Lat = [-15, 30, 68];
Month = [1 2 10];
F107 = [30 125 210];
%Enable exponential decay for heights < 55 km
eDecay = true;
```
There are two calculation methods: `'straight'` and `'all'`. 
Default method is `'straight'`.
If you choose method 'straight', then  will be calculated profiles with the same indexes of Chi, Lat, Month and F107 variables. Chi, Lat, Month and F107 must be the same length.
For example, if
```
Chi = [-30,48,81];
Lat = [-15, 30, 68];
Month = [1 2 10];
F107 = [30 125 210];
```
then will be calculated three profiles with parameters:
1. Chi = -30; Lat = -15; Month = 1;  F107 = 30;
2. Chi = 48;  Lat = 30;  Month = 2;  F107 = 125;
3. Chi = 81;  Lat = 68;  Month = 10; F107 = 210;
If you choose `'method'`, `'all'`, then  will be calculated profiles for all combinations of Chi, Lat, Month and F107 values. Chi, Lat, Month and F107 may have arbitrary length.
```
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
If you want to use 'straight' calculation method, you need to update Chi:
%Update Chi
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
```
## Read F10.7 index from 'apf10.7.dat'
If your need to read F10.7 index from 'apf10.7.dat' file use apf107read
function. Example is below. File 'apf10.7.dat' can be downloaded from 
https://irimodel.org. Also you can change apf107read.m file to parse it
from the irimodel.org directly.

```
%Date
Month = 4; Day = 15; Year = 2015;
%Last two digits of the year
Year2d = Year - round(Year,-2);

Chi = 47;
Lat = 40;

%Reading data from 'apf107.dat'
apf107data = apf107read;

%F10.7 index for specified date
F107 = apf107data.F107day(all([apf107data.year==Year2d,...
    apf107data.month==Month,apf107data.day==Day],2));

%Then use FIRI2018func as usual
FIRIprofiles = FIRI2018func(Height,Chi,...
        Lat,Month,F107,eDecay,'method','straight');
```
## Cite as
>Tipikin, Aleksey, and Aleksandr Kuzhelev. “FIRI-2018: MATLAB Package for the Lower Ionosphere Model.” 2024 8th Scientific School Dynamics of Complex Networks and Their Applications (DCNA), IEEE, 2024, pp. 232–34, doi:10.1109/dcna63495.2024.10718582.
>
Also this package is available on Matlab Central File Exchange
>Aleksey Tipikin (2024). FIRI-2018 (https://www.mathworks.com/matlabcentral/fileexchange/160586-firi-2018), MATLAB Central File Exchange. Retrieved March 12, 2024.
