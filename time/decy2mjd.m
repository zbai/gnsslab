function mjd = decy2mjd(dy)
% DECY2MJD converts decimal year to Modified Julian date (MJD) & seconds of
% day(SOD).    
%
% SYNTAX:   
%	mjd = decy2mjd(dy);
%
% INPUT:
%	dy  - Decimal year (nx1)
%
% OUTPUT:
%	mjd - Modified Julian date & seconds of day [mjd,sod]. (nx2)	
%
% See also MJD2DECY.

% validate the number of input arguments
narginchk(1,1);
dy = dy(:);

yr = floor(dy); mon = ones(size(yr)); day = mon; % Jan 1
dy = mod(dy,1.0);

mjd1 = cal2mjd([yr,   mon, day]);
mjd2 = cal2mjd([yr+1, mon, day]);

doy = dy .* (mjd2(:,1) - mjd1(:,1));
mjd = mjd1(:,1) + doy;

mjd1 = floor(mjd);
mjd2 = (mjd - mjd1)*86400;

mjd  = [mjd1, mjd2];

end
