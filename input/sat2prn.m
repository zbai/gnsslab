function prn = sat2prn(sat)
% SAT2PRN converts satellite number to prn string.
%
% SYNTAX:
%	prn = sat2prn(sat);
%
% INPUT:
%	sat - satellite number.(nx1)
%
% OUTPUT:
%   prn - satellite prn(ie. 'G01', 'C06'). (nx1)
%
% See also PRN2SAT.

if isempty(sat), prn = []; return; end

% sat shoule be numbers
if ~isnumeric(sat), error('sat must be numeric.'); end

num = mod(sat,100);
sys = char((sat -num)/100);
prn = [sys, num2str(num,'%02d')];

end