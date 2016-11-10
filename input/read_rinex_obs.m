function [hdr, obs] = read_rinex_obs(obs_file)

% READ_RINEX_OBS read a RINEX observation file and save it in a *.mat file
% with the input file name as prefix, e.g. data read from alic0520.03o will
% be saved in alic0520.03o.mat, which will be loaded next time to save time.
%
% SYNTAX:
%   [hdr, obs] = read_rinex_obs(obs_file);
%
% INPUT:
%   obs_file - RINEX observation file name.
%
% OUTPUT:
%   hdr - structure of the observation file header.
%   obs - matrix of the observation data. The columns are defined as:
%         [week, sow, flag, sat, C1, L1, S1, D1, C2, L2, S2, D2, C3, L3, S3, D3]
%         Data not available in the obs_file will be filled with NaN.
%
% EXAMPLE:
%	[hdr, obs] = read_rinex_obs('alic0520.03o');
%
% See also READ_RINEX_NAV, READ_SP3, FIXY2K, CAL2GPST.

% validate the number of input arguments
narginchk(1,1);

% see if this file has already been read and formatted for MATLAB
mat_file = sprintf('%s.mat',lower(strtrim(obs_file)));
if exist(mat_file, 'file')
    mat = load(mat_file, 'hdr', 'obs');
    hdr = mat.hdr;
    obs = mat.obs;
    return
end

% read the whole file to a temporary cell array
[fid, message] = fopen(obs_file,'rt');
if fid == -1
    error ('Open file %s failed: %s.\n', obs_file, message);
else
    buf = textscan(fid,'%s','delimiter','\n','whitespace','');
    buf = buf{1};
end
fclose(fid);

% read the file header
[hdr, buf] = read_obs_header(buf);

% check if it is a observation file
if (hdr.type ~= 'O')
    error ('%s is not a RINEX observation file',obs_file);
end

% read the observation data
if(hdr.ver < 3.0)
    obs = read_rinex2_obs(hdr, buf);
else
    obs = read_rinex3_obs(hdr, buf);
end

epoch = unique(cal2gpst(obs(:,1:6)), 'rows');
if ~isempty(epoch)
    hdr.gpst = [epoch(1,1:2), epoch(end,1:2)];
else
    hdr.gpst = [NaN, NaN];
end

% save to a .mat file
save(mat_file, 'hdr', 'obs');

end

%-----------------------------------------------------------------------------
% read observation file header from the buffer, Rinex 2.xx & 3.xx
%-----------------------------------------------------------------------------
function [hdr, buf] = read_obs_header(buf)

space(1:80) = ' ';
n = length(buf);
i = 0; % index of buf

hdr.type = [];
hdr.nobs = zeros(1,4);
hdr.obstype = cell(1,4);
hdr.marker = cell(1,2);
hdr.pos = nan(1,3);
hdr.delta = nan(1,3);

while (i < n)
    i = i + 1;
    line = [buf{i}, space];
    label = upper(strtrim(line(61:80)));
    
    if strcmpi(label, 'RINEX VERSION / TYPE')
        hdr.ver  = str2double(line(1:9));
        hdr.type = upper(line(21:21));
        hdr.sys  = upper(line(41:41));
        if(hdr.sys == ' '), hdr.sys = 'G'; end
    elseif strcmpi(label, 'PGM / RUN BY / DATE')
        hdr.pgm   = strtrim(line( 1:20));
        hdr.runby = strtrim(line(21:40));
        hdr.date  = strtrim(line(41:60));
    elseif strcmpi(label, 'MARKER NAME')
        hdr.marker{1} = strtrim(line(1:60));
    elseif strcmpi(label, 'MARKER NUMBER')
        hdr.marker{2} = strtrim(line(1:21));
    elseif strcmpi(label, 'OBSERVER / AGENCY')
        hdr.observer = strtrim(line( 1:20));
        hdr.agency   = strtrim(line(21:60));
    elseif strcmpi(label, 'REC # / TYPE / VERS')
        hdr.rcv{1} = strtrim(line( 1:20));
        hdr.rcv{2} = strtrim(line(21:40));
        hdr.rcv{3} = strtrim(line(41:60));
    elseif strcmpi(label, 'ANT # / TYPE')
        hdr.ant{1} = strtrim(line( 1:20));
        hdr.ant{2} = strtrim(line(21:40));
    elseif strcmpi(label, 'APPROX POSITION XYZ')
        hdr.pos(1) = str2double(line( 1:14));
        hdr.pos(2) = str2double(line(15:28));
        hdr.pos(3) = str2double(line(29:42));
    elseif strcmpi(label, 'ANTENNA: DELTA H/E/N')
        hdr.delta(1) = str2double(line( 1:14));
        hdr.delta(2) = str2double(line(15:28));
        hdr.delta(3) = str2double(line(29:42));
    elseif strcmpi(label, 'WAVELENGTH FACT L1/2')
        hdr.wfact(1) = str2double(line( 1: 6));
        hdr.wfact(2) = str2double(line( 7:12));
    elseif strcmpi(label, '# / TYPES OF OBSERV') %2.xx
        nobs = str2double (line(1:6));
        line = line(7:60);
        % read next line and if nobs > 9
        for k = 10:9:hdr.nobs
            i = i+1;
            next = [buf{i}, space];
            line = [line, next(7:60)]; %#ok<AGROW>
        end;
        c = textscan(line, '%6s', nobs, 'whitespace', '');
        hdr.obstype(1:4) = strtrim(c(:));
        hdr.nobs(1:4) = nobs;
    elseif strcmpi(label, 'SYS / # / OBS TYPES') %3.xx
        sys  = upper(line(1));
        nobs = sscanf(line(2:6),'%d');
        line = line(7:58);
        % read next line and if nobs > 13
        for k = 14:13:nobs
            i = i+1;
            next = [buf{i}, space];
            line = [line, next(7:58)]; %#ok<AGROW>
        end
        c = textscan(line, '%4s', nobs, 'whitespace', '');
        if(sys == 'G'), hdr.obstype{1} = strtrim(c{:}); hdr.nobs(1) = nobs; end
        if(sys == 'R'), hdr.obstype{2} = strtrim(c{:}); hdr.nobs(2) = nobs; end
        if(sys == 'E'), hdr.obstype{3} = strtrim(c{:}); hdr.nobs(3) = nobs; end
        if(sys == 'C'), hdr.obstype{4} = strtrim(c{:}); hdr.nobs(4) = nobs; end
    elseif strcmpi(label, 'INTERVAL')
        hdr.interval = str2double(line(1:10));
    elseif strcmpi(label, 'END OF HEADER')
        break;
    end
end

buf(1:i) = [];

end

%-----------------------------------------------------------------------------
% read observation data from the buffer, Rinex 2.xx
%-----------------------------------------------------------------------------
function obs = read_rinex2_obs(hdr, buf)

space(1:80) = ' ';
n = length(buf);
i = 0; % index of buf

nobs = hdr.nobs(1);
obs  = nan(n,8+nobs); % preallocate memory
m = 0; % index of obs

while (i < n)
    i = i + 1;
    line = [buf{i}, space];
    c = textscan(line, '%3d%3d%3d%3d%3d%11.7f%3d%3d',1);
    time = double([c{1:6}]); 
    flag = double(c{7});
    nsat = c{8};
    time(1) = fixy2k(time(1));
    
    % get the list of prns in current epoch
    line = line(33:68);
    for k = 13:12:nsat % read next line if nsat > 12
        i = i + 1;
        next = [buf{i}, space];
        line = [line, next(33:68)]; %#ok<AGROW>
    end;
    c = textscan(line, '%3s', nsat, 'whitespace','');
    sat = prn2sat(c);
    
    if flag > 1, i = i + nsat; continue; end
    
    % read the observations
    for j = 1:nsat
        i = i + 1;
        line = [buf{i}, space];
        line = line(1:80);
        for k = 6:5:hdr.nobs, % read next line if obstypes > 5
            i = i + 1;
            next = [buf{i}, space];
            line = [line, next(1:80)]; %#ok<AGROW>
        end
        
        c = textscan(line, '%14s%1s%1s', nobs, 'whitespace','');
        c = cellfun(@str2double, c{1});
        c = c';
        
        m = m + 1;
        obs(m,1:8) = [time, flag, sat(j)];
        obs(m,8+(1:nobs)) = c;
    end
end

% free the extra preallocated memory
obs(m+1:end,:) = [];

end

%-----------------------------------------------------------------------------
% read observation data from the buffer, Rinex 3.xx
%-----------------------------------------------------------------------------
function obs = read_rinex3_obs(hdr, buf)

space(1:256) = ' ';
n = length(buf);
i = 0; % index of buf

nobs = max(hdr.nobs);
obs  = nan(n,8+nobs); % preallocate memory
m = 0; % index of obs

while (i < n)
    i = i + 1;
    line = [buf{i}, space];
    c = textscan(line(3:end), '%4d%3d%3d%3d%3d%11.7f%3d%3d',1);
    time = double([c{1:6}]); 
    flag = double(c{7});
    nsat = c{8};
    time(1) = fixy2k(time(1));
    
    if flag > 1, i = i + nsat; continue; end
    
    % read the observations
    for j = 1:nsat
        i = i + 1;
        line = [buf{i}, space];
        prn = line(1:3);
        sat = prn2sat(prn);
        
        c = textscan(line(4:end), '%14s%1s%1s', nobs, 'whitespace','');
        c = cellfun(@str2double, c{1});
        c = c';
        
        m = m + 1;
        obs(m,1:8) = [time, flag, sat];
        obs(m,8+(1:nobs)) = c;
    end
end

% free the extra preallocated memory
obs(m+1:end,:) = [];

end
