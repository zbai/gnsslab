function Rz = geo_spinz(psi)
% GEO_SPINZ returns the rotation matrix about the z-axis.
%
% SYNTAX:
% 	Rz = geo_spinz(psi);
%
% INPUT:
% 	psi - rotation angle about the z-axis, anticlockwise as seen looking
%         towards the origin from positive z.(radians);
%
% OUTPUT:
%   Rz  - the rotation matrix about the z-axis. (3x3)
%
% See also GEO_RX, GEO_RY.

% validate number of input arguments
narginchk(1,1);

% set the rotation matrix
Rz = [cos(psi), sin(psi), 0; -sin(psi), cos(psi), 0; 0, 0, 1];

end

