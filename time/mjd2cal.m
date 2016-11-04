function time = mjd2cal(mjd)
% MJD2CAL converts Modified Julian Date at 0hr (MJD0) & seconds of day(SOD) to
% calendar date and time.
%
% SYNTAX:
%	time = mjd2cal(mjd)
%
% INPUT:
%	mjd - Modified Julian date at 0hr & seconds of day [mjd0,sod]. (nx2)
%
% OUTPUT:
%   time - calendar date and time [yr mon day hr min sec]. (nx6)
%
% See also CAL2MJD.

% Copyright 2002-2012 gnsslab@hotmail.com
% $Revision: 1.0 $    $Date: 2011/12/12 21:24:49 $

% validate number of input arguments
narginchk(1, 1);
if(size(mjd,2) < 2), mjd(:,2) = 0; end

% in case mjd1 has fraction part
mjd1 = floor(mjd(:,1));
mjd2 = mjd(:,2) + (mjd(:,1) - mjd1) * 86400;

% in case sod >= 86400
mjd1 = mjd1 + floor(mjd2/86400);
mjd2 = mod(mjd2, 86400);

% converts (year month day) to Julian date
mjd_gps = 44244;
day_gps = datenum([1980,1,6]);

ymd = datevec(mjd1 - mjd_gps + day_gps);

sec = mod(mjd2, 60);
tmp = (mjd2 - sec) / 60;
min = mod(tmp, 60);
tmp = (tmp - min) / 60;
hrs = tmp;

hms = [hrs, min, sec];

% return the time matrix
time = [ymd(:,1:3), hms];

end
