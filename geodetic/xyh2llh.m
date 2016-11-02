function llh = xyh2llh(xyh, proj, ell)
% XYH2LLH converts plane coordinates (x,y) to geodetic (lat,lon) using
% Transverse Mercator projection formulas (either Universal Transverse
% Mercator (UTM) or Gauss-Kruger depending on the projection parameters).
% It also converts orthometric height to geodetic height using the geoidal
% undulation from EGM96 model if provided.
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid
% 	llh = xyh2llh(xyh, proj);
%
%   % conversion using user defined ellipsoid
%   ell = get_datum('KRASS');
%   llh = xyh2llh(xyh, proj, ell)
%
% INPUT:
%    xyh - plane coordinates and orthometric height [x,y,h], x, y
%           correspond to north and east direction respectively. (nx3)
%	proj - projection parameters [lat0,lon0,scale,dN,dE]
%          lat0 : Latitude  of natural origin in radians. [default: 0]
%          lon0 : Longitude of natural origin in radians.
%                 [default: 6бу intervals central meridian]
%          scale: Scale at natural origin; usually 1 Gauss-Kruger and
%                 0.9996 for UTM. [default: 1.0]
%          dN   : false northing in meters; [default: 0.0]
%	       dE   : false easting in meters;  [default: 500,000]
%     ell - the reference ellipsoid parameters. [default: WGS-84]
%
%
% OUTPUT:
% 	 llh - geodetic coordinates [lat,lon,h] in (rad, rad, m). (nx3)
%
% REFERENCE:
% Coordinate Conversions and Transformation including Formulas,
% OGP Surveying and Positioning Guidance Note number 7, part 2 иC February 2007
% http://www.epsg.org/guides/G7-2.html, pp34-36
%
% See also LLH2XYH, GET_DATUM.

% validate number of input arguments
narginchk(1,3);
if nargin < 2; proj = []; end;
if nargin < 3, ell = geo_ellipsoid('WGS84'); end

N = xyh(:,1); E = xyh(:,2); H = xyh(:,3);

% set default projection parameters if proj is invalid
if(isempty(proj) || numel(proj) <7)
    proj = zeros(1,7);
    proj(1) = 0;            % lat0
    proj(2) = 117*pi/180; 	% lon0
    proj(3) = 1.0;         	% 1.0 for gauss-krug
    proj(4) = 0.0;        	% false northing in meters;
    proj(5) = 500000;     	% false easting in meters;
    proj(6) = 0;          	% projection geodetic height  H0
    proj(7) = 0;         	% height anomaly
end

ell.a = ell.a + proj(6);
lat0 = proj(1); lon0 = proj(2); scale= proj(3); offset =proj(4:5); anomaly =proj(7);

% constants and parameters
e  = ell.e;                  	% first eccentricity
e2 = e^2; e4 = e^4; e6 = e^6;	% first eccentricity powers
es2 = e2/(1-e2);				% second eccentricity squared

z1 = 1 -  e2/4 -  3*e4/64  -   5*e6/ 256;
z2 =    3*e2/8 +  3*e4/32  +  45*e6/1024;
z3 =             15*e4/256 +  45*e6/1024;
z4 =                          35*e6/3072;

M0 = ell.a*( z1*lat0 - z2*sin(2*lat0) + z3*sin(4*lat0) - z4*sin(6*lat0));

e1 = (1-sqrt(1-e2))/(1+sqrt(1-e2));
M1 = M0 + (N - offset(1))/scale;
mu = M1 / ( ell.a*(1 - e2/4 - 3*e4/64 - 5*e6/256) );

z1 = 3*e1/2 - 27*e1^3/32;
z2 = 21*e1^2/16 - 55*e1^4/32;
z3 = 151*e1^3/96;
z4 = 1097*e1^4/512;

lat1 = mu + z1*sin(2*mu) + z2*sin(4*mu) + z3*sin(6*mu) + z4*sin(8*mu);

T1 = (tan(lat1)).^2;
C1 = es2*(cos(lat1)).^2;

v1 = ell.a ./ sqrt( 1 - e2 * sin(lat1).^2 );
% R1 = ell.a*(1-e2) ./ ( 1 - e2 * sin(lat1).^2 ).*sqrt(( 1 - e2*(sin(phi1)).^2 ));
R1 = ell.a*(1-e2) ./ ( 1 - e2 * sin(lat1).^2 ).^(3/2);
D = (E - offset(2)) ./ (v1*scale);

za = 5 + 3*T1 + 10*C1 - 4*C1.^2 - 9*es2;
zb = 61 + 90*T1 + 298*C1 + 45*T1.^2 - 252*es2 - 3*C1.^2;
zc = 1 + 2*T1 + C1;
zd = 5 - 2*C1 + 28*T1 - 3*C1.^2 + 8*es2 + 24*T1.^2;

lat = lat1 - (v1.*tan(lat1)./R1).*(D.^2/2 - za.*D.^4/24 + zb.*D.^6/720);
lon = lon0 + (D - zc.*D.^3./6 + zd.*D.^5/120) ./ cos(lat1);
h   = H + anomaly;

llh = [lat,lon,h]; llh(:,3) = 0;
xyz = llh2xyz(llh, ell);
ell.a = ell.a - proj(6);
llh = xyz2llh(xyz, ell);
llh(:,3) = H + anomaly;

end