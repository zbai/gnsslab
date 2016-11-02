function [xyz] = neu2xyz(neu, org, ell)
% NEU2XYZ converts local topocentric coordinates [n,e,u] to ECEF cartesian
% coordinates [x,y,z]. Local topocentric coordinates is referenced to the
% tangent plane at the point defined by orgxyz, n, e, u correspond to the
% north, east and up direction respectively.
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid
% 	xyz = neu2xyz(neu, orgxyz);
%
%   % conversion using user defined ellipsoid
%   ell = geo_ellipsoid('KRASS');
% 	xyz = neu2xyz(neu, orgxyz, ell);
%
% INPUT:
%   neu - topocentric coordinates [n,e,u] relative to local origin. (nx3)
%   org - ECEF cartesian coordinates [x,y,z] of the local origin. (1x3)
%   ell - the reference ellipsoid parameters. [default: WGS84]
%
% OUTPUT:
%	xyz - ECEF cartesian coordinate [x,y,z]. (nx3)
%
% REFERENCE:
%	Hoffman-Wellenhoff, 'GPS: Theory and Practice', pages 282-284.
%
% See also XYZ2NEU, GET_ELLIPSOID.

% validate number of input arguments
narginchk(2,3);

% Set default ellipsoid to WGS-84
if nargin<3, ell = geo_ellipsoid('WGS84'); end

%convert org to a row vector
org = org(1:3); org = org(:)';

% Calc the geodetic lat and lon of the local origin.
llh = xyz2llh(org, ell);
lat = llh(1); lon = llh(2);

% the rotation matrix
R = [
    -sin(lat).*cos(lon), -sin(lon), cos(lat).*cos(lon)
    -sin(lat).*sin(lon),  cos(lon), cos(lat).*sin(lon)
    cos(lat),                  0.0,           sin(lat)];

% compute ECEF cartesian coordinate(x y z)
xyz = R*neu';
xyz = xyz' + repmat(org,size(neu,1),1);

end
