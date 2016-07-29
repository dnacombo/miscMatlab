function [EEG,com] = pop_chandiff(EEG,chan1,chan2,name,type)

% [EEG,com] = pop_chandiff(EEG,chan1,chan2,name,type)
% compute the difference chan1 - chan2 and add it to the data.
% optionally name the new channel (default = 'diff chan1-chan2'
% if chan1 and/or chan2 match several channel names, compute the mean
% before.
% type of channel is added to EEG.chanlocs if provided

if not(exist('name','var'))
    [dum,ch1] = chnb(chan1);
    [dum,ch2] = chnb(chan2);
    name = ['diff ' ch1 '-' ch2];
end
if not(exist('type','var'))
    type = [];
end
if not(isempty(chnb(name)))
    error(['channel ' name ' already exists'])
end


EEG.data(end+1,:) = mean(EEG.data(chnb(chan1),:),1) - mean(EEG.data(chnb(chan2),:),1);
EEG.chanlocs(end+1).labels = name;
EEG.chanlocs(end).type = type;

EEG.nbchan = numel(EEG.chanlocs);


com = sprintf('EEG = pop_chandiff( %s,%s);', inputname(1), vararg2str({chan1,chan2,name,type}));

