function write_inifile(ini_file, options)
% WRITE_INIFILE writes options(as a structure) into an .ini file, based
% on struct2ini.m by Dirk Lohse. it's the opposite to READ_INIFILE.

% http://cn.mathworks.com/matlabcentral/fileexchange/22079-struct2ini
% http://cn.mathworks.com/matlabcentral/fileexchange/45725-ini2struct
% http://cn.mathworks.com/matlabcentral/fileexchange/17177-ini2struct

% 2016/01/02

% open file, or create new file, for writing the options
[fid, message] = fopen (ini_file,'wt');
if fid == -1
    error ('open %s failed: %s.\n', ini_file, message);
end

% get the sections from the given structure.
sections = fieldnames(options);

for i=1:length(sections)
    section = sections{i};
    
    if isstruct(options.(section))
        % it is a section
        fprintf(fid,'\n[%s]\n',section);
        
        keys = fieldnames(options.(section));
        for j=1:length(keys)
            key = keys{j};
            val = options.(section).(key);
            
            if isnumeric(val)
                val = num2str(val);
                val = regexprep(val,'\s+',', ');
            end
            fprintf(fid,'%s = %s\n',key, val);
        end
    else
        % it is a key-value pair
        key = section;
        val = options.(section);
        if isnumeric(val)
            val = num2str(val);
            val = regexprep(val,'\s+',', ');
        end
        fprintf(fid,'%s = %s\n',key, val);
    end
end

fclose(fid);

end
