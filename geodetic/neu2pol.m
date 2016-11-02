function pol = neu2pol(neu)
% NEU2POL converts topcentric cartesian coordinates [n,e,u] (left-hand)
% to topcentric polar coordinates [az,el,r]. This function is similar to
% xyz2llr but ECEF cartesian coordinates [x,y,z] is a right-hand system.
%
% SYNTAX:
%	pol = neu2pol(neu);
%
% INPUT:
%   neu - topcentric cartesian coordinates [n,e,u] in meters. (3xn)
%
% OUTPUT:
%   pol - topcentric polar coordinates [azimuth, elevation, radius].
%         azimuth, elevation in radians and radius in meters. (3xn)
%
% See also POL2NEU.

% validate number of input arguments
narginchk(1,1);

n = neu(:,1); e = neu(:,2); u = neu(:,3);

% Calculate topcentric polar coordinates
r  = sqrt(n.*n + e.*e + u.*u);
el = asin(u./r);
az = atan2(e, n);
% Convert azimuths to be between 0 and 2*pi
az = mod(az, 2*pi);

pol = [az, el, r];

end

