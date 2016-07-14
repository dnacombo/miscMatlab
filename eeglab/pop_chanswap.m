function [EEG,com] = pop_chanswap(EEG,chan1,chan2)

% [EEG,com] = pop_chanswap(EEG,chan1,chan2)
%
% swap chan1 with chan2.
% 

if isempty(chnb(chan1)) || isempty(chnb(chan2))
    error('channel not found')
end

d = EEG.data(chnb(chan1),:);
EEG.data(chnb(chan1),:) = EEG.data(chnb(chan2),:);
EEG.data(chnb(chan2),:) = d;
c = EEG.chanlocs(chnb(chan1));
EEG.chanlocs(chnb(chan1)) = EEG.chanlocs(chnb(chan2));
EEG.chanlocs(chnb(chan2)) = c;



