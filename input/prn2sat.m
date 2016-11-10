function sat = prn2sat(prn)
% PRN2SAT convert satellite prn(string) to sat(number) used in GNSSLAB.
%
% SYNTAX:
%   sat = prn2sat(prn);
%
% INPUT:
%   prn - satellite prn(ie. 'G01', 'C06').(nx1)
%
% OUTPUT:
%   sat - satellite number. (nx1)
%
% See also SAT2PRN.

if isempty(prn), sat = []; return; end

% prn shoule be strings
if(iscell(prn)), prn = char(prn{:}); end
if ~ischar(prn), error('prn must be strings'); end

% prn=[prn repmat(' ', size(prn,1), 3)];
% prn = prn(:,1:3);
% prn = strjust(upper(prn), 'right');

ii = (prn(:,1)==' '); prn(ii,1) = 'G';
ii = (prn(:,2)==' '); prn(ii,2) = '0';

sat = abs(prn(:,1))*100 + str2double(cellstr(prn(:,2:3)));

end

