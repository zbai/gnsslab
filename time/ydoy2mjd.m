function mjd = ydoy2mjd(ydoy)

% YDOY2MJD  converts year and day of year to Modified Julian date.
% 
% SYNTAX:   
%	mjd = ydoy2mjd(ydoy);
%
% INPUT:
%	ydoy - year and day of year. (nx2)
%
% OUTPUT:
%	mjd  - Modified Julian date. (nx1)
%
% See also MJD2YDOY.

% validate the number of input arguments
narginchk(1,1);

yr = ydoy(:,1); doy = ydoy(:,2);
m  = ones(size(yr)); d = zeros(size(yr)); % Jan 0

mjd = cal2mjd([yr, m, d]);

% mjd = mjd of Jan 0 + doy
mjd = mjd(:,1) + doy;

mjd1 = floor(mjd);
mjd2 = (mjd - mjd1)*86400;

mjd  = [mjd1, mjd2];

end
