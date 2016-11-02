function gnsslab_install()
% INSTALL adds the necessary folders to the MATLAB path for the GNSSLAB
% toolbox to be used from anywhere.
%
% SYNTAX:
%   >> GNSSLAB_INSTALL
%
% INPUT:
%   none
%
% OUTPUT: none
%   none
%
% See also GNSSLAB_UNINSTALL, GENPATH, SAVEPATH, VER.

% Check the version
matlab = ver('MATLAB' );
if datenum( matlab.Date ) < datenum( '08-Jul-2011' )
    fprintf('GNSSLab has been built and tested on MATLAB R2011b and above.\n');
    fprintf('You are using an older version and may experience problems.\n' )
end

% Add the folders to the path
folder = fileparts( mfilename( 'fullpath' ) );

pathstr = genpath(folder);
seplocs = strfind(pathstr, pathsep);
loc1 = [1 seplocs(1:end-1)+1];
loc2 = seplocs(1:end)-1;
dirs = arrayfun(@(a,b) pathstr(a:b), loc1, loc2, 'UniformOutput', false);

for dd = 1:numel( dirs )
    addpath( dirs{dd} );
    fprintf( '+ Folder added to path: %s\n', dirs{dd} );
end

% Save the changes to make the installation permanent
if savepath() == 0
    % Success
    fprintf( 'GNSSLab installed\n' );
else
    % Failure
    fprintf( 'Failed to add GNSSLab to the MATLAB path\n' );
end

end

