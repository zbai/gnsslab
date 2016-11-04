function gpst = mjd2gpst(mjd)
% MJD2GPST converts Modified Julian date at 0hr & seconds of day(SOD) to
% GPS time (week and sow). 
% 
% SYNTAX:   
%	gpst = mjd2gpst(mjd);
%
% INPUT:
%	mjd - Modified Julian date at 0hr & seconds of day [mjd0,sod].(nx2)
%
% OUTPUT:
%   gpst - GPS time [week sow].(nx2)
%
% See also GPST2MJD.

% validate number of input arguments
narginchk(1, 1);
if(size(mjd,2) < 2), mjd(:,2) = 0; end

% in case mjd0 has fraction part
mjd1 = floor(mjd(:,1));
mjd2 = mjd(:,2) + (mjd(:,1) - mjd1) * 86400;

% in case sod >= 86400
mjd1 = mjd1 + floor(mjd2/86400);
mjd2 = mod(mjd2, 86400);

% convert
mjd_gps = 44244;  % mjd of the begining of GPST (Jan 6, 1980)
week = floor((mjd1 - mjd_gps)/7);

dow = mjd1 - mjd_gps - week * 7;
sow = dow * 86400 + mjd2;

gpst = [week, sow];

end
