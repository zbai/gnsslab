function gpst = cal2gpst(time)
% CAL2GPST converts calendar date and time to GPS week and seconds of week.
%
% SYNTAX:
%   gpst = cal2gpst(time);
%
% INPUT:
%	time - calendar date and time [yr mon day hr min sec]. (nx3 or nx6)
%
% OUTPUT:
%   gpst - GPS time[gpsweek sow]. (nx2)
%
% See also GPTS2CAL.

% validate the number of input arguments
narginchk(1, 1);

cols = size(time,2);
if(cols ~= 3 && cols ~= 6), error('Invalid column number'); end

% fix y2k problem
time(:,1) = fixy2k(time(:,1));

%number of days since the beginning of GPS time
days = datenum(time(:,1:3)) - datenum([1980,1,6]);
if(cols == 6) % seconds of day
    sod = time(:,4)*3600 + time(:,5)*60 + time(:,6);
else
    sod = 0.0;
end

week = floor(days/7); %GPS week
sow  = (days - week*7)*86400 + sod; %GPS seconds of week
gpst = [week, sow];

end
