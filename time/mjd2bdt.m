function bdt = mjd2bdt(mjd)
% MJD2BDT converts Modified Julian date & seconds of day [mjd,sod] to BDS
% time [week,sow].  
% 
% SYNTAX:   
%	bdt = mjd2bdt(mjd);
%
% INPUT:
%	mjd - Modified Julian date at 0hr & seconds of day [mjd,sod].(nx2)
%
% OUTPUT:
%   bdt - BDS time[week, sow].(nx2)
%
% See also BDT2MJD, GPST2MJD, MJD2GPST.

% validate the number of input arguments
narginchk(1,1);
if(size(mjd,2) < 2), mjd(:,2) = 0; end

% in case mjd0 has fraction part
mjd1 = floor(mjd(:,1));
mjd2 = mjd(:,2) + (mjd(:,1) - mjd1) * 86400;

% in case sod >= 86400
mjd1 = mjd1 + floor(mjd2/86400);
mjd2 = mod(mjd2, 86400);

% covert
mjd_bdt = 53736; % mjd of the begining of BDT (Jan 1,2006)
week = floor((mjd1 - mjd_bdt)/7);

dow  = mjd1 - mjd_bdt - week * 7;
sow  = dow * 86400 + mjd2;

bdt = [week, sow];

end
