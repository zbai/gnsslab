function [rs, dts] = eph2pos(gpst, sat, nav)
% EPH2POS: compute satellite position/clock biases with ephemeris.
% calculate satllite position/velocity from navigation messages
%
% [argin]  : td    = date (mjd-gpst)
%            ts    = time (sec)
%            nav   = navigation messages
%           (type) = GPS/GLONASS('N'=GPS,'G'=GLONASS)
%           (opt)  = option (1:relativity correction off)
% [argout] : pos = satellite position [x;y;z] (m)(ecef)
%            dts = satellite clock error [bias;drift;drift-rate]
%                  bias/drift/drift-rate(sec,sec/sec,sec/sec^2)
%           (vel)= satellite velocity [vx;vy;vz] (m/sec)(ecef)
%           (svh)= sv health
% [note]   : no TGD correction

narginchk(3, 3);
rs = nan(1, 3); dts = nan(1, 1);

switch char(sat/100)
    case 'G',
        eph = find_eph(gpst, sat, nav);
        if isempty(eph), return; end
        [rs, dts] = eph2pos_gps(gpst, eph); %#ok<ASGLU>
        gpst = gpst - [0, dts];
        [rs, dts] = eph2pos_gps(gpst, eph);
    case 'C',
        bdt = gpst - [1356, 14]; %[-1356, -14]
        eph = find_eph(bdt, sat, nav);
        if isempty(eph), return; end
        [rs, dts] = eph2pos_bds(bdt, eph); %#ok<ASGLU>
        bdt = bdt - [0, dts];
        [rs, dts] = eph2pos_bds(bdt, eph);
    case 'R',
        utc = gpst2utc(gpst);
        eph = find_eph(utc, sat, nav);
        if isempty(eph), return; end
        [rs, dts] = eph2pos_glo(utc, eph);
    case 'E',
        error('Galileo is not supported yet.');
    otherwise,
        error('Invalid satellite number.');
end

end

% find ephemeris -------------------------------------------------------------
function eph = find_eph(gpst, sat, nav)
% FIND_EPH find navigation message having closest toe to the given time
eph = [];

ii = find(nav(:, 1) == sat);
if isempty(ii)
    return;
else
    nav = nav(ii,:);
end

% nav(:,29) = toe_week, nav(:,19) = toe_sow, nav(:,32) = health
dt = gpst2sec(gpst)-gpst2sec([nav(:, 29), nav(:, 19)]);

[dti, i] = min(abs(dt));

fit_interval = nav(i,36);
if (fit_interval ~= 0)
    dtmax = fit_interval*3600/2;
else
    switch char(sat/100)
        case 'R' %GLONASS
            dtmax = 950; %900 + 50 to account for leap seconds difference
        case 'J' %QZSS
            dtmax = 3600;
        otherwise
            dtmax = 7200;
    end
end

% MAXDTOE = 7200.0;	% max time-difference referenced to TOE
switch char(sat/100)
    case 'G', if dti <= dtmax && nav(i, 32) == 0, eph = nav(i,:); end
    case 'C', if dti <= dtmax && nav(i, 32) == 0, eph = nav(i,:); end
    case 'R', if dti <= dtmax && nav(i, 32) == 0, eph = nav(i,:); end
        % (QZSS and Galileo health flag is kept on for tests)
    case 'E', if dti <= dtmax, eph = nav(i,:); end
    case 'J', if dti <= dtmax, eph = nav(i,:); end
    otherwise, error('Invalid satellite number.');
end

end

function [rs, dts] = eph2pos_gps(gpst, eph)
% Compute GPS satellite position and clock-bias.ICD-GPS-200C, PP98-100, P88

rs = nan(1, 3); dts = nan(1, 1);
if isempty(eph), return; end

C = 299792458; OMGE = 7.2921151467E-5; MU = 3.986005E14;

%get ephemerides
sat = eph(1);
crs = eph(12);
deltan = eph(13);
M0 = eph(14);
cuc = eph(15);
ecc = eph(16);
cus = eph(17);
roota = eph(18);
toe = eph(19);
cic = eph(20);
OMEGA0 = eph(21);
cis = eph(22);
i0 = eph(23);
crc = eph(24);
omega = eph(25);
OMEGADOT = eph(26);
idot = eph(27);
week = eph(29);

if (char(sat/100) ~= 'G'), return; end

tk = gpst2sec(gpst-[week, toe]); %toe
tk = check_t(tk); % repairs over- and underflow of GPS time

%semi-major axis
A = roota * roota;
% computed mean motion (rad/sec)
n0 = sqrt(MU/A^3);
% corrected mean motion
n = n0 + deltan;

% mean anomaly
Mk = M0 + n * tk;
Mk = rem(Mk+2*pi, 2*pi);

% kepler's equation for eccentric anomaly (rad)
max_iter = 15;
% convergence was achieved at 4-6 iterations for GPS; but it would take 11
% iterations to converge for QZSS PRN 193
Ek = Mk;
for i = 1:max_iter
    E0 = Ek;
    Ek = Mk + ecc * sin(Ek);
    if (abs(Ek-E0) < 1.0e-12), break; end
end

% true anomaly
fk = atan2(sqrt(1-ecc^2)*sin(Ek), cos(Ek)-ecc);

% argument of latitude
phi = fk + omega;

% argument of latitude correction
du = cuc * cos(2*phi) + cus * sin(2*phi);
% radius correction
dr = crc * cos(2*phi) + crs * sin(2*phi);
% inclination correction
di = cic * cos(2*phi) + cis * sin(2*phi);

% corrected argument of latitude
uk = phi + du;
% corrected radial distance
rk = A * (1 - ecc * cos(Ek)) + dr;
% corrected inclination  of the orbital plane
ik = i0 + idot * tk + di;

% satellite position in orbital plane
x1 = cos(uk) * rk;
y1 = sin(uk) * rk;

% corrected longitude of ascending node
omegak = OMEGA0 + (OMEGADOT - OMGE) * tk - OMGE * toe;
omegak = rem(omegak+2*pi, 2*pi);

% Earth-fixed coordinates
xyz(1) = x1 * cos(omegak) - y1 * cos(ik) * sin(omegak);
xyz(2) = x1 * sin(omegak) + y1 * cos(ik) * cos(omegak);
xyz(3) = y1 * sin(ik);

% satellite clock correction & relativistic correction(up to 6.79m)
toc = date2gpst(eph(2:7));
dt = gpst2sec(gpst-toc);
dt = check_t(dt);
dts = eph(8:10) * [1; dt; dt^2] - 2.0 * sqrt(MU*A) * ecc * sin(Ek) / (C^2); %-eph(36);

rs = xyz;

end


function [rs, dts] = eph2pos_bds(bdt, eph)
% Compute BDS satellite position and clock-bias.ICD-GPS-200C, PP98-100, P88

rs = nan(1, 3); dts = nan(1, 1);
if isempty(eph), return; end

% BDS constants
C = 299792458; OMGE = 7.2921150e-5; MU = 3.986004418e14;

%get ephemerides
sat = eph(1);
crs = eph(12);
deltan = eph(13);
M0 = eph(14);
cuc = eph(15);
ecc = eph(16);
cus = eph(17);
roota = eph(18);
toe = eph(19);
cic = eph(20);
OMEGA0 = eph(21);
cis = eph(22);
i0 = eph(23);
crc = eph(24);
omega = eph(25);
OMEGADOT = eph(26);
idot = eph(27);
week = eph(29);

if (char(sat/100) ~= 'C'), return; end

tk = gpst2sec(bdt-[week, toe]); %toe
tk = check_t(tk); % repairs over- and underflow of GPS time

%semi-major axis
A = roota * roota;
% computed mean motion (rad/sec)
n0 = sqrt(MU/A^3);
% corrected mean motion
n = n0 + deltan;

% mean anomaly
Mk = M0 + n * tk;
Mk = rem(Mk+2*pi, 2*pi);

% kepler's equation for eccentric anomaly (rad)
max_iter = 15;
% convergence was achieved at 4-6 iterations for GPS; but it would take 11
% iterations to converge for QZSS PRN 193
Ek = Mk;
for i = 1:max_iter
    E0 = Ek;
    Ek = Mk + ecc * sin(Ek);
    if (abs(Ek-E0) < 1.0e-12), break; end
end

% true anomaly
fk = atan2(sqrt(1-ecc^2)*sin(Ek), cos(Ek)-ecc);

% argument of latitude
phi = fk + omega;

% argument of latitude correction
du = cuc * cos(2*phi) + cus * sin(2*phi);
% radius correction
dr = crc * cos(2*phi) + crs * sin(2*phi);
% inclination correction
di = cic * cos(2*phi) + cis * sin(2*phi);

% corrected argument of latitude
uk = phi + du;
% corrected radial distance
rk = A * (1 - ecc * cos(Ek)) + dr;
% corrected inclination  of the orbital plane
ik = i0 + idot * tk + di;

% satellite position in orbital plane
x1 = cos(uk) * rk;
y1 = sin(uk) * rk;

if (rem(sat, 100) <= 5) % if BDS GEO satellite (prn <= 5)
    %corrected longitude of the ascending node
    omegak = OMEGA0 + OMEGADOT * tk - OMGE * toe;
    
    %satellite coordinates (X,Y,Z) in inertial system
    xg = x1 * cos(omegak) - y1 * cos(ik) * sin(omegak);
    yg = x1 * sin(omegak) + y1 * cos(ik) * cos(omegak);
    zg = y1 * sin(ik);
    
    omg = OMGE * tk;
    
    xyz(1) = xg * cos(omg) + yg * sin(omg) * cosd(-5) + zg * sin(omg) * sind(-5);
    xyz(2) = - xg * sin(omg) + yg * cos(omg) * cosd(-5) + zg * cos(omg) * sind(-5);
    xyz(3) = - yg * sind(-5) + zg * cosd(-5);
else % BDS MEO/IGSO satellite
    % corrected longitude of ascending node
    omegak = OMEGA0 + (OMEGADOT - OMGE) * tk - OMGE * toe;
    omegak = rem(omegak+2*pi, 2*pi);
    
    % Earth-fixed coordinates
    xyz(1) = x1 * cos(omegak) - y1 * cos(ik) * sin(omegak);
    xyz(2) = x1 * sin(omegak) + y1 * cos(ik) * cos(omegak);
    xyz(3) = y1 * sin(ik);
end

% satellite clock correction & relativistic correction(up to 6.79m)
toc = mjd2bdt(date2mjd(eph(2:7)));
dt = gpst2sec(bdt-toc);
dt = check_t(dt);
dts = eph(8:10) * [1; dt; dt^2] - 2.0 * sqrt(MU*A) * ecc * sin(Ek) / (C^2); %-eph(36);

rs = xyz;

end


% compute satellite position and clock-bias for glonass ------------------------
function [rs, dts] = eph2pos_glo(t, eph)
STEP = 30; tk = t - eph(end);
tk = t - eph(7:8) * [-1; tk] - eph(end);
x = eph([10, 14, 18, 11, 15, 19])' * 1E3;
while abs(tk) > 1e-12
    if tk > STEP, h = STEP; elseif tk < -STEP, h = -STEP; else h = tk; end
    x = integ_glo(x, h, eph([12, 16, 20])'*1E3);
    tk = tk - h;
end
rs = x(1:3); dts = eph(7:8) * [-1; tk];
end

% integrate glonass orbit ------------------------------------------------------
function x = integ_glo(x, h, acc)
k1 = ode_glo(x, acc);
k2 = ode_glo(x+k1*h/2, acc);
k3 = ode_glo(x+k2*h/2, acc);
k4 = ode_glo(x+k3*h, acc);
x = x + (k1 + 2 * k2 + 2 * k3 + k4) * h / 6;
end

% glonass orbit differential equations -----------------------------------------
function xdot = ode_glo(x, acc)
RE = 6378136; MU = 3.9860044E14; J2 = 1.0826257E-3; OMG = 7.292115E-5;
r = norm(x(1:3)); A = 1.5 * J2 * MU * RE^2 / r^5; B = 5 * x(3)^2 / r^2;
xdot = [x(4:6); - MU / r^3 * x(1) - A * x(1) * (1 - B) + OMG^2 * x(1) + 2 * OMG * x(5) + acc(1); ...
    -MU / r^3 * x(2) - A * x(2) * (1 - B) + OMG^2 * x(2) - 2 * OMG * x(4) + acc(2); ...
    -MU / r^3 * x(3) - A * x(3) * (3 - B) + acc(3)];
end

% coordinate rotation matrix ---------------------------------------------------
function R = Rx(t), R = [1, 0, 0; 0, cos(t), sin(t); 0, - sin(t), cos(t)]; end
function R = Rz(t), R = [cos(t), sin(t), 0; - sin(t), cos(t), 0; 0, 0, 1]; end

%
% % Sat velocity
% % REFERENCE
% % GPS Solutions, Volume 8, Number 2, 2004 (in press).
% % "Computing Satellite Velocity using the Broadcast Ephemeris", by Benjamin W. Remondi
%
% mkdot  = angvel;
% ekdot  = mkdot./(1-eph.ecc.*cos(eccanomaly));
% takdot = sin(eccanomaly).*ekdot.*(1+eph.ecc.*cos(realanomaly))./(sin(realanomaly).*(1-eph.ecc.*cos(eccanomaly)));
%
% ukdot = takdot + 2.*(eph.cus.*cos(2.*clat)-eph.cuc.*sin(2.*clat)).*takdot;
% rkdot = a.*eph.ecc.*sin(eccanomaly).*angvel./(1-eph.ecc.*cos(eccanomaly))+2.*(eph.crs.*cos(2.*clat)-eph.crc.*sin(2.*clat)).*takdot;
% ikdot = eph.idot + (eph.cis.*cos(2.*clat)-eph.cic.*sin(2.*clat)).*2.*takdot;
%
% xpkdot = rkdot.*cos(clat)-yl.*ukdot;
% ypkdot = rkdot.*sin(clat)+xl.*ukdot;
%
% omegakdot = eph.omegadot-OMEGAE;
% vxyz(:,1)  = (xpkdot - yl.*cos(inc).*omegakdot).*cos(omega) ...
%     - (xl.*omegakdot + ypkdot.*cos(inc) - yl.*sin(inc).*ikdot).*sin(omega);
% vxyz(:,2)  = (xpkdot - yl.*cos(inc).*omegakdot).*sin(omega) ...
%     + (xl.*omegakdot + ypkdot.*cos(inc) - yl.*sin(inc).*ikdot).*cos(omega);
% vxyz(:,3)  = ypkdot.*sin(inc) + yl.*cos(inc).*ikdot;
