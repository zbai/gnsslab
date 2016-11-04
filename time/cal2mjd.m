function mjd = cal2mjd(time)
% CAL2MJD  Converts calendar date and time [yr,mon,day,hr,min,sec] to
% Modified Julian date & seconds of day [mjd,sod].  
% 
% SYNTAX:   
%	mjd = cal2mjd(time); 
%
% INPUT:
%	time - calendar date and time [yr,mon,day,hr,min,sec]. (nx3 or nx6)
%
% OUTPUT:
%   mjd - Modified Julian date & seconds of day [mjd,sod]. (nx2)
%
% See also MJD2CAL, FIXY2K.

% validate number of input arguments
narginchk(1,1);

[rows, cols] = size(time);
if(cols < 3), error('Invalid column number'); end

% fix y2k problem
time(:,1) = fixy2k(time(:,1));

% converts (year month day) to Julian date
mjd_gps = 44244; % mjd of the begining of GPST (Jan 1,2006)
day_gps = datenum([1980,1,6]); % day number of (Jan 1,2006)

day = datenum(time(:,1:3));
mjd = (day - day_gps) + mjd_gps;

hms = zeros(rows,3);
if(cols >= 4), hms(:,1) = time(:,4); end;
if(cols >= 5), hms(:,2) = time(:,5); end;
if(cols >= 6), hms(:,3) = time(:,6); end;

% seconds of day
sod = hms(:,1)*3600 + hms(:,2)*60 + hms(:,3);

% in case mjd has fraction part
mjd1 = floor(mjd);
mjd2 = sod + (mjd - mjd1) * 86400;

% in case sod > 86400
mjd(:,1) = mjd1 + floor(mjd2/86400);
mjd(:,2) = mod(mjd2, 86400);

end
