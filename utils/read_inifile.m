function opt = read_inifile(ini_file)
% READ_INIFILE reads a .ini file and returns a struct with section names
% and keys as fields, based on ini2struct.m by andriy nych and freeb.

% http://cn.mathworks.com/matlabcentral/fileexchange/22079-struct2ini
% http://cn.mathworks.com/matlabcentral/fileexchange/45725-ini2struct
% http://cn.mathworks.com/matlabcentral/fileexchange/17177-ini2struct

% 2016/01/02

% read the ini file to a temporary cell array
[fid, message] = fopen (ini_file,'rt');
if fid == -1
    error ('Open %s failed: %s.\n', ini_file, message);
else
    buf = textscan(fid,'%s','delimiter','\n','whitespace','');
    buf = buf{1};
end
fclose(fid);

% remove leading/trailing spaces
buf = strtrim(buf);
% remove empty lines
ii = cellfun(@(x)(isempty(x)), buf);
buf(ii) = [];
% remove comments lines
ii = cellfun(@(x)(x(1)==';'||x(1)=='#'), buf);
buf(ii) = [];
% remove invalid lines
ii = cellfun(@(x)(isempty(strfind(x,'=')) & isempty(strfind(x,'['))), buf);
buf(ii) = [];

n = length(buf);
for i = 1:n
    s = buf{i};
    if s(1)=='[' && ~isempty(strfind(s,']'))
        % section header
        if(i<n && buf{i+1}(1)~= '[')
            % create field
            section = genvarname(strtok(s(2:end), ']'));
            opt.(section) = [];
        end
        continue;
    end
    
    % split key = value ; comment
    p = regexp(s,'=','split');
    % remove leading/trailing spaces
    key = strtrim(p{1});
    val = strtrim(p{2});
    
    if isempty(key)
        continue;
    elseif isempty(val) || val(1)==';' || val(1)=='#'
        % empty entry
        val = [];
    elseif val(1)=='"'
        % double-quoted string
        val = strtok(val, '"');
    elseif val(1)==''''
        % single-quoted string
        val = strtok(val, '''');
    else
        % remove inline comment
        val = strtok(val, ';');
        val = strtok(val, '#');
        % remove leading/trailing spaces
        val = strtrim(val);
        % convert string to number(s)
        [x, status] = str2num(val);	%#ok<ST2NM>
        if status, val = x; end
    end
    
    if ~exist('section', 'var')
        % no section found before
        opt.(genvarname(key)) = val;
    else
        % section found before, fill it
        opt.(section).(genvarname(key)) = val;
    end
    
end

end