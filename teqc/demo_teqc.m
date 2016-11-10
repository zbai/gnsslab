function demo_teqc(file)

% DEMO_TEQC: Read and plot TEQC report files
% TEQC is the Toolkit for GNSS Data used to solve
% many pre-processing problems with GPS, GLONASS, and SBAS data:
% TEQC stands for Translation, Editing, and Quality Check
% More info here: http://facility.unavco.org/software/teqc/teqc.html
%
% Valid TEQC report files are:
%
% FORMAT  DESCRIPTION
% *.sn1   Signal to noise ratio (S/N) Carrier L1
% *.sn2   Signal to noise ratio (S/N) Carrier L2
% *.iod   Derivative of ionospheric delay observable (m/s)
% *.ion   Ionospheric delay observable (m)
% *.mp1   Multipath Carrier L1
% *.mp2   Multipath Carrier L2
% *.azi   Satellite azimuthal data (degrees)
% *.ele   Satellite elevation data (degrees)

% ------------------------------------------------------------------------------
% ext = {'mp1', 'mp2', 'sn1', 'sn2', 'iod', 'ion'};

if nargin == 0
    [file,path] = uigetfile('*.mp1;*.mp2;*.sn1;*.sn2;*.sn5;*.iod;*.ion',...
        'Pick your TEQC report file');
    file = fullfile(path,file);
end

[path,basename,ext] = fileparts(file);
ext = {ext,'.ele','.azi'};
% ext = {ext,'.ele'};
if ischar(ext), ext = cellstr(ext); end

n = length(ext);
files = cell(n,1);
for i = 1:n, files{i} = fullfile(path,[basename,ext{i}]); end

plot_teqc(files)

% base_dir = 'c:\work\misc\fx\read_teqc_compact\';
% addpath(base_dir)
%
% base_name = 'Ball1830';
% tic
% data = read_teqc_compact (base_dir, base_name, 'mp1');
% toc
%
% prn = unique(data.prn);
% figure
% for i=1:numel(prn)
%     idx = (data.prn == prn(i));
%     subplot(3,1,1), plot(data.epoch(idx), data.elev(idx), '-k')
%     subplot(3,1,2), plot(data.epoch(idx), data.azim(idx), '-k')
%     subplot(3,1,3), plot(data.epoch(idx), data.obs(idx),  '-k', 'LineWidth',1/2)
%     subplot(3,1,1), ylabel('Elev.')
%     subplot(3,1,2), ylabel('Azim.')
%     subplot(3,1,3), ylabel('MP1'), xlabel('Time')
%     subplot(3,1,1), title(sprintf('PRN %d', prn(i)))
%     pause
% end
%
% i = 1;
% figure
% idx = (data.prn == prn(i));
% plot(data.elev(idx), data.obs(idx),  '-k', 'LineWidth',1/2)
% ylabel('MP1 (m)')
% xlabel('Elev. (degrees)')
% title(sprintf('PRN %d', prn(i)))
% xlim([32.5 50])

end