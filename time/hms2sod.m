function sod = hms2sod(hms)
% HMS2SOD converts time in [hour, minute, second] to seconds of day.
%
% SYNTAX:
%	sod = hms2sod(hms);
%
% INPUT:
%	hms - time in [hour, min, sec].  (nx3)
%
% OUTPUT:
%	sod - seconds of day.  (nx1)
%
% See also SOD2HMS.

% validate the number of input arguments
narginchk(1,1);

% seconds of day
sod = hms(:,1)*3600 + hms(:,2)*60 + hms(:,3);

end
