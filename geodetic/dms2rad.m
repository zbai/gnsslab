function rad = dms2rad(dms)
% DMS2RAD converts angles from [sign, deg, min, sec] to radians.
%
% SYNTAX:
%   rad = dms2rad(dms);
%
% INPUT:
%   dms - angles in [sign, deg, min, sec].(nx4)
%
% OUTPUT:
%   rad - angles in radians. (nx1)
%
% See also RAD2DMS.

% validate number of input arguments
narginchk(1, 1);

% convert the angle to radians
deg = dms(:,1) .* (dms(:,2) + dms(:,3)/60.0 + dms(:,4)/3600.0);
rad = deg * pi / 180;

end
