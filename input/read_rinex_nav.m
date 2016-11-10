function [hdr, nav] = read_rinex_nav( nav_file )

% READ_RINEX_NAV: read a RINEX navigation file and save it to a *.mat file
% with the input file name as prefix, e.g. data read from alic0520.03n will
% be saved in alic0520.03n.mat.
%
% SYNTAX:
%	[hdr, nav] = read_rinex_nav(nav_file);
%
% INPUT:
%	nav_file - Rinex navigation file name.
%
% OUTPUT:
%   hdr - structure of the navigation file header
%   nav - matrix of the broadcast ephemeris parameters
%
%   nav(:,1)   = sat number
%   nav(:,2:07)= toc (Time of Clock) [year,month,day,hour,minute,second]
%   nav(:,8:10)= sat clock bias,drift, drift-rate(sec,sec/sec,sec/sec^2)
%   nav(:,11)  = IODE, Issue of Data, Ephemeris
%   nav(:,12)  = crs                      (m)
%   nav(:,13)  = delta n                  (rad/sec)
%   nav(:,14)  = M0                       (rad)
%   nav(:,15)  = cuc                      (rad)
%   nav(:,16)  = e Eccentricity
%   nav(:,17)  = cus                      (rad)
%   nav(:,18)  = sqrt(A)                  (sqrt(m))
%   nav(:,19)  = toe (Time of Ephemeris)  (sec of GPS week)
%   nav(:,20)  = cic                      (rad)
%   nav(:,21)  = OMEGA                    (rad)
%   nav(:,22)  = cis                      (rad)
%   nav(:,23)  = i0                       (rad)
%   nav(:,24)  = crc                      (m)
%   nav(:,25)  = omega                    (rad)
%   nav(:,26)  = OMEGA DOT                (rad/sec)
%   nav(:,27)  = IDOT                     (rad/sec)
%   nav(:,28)  = Codes on L2 channel
%   nav(:,29)  = GPS Week # (to go with Toe)
%   nav(:,30)  = L2 P data flag
%   nav(:,31)  = accuracy              (m)
%   nav(:,32)  = health                (MSB only)
%   nav(:,33)  = TGD                      (sec)
%   nav(:,34)  = IODC Issue of Data, Clock
%   nav(:,35)  = Transmission time of message (sec of GPS week,
%   nav(n,36)  = fit Interval
%   nav(n,37)  = spare
%   nav(n,38)  = spare
%
%   gps_iono   = GPS ionospheric parameters [a0,a1,a2,a3;b0,b1,b2,b3]
%   bds_iono   = GPS ionospheric parameters [a0,a1,a2,a3;b0,b1,b2,b3]
%   dutc   = delta utc parameters [A1,A2,T,W]

% See also READ_RINEX_OBS, READ_SP3, FIXY2K, CAL2GPST.

% validate the number of input arguments
narginchk(1,1);

% see if this file has already been read and formatted for MATLAB
mat_file = sprintf('%s.mat',lower(strtrim(nav_file)));
if exist(mat_file, 'file')
    mat = load(mat_file, 'hdr', 'nav');
    hdr = mat.hdr;
    nav = mat.nav;
    return
end

% read the whole file to a temporary cell array
[fid, message] = fopen(nav_file,'rt');
if fid == -1
    error ('Open file %s failed: %s.\n', nav_file, message);
else
    buf = textscan(fid,'%s','delimiter','\n','whitespace','');
    buf = buf{1};
end
fclose(fid);

[hdr, buf] = read_nav_header(buf);

% check if it is a navigation file
if(hdr.type ~= 'N')
    error ('%s is not a RINEX navigation file', nav_file);
end

% preallocate memory
n = length(buf);
nav = nan(n, 38);
m = 0; % index of nav
space(1:80) = ' ';

if (hdr.ver < 3.0)
    for i = 1:length(buf), buf{i} = [' ', buf{i}]; end
end

while (~isempty(buf))
    line = [buf{1}, space];
    if (hdr.ver < 3.0)
        prn = sprintf('%c%02d', hdr.sys, str2double(line(1:3)));
    else
        prn = line(1:3);
    end
    sat = prn2sat(prn);
    c = textscan(line(4:23), '%f%f%f%f%f%f%*[^\n]');
    time = double([c{1:6}]); time(1) = fixy2k(time(1));
    
    if(prn(1) == 'G' || prn(1) == 'C' || prn(1) == 'E' || prn(1) == 'J' || prn(1) == 'I')
        nl = 8; % number of lines
    elseif (prn(1) == 'R' || prn(1) == 'S')
        nl = 4; % number of lines
    else
        error('Invalid satellite ephemeris.\n');
    end
    
    str = line(24:80);
    for i = 2:nl
        next = [buf{i}, space];
        str  = [str, next(5:80)]; %#ok<AGROW>
    end
    nf = 3 + (nl-1)*4; % number of fields
    str = strrep(upper(str), 'D', 'e');
    c = textscan(str, '%19s', nf, 'whitespace', '');
    c = cellfun(@str2double, c{1});
    
    m = m + 1;
    nav(m,1:(7+nf)) = [sat, time, c(1:nf)'];
    
    buf(1:nl) = [];
end

% remove the extra preallocated memory
nav(m+1:end,:) = [];

epoch = unique(cal2gpst(nav(:,2:7)), 'rows');
if ~isempty(epoch)
    hdr.gpst = [epoch(1,1:2), epoch(end,1:2)];
else
    hdr.gpst = [NaN, NaN];
end

% save to a .mat file
save(mat_file, 'hdr', 'nav');

end

function [hdr, buf] = read_nav_header(buf)
% Read the rinex navigation file header from buf

hdr.type = [];
hdr.iono = nan(4,8);
hdr.dutc = nan(4,4);

% read navigation file header from buf
n = length(buf);
space(1:80) = ' ';

for i = 1:n
    % read a line and make sure its length exceed 80
    line = [buf{i}, space];
    label = upper(strtrim(line(61:80)));
    % correct misspelling of IONOSPHERIC for NAVCOM
    label = strrep(label, 'IONOSPHDRIC CORR', 'IONOSPHERIC CORR');
    
    if strcmpi(label, 'RINEX VERSION / TYPE')
        hdr.ver  = str2double(line(1:9));
        hdr.type = upper(line(21:21));
        hdr.sys  = upper(line(41:41));
        if(hdr.ver < 3.0)
            if hdr.type == 'G', hdr.sys = 'R'; hdr.type = 'N'; end % GLO
            if hdr.type == 'N', hdr.sys = 'G'; hdr.type = 'N'; end % GPS
            if hdr.type == 'B', hdr.sys = 'C'; hdr.type = 'N'; end % BDS
            if hdr.type == 'C', hdr.sys = 'C'; hdr.type = 'N'; end % BDS
        end
    elseif strcmpi(label,  'PGM / RUN BY / DATE')
        hdr.pgm   = line( 1:20);
        hdr.runby = line(21:40);
        hdr.date  = line(41:60);
    elseif strcmpi(label,  'ION ALPHA')
        line = strrep(upper(line), 'D', 'e');
        a0 = str2double(line( 3:14));
        a1 = str2double(line(15:26));
        a2 = str2double(line(27:38));
        a3 = str2double(line(39:50));
        if hdr.sys == 'G', hdr.iono(1,1:4) = [a0,a1,a2,a3]; end
        if hdr.sys == 'R', hdr.iono(3,1:4) = [a0,a1,a2,a3]; end
        if hdr.sys == 'E', hdr.iono(4,1:4) = [a0,a1,a2,a3]; end
        if hdr.sys == 'C', hdr.iono(2,1:4) = [a0,a1,a2,a3]; end
    elseif strcmpi(label,  'ION BETA')
        line = strrep(upper(line), 'D', 'e');
        b0 = str2double(line( 3:14));
        b1 = str2double(line(15:26));
        b2 = str2double(line(27:38));
        b3 = str2double(line(39:50));
        if hdr.sys == 'G', hdr.iono(1,5:8) = [b0,b1,b2,b3]; end
        if hdr.sys == 'R', hdr.iono(3,5:8) = [b0,b1,b2,b3]; end
        if hdr.sys == 'E', hdr.iono(4,5:8) = [b0,b1,b2,b3]; end
        if hdr.sys == 'C', hdr.iono(2,5:8) = [b0,b1,b2,b3]; end
    elseif strcmpi(label, 'DELTA-UTC: A0,A1,T,W')
        line = strrep(upper(line), 'D', 'e');
        hdr.dutc(1,1) = str2double(line( 4:22));
        hdr.dutc(1,2) = str2double(line(23:41));
        hdr.dutc(1,3) = str2double(line(42:50));
        hdr.dutc(1,4) = str2double(line(51:59));
    elseif strcmpi(label,'IONOSPHERIC CORR')% 3.xx
        line = strrep(upper(line), 'D', 'e');
        a0 = str2double(line( 6:17));
        a1 = str2double(line(18:29));
        a2 = str2double(line(30:41));
        a3 = str2double(line(42:53));
        if strcmpi(line(1:4),'GPSA'), hdr.iono(1,1:4) = [a0,a1,a2,a3]; end
        if strcmpi(line(1:4),'GPSB'), hdr.iono(1,5:8) = [a0,a1,a2,a3]; end
        if strcmpi(line(1:4),'COMA'), hdr.iono(4,1:4) = [a0,a1,a2,a3]; end
        if strcmpi(line(1:4),'COMB'), hdr.iono(4,5:8) = [a0,a1,a2,a3]; end
    elseif strcmpi(label, 'TIME SYSTEM CORR') % 3.xx
        %GAUT -5.5879354477e-09-2.664535259e-15 172800 1873
        %fprintf('ignored');
    elseif strcmpi(label, 'LEAP SECONDS')
        hdr.leapsec = str2double(line(1:6));
    elseif strcmpi(label, 'END OF HEADER')
        break;
    end
end

buf(1:i) = [];

end
