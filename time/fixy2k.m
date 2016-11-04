function year = fixy2k(yr)
% FIXY2K fixes the hundred-year ambiguity for a given two-digit year. The
% two-digit year will be translated to a full 4-digit year according to
% the RINEX 2.1 specification:
%        80-99 -> 1980-1999
%        00-79 -> 2000-2079
% if the input year >= 100, the output year will be unchanged.
%
% SYNTAX:
%	year = fixy2k(yr);
%
% INPUT:
%	yr - 2-digit year.
%
% OUTPUT:
%	year - 4-digit year.
%
% See also CAL2MJD, CAL2GPST.

% validate the number of input arguments
narginchk(1, 1);

% Initialize the output variables
year = yr;

idx = (year >= 80 & year < 100);
year(idx) = year(idx) + 1900;

idx = (year >= 0 & year <= 79);
year(idx) = year(idx) + 2000;

end