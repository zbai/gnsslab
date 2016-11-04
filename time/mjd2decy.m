function dy = mjd2decy(mjd)
% MJD2DECY converts modified julian date(MJD) to decimal year. 
%
% SYNTAX:   
%   dy = mjd2dy(mjd);
%
% INPUT:
%	mjd - Modified Julian date.(nx1)
%
% OUTPUT:
%	dy - decimal year. (nx1)
%
% EXAMPLE:
%   dy = jd2dy(jd);
%   Compute decimal year of 1989/02/17 15:20:10, 
%	fod = hms2fod(15, 20, 10);	      % fod = 0.63900462962963
%	jd  = ymd2jd(1989, 2, 17 + fod);  % jd = 2.447575139004630e+006
%   dy = jd2dy(jd);                   % dy = 
%	
% See also DY2MJD.

% validate the number of input arguments
narginchk(1,1);
if(size(mjd,2) < 2), mjd(:,2) = 0; end

cal = mjd2cal(mjd);

yr  = cal(:,1); m = ones(size(yr)); d = ones(size(yr));

mjd0 = cal2mjd([yr,   m, d]);
mjd1 = cal2mjd([yr+1, m, d]);

dy  = yr + (mjd(:,1)-mjd0(:,1)+mjd(:,2)/86400)./(mjd1(:,1)-mjd0(:,1));

end