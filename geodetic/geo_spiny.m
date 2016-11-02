function Ry = geo_spiny(theta)
% GEO_SPINY returns the rotation matrix about the y-axis.
%
% SYNTAX:
%   Ry = geo_spiny(theta);
%
% INPUT:
%   theta - rotation angle about the y-axis, anticlockwise as seen looking
% 	        towards the origin from positive y. (radians)
%
% OUTPUT:
%   Ry    - the rotation matrix about the y-axis. (3x3)
%
% See also GEO_RX, GEO_RZ.

% validate number of input arguments
narginchk(1,1);

% set the rotation matrix
Ry = [cos(theta), 0, -sin(theta); 0, 1, 0; sin(theta), 0, cos(theta)];

end

