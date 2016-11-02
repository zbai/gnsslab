function Rx = geo_spinx(phi)
% GEO_SPINX returns the rotation matrix about the x-axis.
%
% SYNTAX:
%   Rx = geo_spinx(phi);
%
% INPUT:
%   phi - rotation angle about the x-axis, anticlockwise as seen looking
%         towards the origin from positive x.(radians);
%
% OUTPUT:
%   Rx  - teh rotation matrix about the x-axis. (3x3)
%
% See also GEO_RY, GEO_RZ.

% validate number of input arguments
narginchk(1,1);

% set the rotation matrix
Rx = [1, 0, 0; 0, cos(phi), sin(phi); 0, -sin(phi), cos(phi)];

end

