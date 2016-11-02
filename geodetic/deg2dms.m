function dms = deg2dms(deg)
% DEG2DMS converts angles from decimal degrees to [sign, deg, min, sec].
%
% SYNTAX:
%   dms = deg2dms(deg);
%
% INPUT:
%   deg - angles in decimal degrees (nx1)
%
% OUTPUT:
%   dms - angles in [sign, deg, min, sec].(nx4)
%
% See also DMS2DEG.

% validate the number of input arguments
narginchk(1, 1);

% make deg to a single coloum and get the sign of the angles
deg = deg(:); signd = sign(deg);

% convert angles to (degree, minute, second)
deg = abs(deg);     % work in absolute value
d   = floor(deg);   % degrees
min = 60*(deg - d); % minutes and seconds
m   = floor(min);   % minutes
s   = 60*(min - m); % seconds

dms = [signd, d, m, s];

end
