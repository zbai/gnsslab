function llh = xyz2llh(xyz, ell)
% XYZ2LLH converts cartesian coordinates [x,y,z] to geodetic coordinates
% [lat,lon,h] using iterative alogithm.
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid
%	llh = xyz2llh(xyz);
%
%   % conversion using user defined ellipsoid
%   ell = get_ellipsoid('KRASS');
%	llh = xyz2llh(xyz, ell);
%
% INPUT:
%    xyz - cartesian coordinates in [x,y,z] in meters. (nx3)
%    ell - the reference ellipsoid parameters.(default: WGS-84)
%
% OUTPUT:
%    llh - geodetic coordinates in [lat,lon,h] in (rad,rad,m).(nx3)
%
% REFERENCE:
%   Hoffman-Wellenhoff, 'GPS: Theory and Practice', pages 33, 255-257.
%
% See also LLH2XYZ, GET_ELLIPSOID.

% validate number of input arguments
narginchk(1,2);

% set default ellipsoid to WGS-84
if nargin < 2, ell = geo_ellipsoid('WGS84'); end

x = xyz(:,1); y = xyz(:,2); z = xyz(:,3);

% r is distance from spin axis
r = sqrt(x.*x + y.*y);

% first guess of lat
lat0 = atan2(z, r);

% default tolerance	for |lat-lat0|
eps = ones(size(lat0)) * 1.e-11;  % 1.e-11*6378137(m)=0.06378137 (mm)
% maximun iteration times
max_iter = 10;  % normally 3~4 iterations should be enough

e2 = ell.e * ell.e;

% iterate
for i = 1:max_iter
    % compute radius of curvature in prime vertical direction
    N = ell.a ./ sqrt(1.0 - e2 .* sin(lat0) .* sin(lat0));
    % compute lat
    lat = atan2(z + N .* e2 .* sin(lat0), r);
    % test for convergence
    if(abs(lat-lat0) < eps), break; end;
    % update lat0
    lat0 = lat;
end

% if not converged, give an error message
if i == max_iter && abs(lat-lat0) >= eps
    error('XYZ2LLH can not converge after %d iterations.', i);
end;

% direct calculation of longitude and ellipsoidal height
lon = atan2(y, x);
lon = mod(lon, 2*pi); % convert lon to (0~2*pi)

h   = r ./ cos(lat) - N;

llh = [lat, lon, h];

end

