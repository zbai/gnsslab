function [azi] = azimuth(dx, dy)
% AZIMUTH calculates the azimuth given the coordinate offset between
% starting and ending points.
%
% SYNTAX:
%	azi = azimuth(dx, dy);
%
% INPUT:
%	dx - x coordinate offset. dx = x2 - x1 (nx1)
%   dy - y coordinate offset. dy = y2 - y1 (nx1)
%
% OUTPUT:
%	azi - azimuth as seen from starting point to ending point; (nx1)
%
% See also DEG2DMS, DMS2DEG, ATAN2.

% validate number of input arguments
narginchk(2, 2);

azi = atan2(dy, dx);

% convert azimuth to [0,2*pi]
azi = mod(azi, 2*pi);

end
