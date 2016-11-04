function gps_calendar(year, outfile)
% GPS_CALENDER generate a GPS calendar and save it to a file.
%
% SYNTAX:
%	gps_calender(year, outfile);
%
% INPUT:
%	year - the year of GPS calendar (default = current year)
%   outfile - output file name (default = standard output).
%
% OUTPUT:
%	none
%
% EXAMPLE:
%   %generate GPS calendar of the current year
%	gps_calendar;
%
%   %generate GPS calendar of year 2002 and save it to 'gpscalender.2002'
%   gps_calendar(2002, 'gpscalendar.2002');
%
% See also CAL2GPST, GPST2CAL, GPST2MJD, MJD2YDOY.

% validate the number of input arguments
narginchk(0,2);

if(nargin < 1)
    c = clock; year = c(1);
else
    year = fixy2k(year);
end

if(nargin < 2)
    fid = 1;  % standard output (the screen)
else
    fid = fopen(outfile, 'wt');
    if(fid == -1)
        error('Can not open file %s to write', outfile);
    end
end

mdays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
months = {'January'; 'February'; 'March'; 'April'; 'May'; 'June'; ...
    'July'; 'August'; 'September'; 'October'; 'November'; 'December'};
weeks = {'WEEK'; 'SUN'; 'MON'; 'TUE'; 'WED'; 'THU'; 'FRI'; 'SAT'};

% Determine if the year is a leap year
if(isleapyear(year)), mdays(2) = 29; end;

width = 100; % the width of each line
split = 4;   % number of seperate blanks between left and right part
half = (width - split) /2;  % the width of left or right part

% the header of GPS calendar
header = sprintf('GPS Calendar %4d%s', year);
header = horzcat(header, blanks(width - length(header)));
header = strjust(header, 'center');
fprintf(fid, '%s\n\n\n', header);

% generate GPS calendar for every month
for m = 1:12
    % the month label
    month = horzcat(months{m}, blanks(half - length(months{m})));
    month = strjust(month, 'center');
    fprintf(fid, '%s%s%s\n', month, blanks(split), month);
    
    % the left week labels
    for i=1:length(weeks), fprintf(fid, '%6s', weeks{i}); end
    % the separate blanks
    fprintf(fid, '%s', blanks(split));
    % the right week labels
    for i=1:length(weeks), fprintf(fid, '%6s', weeks{i}); end
    fprintf(fid, '\n');
    
    % calculate the first and the last gps week number
    first_week = cal2gpst([year, m, 1, 0, 0, 0]);
    last_week  = cal2gpst([year, m, mdays(m), 0, 0, 0]);
    
    % generate GPS calendar for each week
    for gpsweek = first_week(1):last_week(1)
        % the left part of GPS calendar - day of month (day)
        fprintf(fid, '%6d', gpsweek);
        for dow = 0:6
            sow = dow * 86400;
            time = mjd2cal(gpst2mjd([gpsweek, sow]));
            if(time(2) ~= m)
                fprintf(fid, '%s', blanks(6));
            else
                fprintf(fid, '%6d', time(3));
            end
        end
        
        % the separate blanks
        fprintf(fid, '%s', blanks(split));
        
        % the right part of GPS calendar - day of year (doy)
        fprintf(fid, '%6d', gpsweek);
        for dow = 0:6
            sow = dow * 86400;
            mjd = gpst2mjd([gpsweek, sow]);
            time = mjd2cal(mjd);
            ydoy = mjd2ydoy(mjd);
            if(time(2) ~= m)
                fprintf(fid, '%s', blanks(6));
            else
                fprintf(fid, '%6d', ydoy(2));
            end
        end
        
        % next week should be in next line
        fprintf(fid, '\n');
    end
    
    % insert a blank line between this month and the next month
    fprintf(fid, '\n');
end

% if write to a file, close the file, we can't close the standard output
if( fid ~= 1), fclose(fid); end;

end

