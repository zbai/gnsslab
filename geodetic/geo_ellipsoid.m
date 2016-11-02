function ell = geo_ellipsoid(name)
% GET_ELLIPSOID returns the semi-major axis, flattening and other parameters for
% a particular reference ellipsoid. if no argument is given, WGS84 returned.
%
% SYNTAX:
%   ell = geo_ellipsoid(name);
%
% INPUT:
%   name - the name of the reference ellipsoid. [default: WGS84]
%           'CLK66'    = Clarke 1866
%           'GRS67'    = Geodetic Reference System 1967
%           'GRS80'    = Geodetic Reference System 1980
%           'WGS72'    = World Geodetic System 1972
%           'WGS84'    = World Geodetic System 1984
%           'ATS77'    = Quasi-earth centred ellipsoid for ATS77
%           'NAD27'    = North American Datum 1927 (=CLK66)
%           'NAD83'    = North American Datum 1983 (=GRS80)
%           'INTER'    = International
%           'KRASS'    = Krassovsky (USSR)
%           'CGCS2000' = China CGCS 2000
%
% OUTPUT:
%   ell  - the requested ellipsoid parameters, contains
%           ell.a     = semi-major axis (m)
%           ell.f     = flattening
%           ell.b     = minor semi-axis (m)
%           ell.e     = the first eccentricity
%           ell.mu    = Earth¡¯s Gravitational Constant(m3/s2)
%           ell.omega = Earth's angular velocity (radians/sec)
%
% REFERENCE:
% 	Department of Defence World Geodetic System 1984, DMA TR 8350.2, 1987.
%
% EXAMPLE:
% 	wgs84 = geo_ellipsoid('WGS84');
%
% See also XYZ2LLH, LLH2XYZ.

% the cell array contains ellipsoids for use, feel free to add your own
ellipsoids = {
    'CLK66',    6378206.4, 294.9786982;   % Clarke 1866
    'GRS67',    6378160.0, 298.247167427; % GRS 1967
    'GRS80',    6378137.0, 298.257222101; % GRS 1980
    'WGS72',    6378135.0, 298.26;        % WGS 1972
    'WGS84',    6378137.0, 298.257223563; % WGS 1984
    'ATS77',    6378135.0, 298.257;       % ATS77
    'NAD27',    6378206.4, 294.9786982;   % North American Datum 1927
    'NAD83',    6378137.0, 298.257222101; % North American Datum 1983
    'INTER',    6378388.0, 297.0;         % International
    'KRASS',    6378245.0, 298.3;         % Krassovsky (USSR)
    'CGCS2000', 6378137.0, 298.257223563; % China CGCS 2000
    };

if nargin == 0,
    name = 'WGS84'; % default return WGS84
else
    name = strtrim(upper(name));
end

fields = {'name', 'a', 'f'};

% find the parameters of the requested ellipsoid
idx = strcmp(name, ellipsoids(:,1));
ell = cell2struct(ellipsoids(idx,:), fields, 2);

if isempty(ell)
    error('Ellipsoid %s not found.', name);
else
    ell.f = 1/ell.f;
    
    % product of the Earth's mass and the Gravitational Constant(WGS-84)
    ell.mu = 3.986004418e14; % m3/s2
    % Earth's angular velocity (WGS-84)
    ell.omega = 7292115e-11; % radians/sec
    
    % calculate other parameters
    ell.b  = ell.a * (1 - ell.f);       % semi-minor axis
    ell.e  = sqrt(1 - (1 - ell.f)^2);   % first numerical eccentricity
end

end