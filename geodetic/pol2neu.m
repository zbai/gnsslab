function neu = pol2neu(pol)
% POL2NEU converts topcentric polar coordinates [az,el,radius] to topcentric
% cartesian coordinates [n,e,u](left-hand). This function is similar to
% llr2xyz but ECEF cartesian coordinates [x,y,z] is a right-hand system.
%
% SYNTAX:
%	neu = pol2neu(pol);
%
% INPUT:
%	pol - topcentric polar coordinates [azimuth;elevation;radius]. (nx3)
%         azimuth, elevation in radians and radius in meters.
%
% OUTPUT:
%	neu - topcentric cartesian coordinates [n,e,u] in meters. (nx3)
%
% See also NEU2POL.

% validate number of input arguments
narginchk(1,1);

az = pol(:,1); el = pol(:,2); r = pol(:,3);

n = r.*cos(el).*cos(az);
e = r.*cos(el).*sin(az);
u = r.*sin(el);

neu = [n, e, u];

end

