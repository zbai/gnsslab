function gnsslab_uninstall()
% UNINSTALL remove the GNSSLab toolbox from the MATLAB path
%
% SYNTAX:
%   >> gnsslab_uninstall
%
% INPUT:
%   none
%
% OUTPUT:
%   none
%
% See also GNSSLAB_INSTALL, GENPATH, SAVEPATH, VER.

folder = fileparts( mfilename( 'fullpath' ) );

pathstr = genpath(folder);
seplocs = strfind(pathstr, pathsep);
loc1 = [1 seplocs(1:end-1)+1];
loc2 = seplocs(1:end)-1;
dirs = arrayfun(@(a,b) pathstr(a:b), loc1, loc2, 'UniformOutput', false);

for dd = 1:numel( dirs )
    rmpath( dirs{dd} );
    fprintf( '- Folder removed from path: %s\n', dirs{dd} );
end

% Save the changes to make the installation permanent
if savepath() == 0
    % Success
    fprintf( 'GNSSLab uninstalled\n' );
else
    % Failure
    fprintf( 'Failed to remove GNSSLab from the MATLAB path\n' );
end

end