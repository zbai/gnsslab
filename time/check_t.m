function tk = check_t(tk)
% CHECK_T accounting for the beginning or end of week crossover. From the
% Interface Specification document revision E (IS-GPS-200E), page 93.
%
% SYNTAX:
%   tk = check_t(tk);
%
% INPUT:
%   tk = GNSS time
%
% OUTPUT:
%   tk = corrected GNSS time
%
% See also MJD2CAL, FIXY2K.

% validate number of input arguments
narginchk(1,1);

if tk >  302400, tk = tk - 604800; end;
if tk < -302400, tk = tk + 604800; end;

end
