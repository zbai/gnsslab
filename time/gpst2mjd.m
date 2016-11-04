function mjd = gpst2mjd(gpst)
% GPST2MJD converts GPS time [week,sow] to Modified Julian Date & seconds
% of day [mjd,sod].  
% 
% SYNTAX:   
%   mjd = gpst2mjd(gpst);
%
% INPUT:
%   gpst - GPS time [week,sow]. (nx2)
%
% OUTPUT:
%	mjd - Modified Julian date & seconds of day [mjd,sod].(nx2)
%
% See also MJD2GPST.

% validate the number of input arguments
narginchk(1, 1);

mjd_gps = 44244; % mjd of the begining of GPST (Jan 1,2006)

% calculate mjd & seconds of day
mjd(:,1) = gpst(:,1)*7 + floor(gpst(:,2)/86400) + mjd_gps; % mjd
mjd(:,2) = mod(gpst(:,2), 86400);                          % sod

end
