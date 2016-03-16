function [elec tpt elecname time] = eeg_find(EEG,what,when,dat)

% [elec tpt elecname time] = eeg_find(EEG,what,when,data)
% find minimum or maximum (as stated in what) of EEG in the time period
% defined by when. If data is provided, perform what on that data, using
% times of EEG.

if not(exist('when','var'))
    when = [-Inf Inf];
end
if not(exist('dat','var'))
    dat = EEG.data;
elseif ndims(dat) ~=ndims(EEG.data) || ~all(size(dat) == size(EEG.data))
    error(['Data manually entered should have same size as EEG.data'])
end
EEG.data = dat;
times = EEG.xmin:1/EEG.srate:EEG.xmax;
% select time of interest (when)
[tpts] = timepts(when,times);
times = times(tpts);
EEG.data = EEG.data(:,tpts);

switch what
    case 'max'
        i = find(EEG.data == max(EEG.data(:)));
    case 'min'
        i = find(EEG.data == min(EEG.data(:)));
    otherwise
        error([what ' not supported'])
end

[elec tpt] = ind2sub(size(EEG.data),i);
[elec elecname] = chnb(elec);

time = times(tpt);
% we want to return tpt in the original time (not just the selection)
times = EEG.xmin:1/EEG.srate:EEG.xmax;
tpt = timepts([time time],times);

