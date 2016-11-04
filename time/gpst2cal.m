function time = gpst2cal(gpst)
% GPST2CAL converts GPS time (gpsweek and sow) to calendar date and time.
% 
% SYNTAX:   
%	time = gpst2cal(gpst)
%
% INPUT:
%   gpst - GPS time [gpsweek sow]. (nx2)
%
% OUTPUT:
%   time - calendar date and time [yr mon day hr min sec]. (nx6)
%
% See also YDOY2JD, GPS2JD, JD2YMD, JD2DOW, JD2YDOY, JD2GPS, JD2year, year2JD.

% Copyright 2002-2012 gnsslab@hotmail.com
% $Revision: 1.0 $    $Date: 2011/12/12 21:24:49 $

% validate the number of input arguments
narginchk(1,1);
day_gps = datenum([1980,1,6,0,0,0]);

dow = floor(gpst(:,2)/86400); %day of week
ymd = datevec(day_gps + 7*gpst(:,1) + dow); 
                    
sod = gpst(:,2) - dow*86400; %seconds of day
hrs = floor(sod / 3600);
sec = sod - hrs*3600;
min = floor(sec / 60);
sec = sec - min*60;

hms = [hrs, min, sec];

time = [ymd(:,1:3), hms];

end
