function gpst = sec2gpst(seconds)
% SEC2GPST converts GPS time in seconds since the begining of GPS time
% (0hr, Jan 6 1980) to gps week and seconds of week.
%
% SYNTAX:   
%	gpst = sec2gpst(seconds);
%
% INPUT:
%	seconds - seconds since the begining of GPS time(0hr, Jan 6 1980).(nx1)
%
% OUTPUT:
%   gpst - GPS time[week, sow]. (nx2)
%
% See also GPST2SEC.

% validate the number of input arguments
narginchk(1,1);

week = floor(seconds/604800);
sow  = seconds - week*604800;

gpst = [week sow];

end 

