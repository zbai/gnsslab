function [llr] = xyz2llr(xyz)
% XYZ2LLR converts cartesian coordinates [x,y,z] to geocentric coordinates
% [lat,lon,radius].
%
% SYNTAX:
%   llr = xyz2llr(xyz);
%
% INPUT:
%   xyz - ECEF cartesian coordinates [x,y,z] in meters. (nx3)
%
% OUTPUT:
%   llr - geocentric coordinates [lat,lon,radius] in (rad,rad,m). (nx3)
%
% See also LLR2XYZ.

% validate number of input arguments
narginchk(1,1);
x = xyz(:,1); y = xyz(:,2); z = xyz(:,3);

rad = sqrt(x.*x + y.*y + z.*z);
lat = asin(z./r);
lon = atan2(y, x);

% normalizes the longitute into [0, 2*pi].
lon = mod(lon, 2*pi);

llr = [lat,lon,rad];

end