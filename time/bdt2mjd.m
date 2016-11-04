function mjd = bdt2mjd(bdt)
% BDT2MJD converts BDS time [week,sow] to Modified Julian Date & seconds of
% day [mjd,sod].   
%
% SYNTAX:
%   mjd = bdt2mjd(bdt);
%
% INPUT:
%   bdt - BDS time [week,sow]. (nx2)
%
% OUTPUT:
%	mjd - Modified Julian date & seconds of day [mjd,sod].(nx2)
%
% See also MJD2BDT, GPST2MJD, MJD2GPST.

% validate the number of input arguments
narginchk(1,1);

mjd_bdt = 53736; % mjd of the begining of BDT (Jan 1,2006)

% calculate mjd & seconds of day
mjd(:,1) = bdt(:,1)*7 + floor(bdt(:,2)/86400) + mjd_bdt; % mjd
mjd(:,2) = mod(bdt(:,2), 86400);                         % sod

end
