function xyz = llh2xyz(llh, ell)
% LLH2XYZ converts geodetic coordinates [lat,lon,h] to cartesian coordinates
% [x,y,z].
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid
% 	[xyz] = llh2xyz(llh);
%
%   % conversion using user defined ellipsoid
%   ell = geo_ellipsoid('KRASS');
% 	xyz = llh2xyz(llh, ell);
%
% INPUT:
%	llh - geodetic coordinates [lat,lon,h] in (rad, rad, m). (3xn)
%   ell - the reference ellipsoid parameters. [default: WGS84]
%
% OUTPUT:
%	xyz - cartesian coordinates in [x,y,z] in meters. (3xn)
%
% See also XYZ2LLH, GET_ELLIPSOID.

% validate number of input arguments
narginchk(1, 2);

% Set default ellipsoid to WGS-84
if nargin < 2, ell = geo_ellipsoid('WGS84'); end

lat = llh(:,1); lon = llh(:,2); h = llh(:,3);

% compute radius of curvature in prime vertical direction
N = ell.a ./ sqrt(1.0 - ell.e^2 .* sin(lat) .* sin(lat));

% compute cartesian coordinates
x = (N + h) .* cos(lat) .* cos(lon);
y = (N + h) .* cos(lat) .* sin(lon);
z = (N .* (1-ell.e^2) + h) .* sin(lat);

xyz = [x, y, z];

end

