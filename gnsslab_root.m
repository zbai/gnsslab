function folder = gnsslab_root()
% GNSSLAB_ROOT returns the folder containing the gnsslab toolbox
%
% SYNTAX:
%   folder = gnsslab_root()
%
% INPUT:
%   none
%
% OUTPUT:
%   folder - the full path to the folder containing the gnsslab toolbox.
%
% See also GNSSLAB_VERSION.

folder = fileparts( mfilename( 'fullpath' ) );

end