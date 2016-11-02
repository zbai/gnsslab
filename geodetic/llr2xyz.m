function [xyz] = llr2xyz(llr)
% LLR2XYZ converts geocentric coordinates [lat,lon,radius] to cartesian
% coordinates [x,y,z].
%
% SYNTAX:
%	[xyz] = llr2xyz(llr);
%
% INPUT:
%   llr - geocentric coordinates [lat,lon,radius] in (rad, rad, m). (nx3)
%
% OUTPUT:
%   xyz - cartesian coordinates [x,y,z] in meters. (nx3)
%
% See also XYZ2LLR.

% validate number of input arguments
narginchk(1,1);

lat = llr(:,1); lon = llr(:,2); r = llr(:,3);

x = r.*cos(lat).*cos(lon);
y = r.*cos(lat).*sin(lon);
z = r.*sin(lat);

xyz = [x, y, z];

end