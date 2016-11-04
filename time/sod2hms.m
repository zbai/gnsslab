function hms = sod2hms(sod)
% SOD2HMS converts seconds of day to [hour, min, sec].
%
% SYNTAX:
%	hms = sod2hms(sod);
%
% INPUT:
%	sod - seconds of day.(nx1)
%
% OUTPUT:
%	hms - time in [hour, min, sec].(nx3)
%
% See also HMS2SOD.

% validate the number of input arguments
narginchk(1,1);

sec = mod(sod, 60);
tmp = (sod - sec) / 60;
min = mod(tmp, 60);
tmp = (tmp - min) / 60;
hrs = tmp;

% The following scripts will get sec = 22.0000000000005.
%tmp = sod / 3600.0;
%hrs = fix(tmp);
%tmp = (tmp - hrs) * 60
%min = fix(tmp);
%sec = (tmp - min) * 60

hms = [hrs, min, sec];

end
