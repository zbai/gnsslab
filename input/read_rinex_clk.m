function [hdr, clk] = read_rinex_clk(clk_file)
% READ_RINEX_CLK read a RINEX clock file.
%
% SYNTAX:
%   [hdr, clk] = read_rinex_clk(clk_file);
%
% INPUT:
%   clk_file - Name of RINEX clock file.
%
% OUTPUT:
%   hdr - structure of the clock file header.
%   clk - matrix of the satellite clock data. (nx10)
%
% EXAMPLE:
%	[hdr, clk] = read_rinex_clk('d:\1202\rinex3\igr18733.clk');
%
% See also READ_RINEX_OBS, READ_RINEX_NAV, READ_SP3, FIXY2K, CAL2GPST.

% validate the number of input arguments
narginchk(1,1);

if ~exist(clk_file, 'file')
    error ('File %s NOT exists.\n', clk_file);
else
    clk_file = which(clk_file);
end

% see if this file has already been read and formatted for MATLAB
[folder, name, ext] = fileparts(clk_file);
mat_file = fullfile(folder, lower([name, ext, '.mat']));
if exist(mat_file, 'file')
    mat = load(mat_file, 'hdr', 'clk');
    hdr = mat.hdr;
    clk = mat.clk;
    return
end

% read the whole file to a temporary cell array
[fid, message] = fopen(clk_file,'rt');
if fid == -1
    error ('Open file %s failed: %s.\n', clk_file, message);
else
    buf = textscan(fid,'%s','delimiter','\n','whitespace','');
    buf = buf{1};
end
fclose(fid);

% read clock file header from buf
hdr.type = '';
for i = 1:length(buf)
    line  = [buf{i}, blanks(256)];
    label = upper(strtrim(line(61:80)));
    
    if strcmpi(label, 'RINEX VERSION / TYPE')
        hdr.type  = line(21:21);
        hdr.ver   = str2double(line(1:9));
    elseif strcmpi(label, 'END OF HEADER')
        break;
    end
end

% check if it is a rinex clock file
if (hdr.type ~= 'C')
    error ('%s is not a RINEX clock file',clk_file);
end;

% remove the header from the buf
buf(1:i) = []; 

% the satellite clock records
str = char(buf);
ii  = strcmpi(cellstr(str(:,1:2)),'AS');
str = str(ii,:);
sat = prn2sat(str(:,4:6)); 
buf = cellstr(str(:,7:end));

n = numel(buf); 
clk = nan(n,10);
clk(:,1) = sat;
space(1:80) = ' ';

for i = 1:n
    line = [buf{i}, space];

    c = textscan(line, '%6s%3s%3s%3s%3s%10s%3s%22s%22s', 1, 'whitespace','');
    c = cellfun(@str2double, c);
    clk(i,2:10) = c;
end

epoch = unique(cal2gpst(clk(:,2:7)), 'rows');
if ~isempty(epoch)
    hdr.gpst = [epoch(1,1:2), epoch(end,1:2)];
else
    hdr.gpst = [NaN, NaN];
end

% save to file for later use
save(mat_file, 'hdr', 'clk');

end


