function [neu] = xyz2neu(xyz, org, ell)
% XYZ2NEU converts ECEF cartesian coordinates [x,y,z] to local topocentric
% coordinates [n,e,u] which referenced to the tangent plane at the origin
% point defined by org, (n,e,u) correspond to the north, east and up
% direction respectively.
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid
%	neu = xyz2neu(xyz, orgxyz);
%
%   % conversion using user defined ellipsoid
%   ell = get_ellipsoid('KRASS');
%	neu = xyz2neu(xyz, orgxyz, ell);
%
% INPUT:
%   xyz - ECEF cartesian coordinates [x,y,z] in meters. (nx3)
%   org - ECEF cartesian coordinates of the local origin. (1x3)
%   ell - the reference ellipsoid parameters. (default: WGS-84)
%
% OUTPUT:
%   neu - topocentric coordinates [n,e,u] relative to the local origin.(nx3)
%
% REFERENCE:
%   Hoffman-Wellenhoff, 'GPS: Theory and Practice', pages 282-284.
%
% See also NEU2XYZ, GET_ELLIPSOID.

% validate number of input arguments
narginchk(2, 3);

% Set default ellipsoid to WGS-84
if nargin < 3, ell = geo_ellipsoid('WGS84'); end

%convert org to a row vector
org = org(1:3); org = org(:);

% Calc the geodetic lat and lon of the local origin.
llh = xyz2llh(org', ell);
lat = llh(1); lon = llh(2);

% compute the rotation matrix
R = [
    -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
    -sin(lon),            cos(lon),         0;
    cos(lat)*cos(lon),   cos(lat)*sin(lon),  sin(lat)];

% compute topocentric coordinates (n, e, u)
xyz = xyz';

neu = R*(xyz-repmat(org,1,size(xyz,2)));
neu = neu';

end

