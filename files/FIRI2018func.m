function FIRIprofiles = FIRI2018func(Height,Chi,Lat,Month,F107,eDecay,options)
%This function makes FIRI-2018 profiles
%INPUT
%1. Height - heights above the ground from 0 to 150 km. Recommended
%   max resolution is 1 km, it is the initial data resolution. 
%2. Chi - Solar zenith angle from -180 to 180 degrees. Linear interpolation
%   in [-130,130], nearest neighbour extrapolation in [-180,130) and
%   (130,180].
%3. Lat - Latitude from -90 to 90 degrees. Linear interpolation
%   in [-60,60], nearest neighbour extrapolation in [-90,-60) and
%   (60,90].
%4. Month - month from 1 to 12. For the Southern hemisphere 6 month is 
%   added automatically.
%5. F107 - solar activity index from 0 to 300. Linear interpolation
%   in [75,200], nearest neighbour extrapolation in [0,75) and
%   (200,300].
%6. eDecay - exponential decay turn on flag. Sometimes it is useful to
%   extrapolate profile below 55 km. This function uses simple exponential
%   extrapolation. If there's no heights below 55 km and eDecay is turned 
%   on, function returns error. If eDecay turned off, heights below 55 km 
%   are ignored.
%7. options - Name-Value argument. Name 'method', values 'straight' or
%   'all'.
%   If you choose 'method', 'straight', then 
%   will be calculated profiles with the same indexes of Chi, Lat, Month
%   and F107 variables. Chi, Lat, Month and F107 must be the same length.
%   For example, if
%   Chi = [-30,48,81];
%   Lat = [-15, 30, 68];
%   Month = [1 2 10];
%   F107 = [30 125 210];
%   then will be calculated three profiles with parameters:
%   1. Chi = -30; Lat = -15; Month = 1;  F107 = 30;
%   2. Chi = 48;  Lat = 30;  Month = 2;  F107 = 125;
%   3. Chi = 81;  Lat = 68;  Month = 10; F107 = 210;
%   If you choose 'method', 'all', then 
%   will be calculated profiles for all combinations of Chi, Lat, Month
%   and F107 values. Chi, Lat, Month and F107 may have arbitrary length.
%OUTPUT
%FIRIprofiles - structure array with fields:
%FIRIprofiles(i).Height - heights of the profile;
%FIRIprofiles(i).Chi - current Chi of the profile;
%FIRIprofiles(i).Lat - current Lat of the profile;
%FIRIprofiles(i).Month - current Month of the profile (not shifted);
%FIRIprofiles(i).F107 - current F107 index of the profile;
%FIRIprofiles(i).prf - electron densities in electrons/m^3 for the 
%appropriate heights (FIRIprofiles(i).Height). Turned off by default. To
%turn on input true or 1 value.

%Input validation
arguments
    Height {mustBeNumeric,mustBeReal,...
        mustBeVector,...
        mustBeInRange(Height,0,150)}
    Chi {mustBeNumeric,mustBeReal,...
        mustBeVector,...
        mustBeInRange(Chi,-180,180)}
    Lat {mustBeNumeric,mustBeReal,...
        mustBeVector,...
        mustBeInRange(Lat,-90,90)}
    Month {mustBeNumeric,mustBeReal,...
        mustBeVector,...
        mustBeMember(Month,1:12)}
    F107 {mustBeNumeric,mustBeReal,...
        mustBeVector,...
        mustBeInRange(F107,0,300)}
    eDecay (1,1) logical = false
    options.method {mustBeMember(options.method,{'straight','all'})} ...
        = 'straight'
end

%Folder of the fuction
FIRIpath = erase(mfilename('fullpath'),mfilename);
%Load interpolant object
load(fullfile(FIRIpath,'FIRI2018data.mat'),'FIRI2018');

%Divide heights if they are out of the FIRI-2018 range
%(enable exp decay if it possible)
if any(Height < 55) && eDecay == true
    Height2 = Height(Height >= 55);
    Height1 = Height(Height < 55);
%Return error if there is no heights for exponential decay
elseif ~any(Height < 55) && eDecay == true
    error('No heights below 55 km for exponential extrapolation')
%Neglect heights below 55 km if eponential extrapolation is turned off
elseif any(Height < 55) && eDecay == false
    Height2 = Height(Height >= 55);
    Height1 = NaN;
else
    Height2 = Height;
    Height1 = NaN;
end

switch options.method
    case 'all'
        FIRIprofiles = struct;
        i = 1;
        for c = 1:numel(Chi)
            for l = 1:numel(Lat)
                for m = 1:numel(Month)
                    for f = 1:numel(F107)
                        %Write current arguments to structure
                        FIRIprofiles(i).Height = rmmissing([Height1;Height2]);
                        FIRIprofiles(i).Chi = Chi(c);
                        FIRIprofiles(i).Lat = Lat(l);
                        FIRIprofiles(i).Month = Month(m);
                        FIRIprofiles(i).F107 = F107(f);
                        
                        %Input vectors for the interpolant object
                        tmpChi = abs(Chi(c)) + zeros(size(Height2));
                        tmpLat = abs(Lat(l)) + zeros(size(Height2));
                        %If southern hemisphere
                        if Lat(l) < 0
                            %Shift month by 6
                            tmpMonth = mod(Month(m)+6,12) + zeros(size(Height2));
                        else
                            tmpMonth = Month(m) + zeros(size(Height2));
                        end
                        tmpF107 = F107(f) + zeros(size(Height2));
                        
                        %Call interpolant object
                        FIRIprofiles(i).prf = FIRI2018(Height2,tmpChi,tmpLat,...
                            tmpMonth,tmpF107);
                        
                        %exponential extrapolation of the profile decayed to zero height
                        if any(~isnan(Height1)) && eDecay == true
                            efit = fit(Height2(1:6),FIRIprofiles(i).prf(1:6),'exp1');
                            tmpPrf = efit(Height1);
                            FIRIprofiles(i).prf = [tmpPrf;FIRIprofiles(i).prf];
                        end
                        
                        %Increase index
                        i = i+1;
                    end
                end
            end
        end
    case 'straight'
        if numel(Chi) ~= numel(Lat) || numel(Chi) ~= numel(Month) || ...
                 numel(Chi) ~= numel(F107)
            error 'Chi, Lat, Month and F107 must be the same length'
        end
        for i=1:numel(Chi)
            %Write current arguments to structure
            FIRIprofiles(i).Height = rmmissing([Height1;Height2]);
            FIRIprofiles(i).Chi = Chi(i);
            FIRIprofiles(i).Lat = Lat(i);
            FIRIprofiles(i).Month = Month(i);
            FIRIprofiles(i).F107 = F107(i);

            %Input vectors for the interpolant object
            tmpChi = abs(Chi(i)) + zeros(size(Height2));
            tmpLat = abs(Lat(i)) + zeros(size(Height2));
            %If southern hemisphere
            if Lat(i) < 0
                %Shift month by 6
                tmpMonth = mod(Month(i)+6,12) + zeros(size(Height2));
            else
                tmpMonth = Month(i) + zeros(size(Height2));
            end
            tmpF107 = F107(i) + zeros(size(Height2));

            %Call interpolant object
            FIRIprofiles(i).prf = FIRI2018(Height2,tmpChi,tmpLat,...
                tmpMonth,tmpF107);

            %exponential extrapolation of the profile decayed to zero height
            if any(~isnan(Height1)) && eDecay == true
                efit = fit(Height2(1:6),FIRIprofiles(i).prf(1:6),'exp1');
                tmpPrf = efit(Height1);
                FIRIprofiles(i).prf = [tmpPrf;FIRIprofiles(i).prf];
            end
        end
end
end

