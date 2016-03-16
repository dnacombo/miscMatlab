function EEG = pop_selecttime(EEG,t)

[pts, times] = timepts(t);

EEG.data = EEG.data(:,pts,:);
EEG.times = times;
EEG.xmin = times(1)/1000;
EEG.xmax = times(end)/1000;
EEG.pnts = numel(times);