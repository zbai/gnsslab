function [sp3_hdr, sp3] = read_sp3( sp3_file )
% READ_SP3: read a sp3 file and save it to a *.mat file with the input
% file name as prefix, e.g. data read from igs21212.sp3 will be saved
% to igs21212.sp3.mat.
% NOTE: ONLY SUPPORT IGS SP3 FILES FOR TYPE "P" and VERSION "#c" BY NOW
% SYNTAX:
%	[sp3_hdr, sp3] = read_sp3(sp3_file);
%
% INPUT:
%	sp3_file - sp3 file name.
%
% OUTPUT:
%   sp3_hdr - structure of the sp3 file header
%   sp3 - matrix of the sp3 ephemeris
% 
%   sp3_hdr:
%       .version        = sp3 file version, like "#c"
%       .sp3_type       = sp3 file type, like "P" or "V"
%       .start_time     = start toc (Time of Clock) [year,month,day,hour,minute,second]
%       .epoch          = number of epochs
%       .data_type      = sp3 data type, like "ORBIT"
%       .coordinate_sys	= coordinate system
%       .orbit_type     = orbit type
%       .rel_ins        = release institution
%       .start_gpst     = start GPS time [GPSW GPSS]
%       .sep            = separation of seconds between epochs
%       .mjd            = MJD of start time (including fractions)
%       .sat_num        = satellite number
%       .sat_list       = satellite list[]
%       .sat_precise	= satellite precise list[]
%
%   sp3:
%       sp3(:,1)    = sat number
%       sp3(:,2:7)  = toc (Time of Clock) [year,month,day,hour,minute,second]
%       sp3(:,8)    = x-coordinate(m)
%       sp3(:,9)    = y-coordinate(m)
%       sp3(:,10)   = z-coordinate(m)
%       sp3(:,11)   = clock (sec)
%       sp3(:,12)   = x standard deviation (b**n m)
%       sp3(:,13)   = y standard deviation (b**n m)
%       sp3(:,14)   = z standard deviation (b**n m)
%       sp3(:,15)   = clock standard deviation (b**n sec)
% 

% validate the number of input arguments
narginchk(1,1);

% see if this file has already been read and formatted for MATLAB
mat_file = sprintf('%s.mat',lower(strtrim(sp3_file)));
if exist(mat_file, 'file')
    mat = load(mat_file, 'sp3_hdr', 'sp3');
    sp3_hdr = mat.sp3_hdr;
    sp3 = mat.sp3;
    return
end

% read the whole file to a temporary cell array
[fid, message] = fopen(sp3_file,'rt');
if fid == -1
    error ('Open file %s failed: %s.\n', sp3_file, message);
else
    buf = textscan(fid,'%s','delimiter','\n','whitespace','');
    buf = buf{1};
    fclose(fid);
end

% read header
[sp3_hdr, buf] = read_sp3_header(buf);

% check file
if sp3_hdr.version ~='c' || sp3_hdr.sp3_type ~= 'P'
    print("WARNING: This file is not supported. Unexpected error would occur.");
end

% preallocate memory
n = length(buf) - sp3_hdr.epoch;
sp3 = nan(n, 15);
m = 0; % index of sp3
space(1:80) = ' ';

while(~isempty(buf))
    line = [buf{1}, space];
    % get time
    if line(1) == '*'
        time_t = textscan(line(4:31), '%f%f%f%f%f%f%*[^\n]');
        time_t = double([time_t{1:6}]);
        buf(1) = []; % remove first line
        continue;
    end
    % start record data
    if line(1) == 'P'
        prn = line(2:4);
        sat = prn2sat(prn); % satellite int mark
        data = textscan(line(5:60), '%14f%14f%14f%14f%*[^\n]');
        sdev = {line(62:63), line(65:66), line(68:69), line(71:73)};
        sdev = cellfun(@str2double, sdev);
        data = [double([data{1:4}]), sdev ];
    elseif line(1) == 'V'
        % skip The Velocity data by now
        % will update in the next version
        continue;
    elseif line(1:2) == "EP"
        % skip The Position and Clock Correlation Record by now
        % will update in the next version
        continue;
    elseif line(1:2) == "EV"
        % skip The Velocity and Clock Rate-of-Change Correlation Record by now
        % will update in the next version
        continue;
    end
    m = m + 1;
    sp3(m,:) = [sat, time_t, data];
    buf(1) = []; % remove first line
end

% reset unit
sp3(:,8:10) = sp3(:,8:10) * 1000; % x y z , km -> m
sp3(:,12:14) = sp3(:,12:14) * 1e-3; % x y z sdev, mm -> m

sp3(:,11) = sp3(:,11) * 1e-6; % clock bias, microsec -> sec
sp3(:,15) = sp3(:,15) * 1e-12; % clock bias sdev, psec -> sec

% save to *.mat file
save(mat_file, 'sp3_hdr', 'sp3');

end


function [sp3_hdr, buf] = read_sp3_header(buf)

sp3_hdr.version = []; % sp3 file version, like "#c"
sp3_hdr.sp3_type = []; % sp3 file type, like "P" or "V"
sp3_hdr.start_time = nan(1,6); % start time YYYY MM DD hh mm ss
sp3_hdr.epoch = []; % number of epochs
sp3_hdr.data_type = []; % sp3 data type, like "ORBIT"
sp3_hdr.coordinate_sys = []; % coordinate system
sp3_hdr.orbit_type = []; % orbit type
sp3_hdr.rel_ins = []; % release institution

sp3_hdr.start_gpst = nan(1,2); % start GPS time GPSW GPSS
sp3_hdr.sep = []; % separation of seconds between epochs
sp3_hdr.mjd = []; % MJD of start time (including fractions)

sp3_hdr.sat_num = []; % satellite number
sp3_hdr.sat_list = []; % satellite list
sp3_hdr.sat_precise = []; % satellite precise list

% read sp3 file header from buf
n = 22; % rows of header
space(1:60) = ' ';

for i = 1:n
   line = [buf{i}, space];
   if i == 1 % line 1
       sp3_hdr.version = strtrim(line(2));
       sp3_hdr.sp3_type = strtrim(line(3));
       c = textscan(line(4:31), '%f%f%f%f%f%f%*[^\n]');
       sp3_hdr.start_time = double([c{1:6}]);
       sp3_hdr.epoch = str2double(line(33:39));
       sp3_hdr.data_type = strtrim(line(41:45));
       sp3_hdr.coordinate_sys = strtrim(line(47:51));
       sp3_hdr.orbit_type = strtrim(line(53:55));
       sp3_hdr.rel_ins = strtrim(line(57:60));
   elseif i == 2 % line 2
       c = textscan(line(4:60), '%f%f%f%f%f%*[^\n]');
       c = double([c{1:5}]);
       sp3_hdr.start_gpst = c(1:2);
       sp3_hdr.sep = c(3);
       sp3_hdr.mjd = c(4) + c(5);
   elseif 2 < i && i <= 7
       if i == 3 % for line 3
           sp3_hdr.sat_num = str2double(line(5:6));
       end
       c = textscan(line(10:60),'%3s','whitespace', '');
       c = cellfun(@strtrim,c{1},'UniformOutput',false);
       sp3_hdr.sat_list = [sp3_hdr.sat_list, string(c).'];
   elseif 7 < i && i <= 12
       c = textscan(line(10:60),'%3s','whitespace', '');
       c = cellfun(@str2double,c{1}.');
       sp3_hdr.sat_precise = [sp3_hdr.sat_precise, c];
%    else continue
   end
    
end

sp3_hdr.sat_list = sp3_hdr.sat_list(1:sp3_hdr.sat_num); % trim satellite list
sp3_hdr.sat_precise = sp3_hdr.sat_precise(1:sp3_hdr.sat_num); % trim satellite precise list
buf(1:i) = []; % trim buf

end