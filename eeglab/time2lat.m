function [lat] = time2lat(EEG,time,tri)

% [lat] = time2lat(EEG,time,tri)
%
% return latency(in EEG samples) corresponding to time time in trial tri
% in EEG

tpts = timepts(time);
lat = tpts + EEG.pnts * (tri -1);

if nargout == 0
    disp(time(:)')
    disp(tri(:)')
    disp(lat(:)')
    clear lat
end

