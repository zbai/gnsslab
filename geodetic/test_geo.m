clear; clc; format long g;

stn = [
    1,   -2379425.3281,    4581623.3684,    3733119.9336
    2,   -2379249.8382,    4581555.0506,    3733304.0679
    3,   -2387352.1925,    4583995.4981,    3725098.9028
    4,   -2387402.8316,    4584205.3278,    3724809.7366
    5,   -2406738.3505,    4583775.0142,    3713070.8318
    6,   -2396685.6496,    4584793.0541,    3718189.5393
    7,   -2396992.3944,    4584547.7373,    3718302.7552
    8,   -2406639.5469,    4584226.0517,    3712593.9546];

xyz = stn(:,2:4);
llh = xyz2llh(xyz);

dms1 = rad2dms(llh(:,1)); dms2 = rad2dms(llh(:,2));
fprintf('\nGeodetic coordinates (site,lat,lon,h)\n');
for i=1:size(stn,1)
    fprintf('%4d %3d %2d %9.5f  %3d %2d %9.5f %9.4f\n', ...
        stn(i,1),dms1(i,1)*dms1(i,2), dms1(i,3:4), ...
        dms2(i,1)*dms2(i,2), dms2(i,3:4), llh(i,3));
end

[xyh,proj] = llh2xyh(llh);
fprintf('\nPlane coordinates by Gauss-Kruger projection (site,x,y,h)\n');
for i=1:size(stn,1)
    fprintf('%4d %14.4f %14.4f %14.4f\n', stn(i,1),xyh(i,:));
end

xyz = llh2xyz(xyh2llh(xyh,proj));
fprintf('\nCartesian coordinates (site,x,y,z)\n');
for i=1:size(stn,1)
    fprintf('%4d %14.4f %14.4f %14.4f\n', stn(i,1),xyz(i,:));
end

%-------------------------------------------------

rcvs = {'B007','B008', 'B009', 'B010'};
% ddbase coord.
xyz = [
    -1352922.2635, 5602534.1890, 2727217.2203
    -1351392.725273,  5603234.678167, 2726561.663309
    -1350455.429086,  5603634.076363, 2726184.601433
    -1350455.429086,  5603634.076363, 2726184.601433];
for i=1:4
    fprintf('XYZ %5s %11.4f %11.4f %11.4f\n',rcvs{i}, xyz(i,1:3));
end

llh = xyz2llh(xyz);
dms1 = rad2dms(llh(:,1)); dms2 = rad2dms(llh(:,2));
fprintf('\nGeodetic coordinates (site,lat,lon,h)\n');
for i=1:size(xyz,1)
    fprintf('%4d %3d %2d %9.5f  %3d %2d %9.5f %9.4f\n', ...
        i,dms1(i,1)*dms1(i,2), dms1(i,3:4), ...
        dms2(i,1)*dms2(i,2), dms2(i,3:4), llh(i,3));
end

proj(1) = 0;                    % lat0
proj(2) = (103+45/60)*pi/180;   % lon0
proj(3) = 1.0;                  % 1.0 for gauss-krug
proj(4) = 0.0;                  % false northing in meters;
proj(5) = 500000;               % false easting in meters;
proj(6) = 1970;              	% projection geodetic height  H0
proj(7) = -30;               	% height anomaly

llh = xyz2llh(xyz);
xyh = llh2xyh(llh,proj);
for i=1:4
    fprintf('XYH: %5s %11.4f %11.4f %11.4f\n',rcvs{i}, xyh(i,1:3));
end

llh = xyh2llh(xyh, proj);
xyz = llh2xyz(llh);
for i=1:4
    fprintf('XYZ %5s %11.4f %11.4f %11.4f\n',rcvs{i}, xyz(i,1:3));
end
