function dms = rad2dms(rad)
% RAD2DMS converts angles from radians to [sign, deg, min, sec].
%
% SYNTAX:
%	dms = rad2dms(rad);
%
% INPUT:
%	rad - angles in radians. (nx1)
%
% OUTPUT:
%	dms - angles in [sign, deg, min, sec].(nx4)
%
% See also DMS2RAD.

% validate number of input arguments
narginchk(1,1);

% make deg to a single coloum and get the sign of the angles
rad = rad(:); signr = sign(rad);

% convert angles to (degree, minute, second)
deg = abs(rad) * 180 / pi;  % work in absolute value
d   = floor(deg);           % degrees
min = 60*(deg - d);         % minutes and seconds
m   = floor(min);           % minutes
s   = 60*(min - m);         % seconds

dms = [signr, d, m, s];

end
