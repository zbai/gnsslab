function seconds = gpst2sec(gpst)
% GPST2SEC convert GPS time [gpsweek,sow] to seconds since the begining
% of GPS time (Jan 6 1980).
%
% SYNTAX:
%	seconds = gpst2sec(gpst);
%
% INPUT:
%   gpst - GPS time[gpsweek,sow]. (nx2)
%
% OUTPUT:
%	seconds - seconds since the begining of GPS time (Jan 6 1980). (nx1)
%
% See also SEC2GPST.

% validate number of input arguments
narginchk(1,1);

seconds = gpst(:,1)*604800 + gpst(:,2);

end

