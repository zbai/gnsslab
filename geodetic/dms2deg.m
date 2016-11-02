function deg = dms2deg(dms)
% DMS2DEG converts angles from [sign, deg, min, sec] to decimal degrees.
%
% SYNTAX:
%   deg = dms2deg(dms);
%
% INPUT:
%   dms - angles in [sign, deg, min, sec]. (nx4)
%
% OUTPUT:
%   deg - angles in decimal degrees. (nx1)
%
% See also DEG2DMS.

% validate the number of input arguments
narginchk(1, 1);

% convert the angles to decimal degrees
deg = dms(:,1) .* (dms(:,2) + dms(:,3)/60.0 + dms(:,4)/3600.0);

end
