function ly = isleapyear(year)
% ISLEAPYEAR return true if year is a leap year, otherwise it return false.
% 
% SYNTAX:   
%	istrue = isleapyear(year);
%
% INPUT:
%	year - 4-digit year (nx1)
%
% OUTPUT:
%	yes  - true is year is a leap year, flase if not.(nx1)
%
% EXAMPLE:
%	ly = isleapyear(2000);  % ly = true
%
% See also CAL2MJD, YDOY2MJD.

% validate the number of input arguments
narginchk(1, 1);

ly = ((mod(year,4) == 0 & mod(year,100) ~= 0) | mod(year,400) == 0);

end
