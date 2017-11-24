% ionospheric model ------------------------------------------------------------
function freq = gnss_frequence(sat)

freq = nan(1,3);

if ischar(sat)
    sys = sat(1);
else
    sys = char(sat/100);
end

if sys == 'G', freq = [1575.420E6, 1227.600E6, 1176.450E6]; end
if sys == 'C', freq = [1561.098E6, 1207.140E6, 1268.520E6]; end

end