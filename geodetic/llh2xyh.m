function [xyh, proj] = llh2xyh(llh, proj, ell)
% LLH2XYH converts geodetic coordinates[lat,lon] to plane coordinates [x,y]
% using Transverse Mercator projection formulas(either Universal Transverse
% Mercator (UTM) or Gauss-Kruger depending on the projection parameters).
% It also converts geodetic height to orthometric height using the geoidal
% undulation from EGM96 model if provided.
%
% SYNTAX:
%   % conversion using WGS-84 ellipsoid and default projection parameters
% 	[xyh, proj] = llh2xyh(llh);
%
%   % conversion using user defined ellipsoid
%   ell = get_ellipsoid('KRASS');
%   proj(1) = 49*pi/180;    %lat0
%   proj(2) = -2*pi/180;    %lon0
%   proj(3) = 0.999602717;  %scale
%   proj(4) = -100*1000;    %dn
%   proj(5) = 400*1000;     %de
%
%   xyh = llh2xyh(llh, proj, ell);
%
% INPUT:
%	llh  - geodetic coordinates [lat,lon,h] in (rad,rad,m). (nx3)
%	proj - projection parameters [lat0,lon0,scale,dN,dE]
%          lat0 : Latitude  of natural origin in radians. [default: 0]
%          lon0 : Longitude of natural origin in radians.
%                 [default: 6бу intervals central meridian]
%          scale: Scale at natural origin; usually 1 Gauss-Kruger and
%                 0.9996 for UTM. [default: 1.0]
%          dN   : false northing in meters; [default: 0.0]
%	       dE   : false easting in meters;  [default: 500,000]
%
%   ell  - reference ellipsoid parameters. [default: WGS-84]
%
% OUTPUT:
%	xyh - plane coordinates and orthometric height [x,y,h] after projection,
%         x, y correspond to north and east direction respectively(m). (nx3)
%
% REFERENCE:
%   Coordinate Conversions and Transformation including Formulas, OGP
%   Surveying and Positioning Guidance Note number 7, part 2 иC February
%   2007 http://www.epsg.org/guides/G7-2.html, pp34-36
%
% See also XYH2LLH, GET_ELLIPSOID.

% validate number of input arguments
narginchk(1,3);
if nargin < 2; proj = []; end;
if nargin < 3; ell  = geo_ellipsoid('WGS84'); end;

% set default projection parameters if proj is invalid
if(isempty(proj) || numel(proj) <7)
    proj = zeros(1,7);
    lon0 = mean(llh(:,2))*180/pi;   % the central meridian in degrees
    n = floor(lon0/6)+1;            % get the projection zone
    
    proj(1) = 0;                    % lat0
    proj(2) = (n*6-3)*pi/180;       % lon0
    proj(3) = 1.0;                  % 1.0 for gauss-krug
    proj(4) = 0.0;                  % false northing in meters;
    proj(5) = 500000;               % false easting in meters;
    proj(6) = 1970;                    % projection geodetic height  H0
    proj(7) = 0;                    % height anomaly
end

lat0 = proj(1); lon0 = proj(2); scale= proj(3); offset =proj(4:5); anomaly =proj(7);
H = llh(:,3) - anomaly;

%llh(:,3) = 0;
xyz = llh2xyz(llh, ell);
ell.a = ell.a + proj(6);
llh = xyz2llh(xyz, ell);
lat = llh(:,1); lon = llh(:,2);

T = tan(lat).^2;
e = ell.e;
es = sqrt(e^2/(1-e^2));	% second eccentricity

C = e^2 * cos(lat).^2 /(1-e^2);
A = (lon - lon0).*cos(lat);
v = ell.a ./ sqrt(1-e^2*sin(lat).^2);

z1 = 1 -  e^2/4 -  3*e^4/64  -   5*e^6/ 256;
z2 =    3*e^2/8 +  3*e^4/32  +  45*e^6/1024;
z3 =              15*e^4/256 +  45*e^6/1024;
z4 =                            35*e^6/3072;

M  = ell.a*( z1*lat  - z2*sin(2*lat ) + z3*sin(4*lat ) - z4*sin(6*lat ));
M0 = ell.a*( z1*lat0 - z2*sin(2*lat0) + z3*sin(4*lat0) - z4*sin(6*lat0));

N = M - M0 + v.*tan(lat) .* (A.^2/2+(5-T+9*C+4*C.^2).*A.^4/24 ...
    +(61-58*T+T.^2+600*C-330*es^2).*A.^6/720);
E = v .*(A + (1-T+C).*A.^3/6+(5-18*T+T.^2+72*C-58*es^2).*A.^5/120);

N = N*scale + offset(1);
E = E*scale + offset(2);

xyh = [N, E, H];

end