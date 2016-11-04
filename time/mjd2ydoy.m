function ydoy = mjd2ydoy(mjd)
%
% MJD2YDOY converts Julian date to year and day of year.
%
% SYNTAX:
%	ydoy = mjd2ydoy(mjd);
%
% INPUT:
%	mjd - Modified Julian date.(nx1)
%
% OUTPUT:
%	ydoy - year and day of year [year, doy].(nx2)
%
% See also YDOY2MJD.

% validate number of input arguments
narginchk(1, 1);
if(size(mjd,2) < 2), mjd(:,2) = 0; end

cal = mjd2cal(mjd);

% mjd of Jan 0
y = cal(:,1);  m = ones(size(y)); d = zeros(size(y));
mjd1 = cal2mjd([y,m,d]);

% day of year
doy = mjd(:,1) - mjd1(:,1) + mjd(:,2)/86400;

ydoy = [y, doy];

end
