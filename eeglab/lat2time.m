function [time, tri] = lat2time(EEG,lat)

% [time, tri] = lat2time(EEG,lat)

% return time (in EEG.times unit) and trial corresponding to lat (in EEG
% samples)


[time, tri] = ind2sub([EEG.pnts, EEG.trials],lat);

time = EEG.times(time);

if nargout == 0
    disp(time(:)')
    disp(tri(:)')
    clear time tri
end