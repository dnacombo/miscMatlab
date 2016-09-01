function [EEG,com] = pop_chanswap(EEG,chan1,chan2)

% [EEG,com] = pop_chanswap(EEG,chan1,chan2)
%
% swap chan1 with chan2.
% 

if isempty(chnb(chan1)) || isempty(chnb(chan2))
    error('channel not found')
end
chan1 = chnb(chan1);
chan2 = chnb(chan2);
d = EEG.data(chnb(chan1),:);
EEG.data(chan1,:) = EEG.data(chan2,:);
EEG.data(chan2,:) = d;
c = EEG.chanlocs(chnb(chan1));
EEG.chanlocs(chan1) = EEG.chanlocs(chan2);
EEG.chanlocs(chan2) = c;

com = sprintf('EEG = pop_chanswap( %s,%s);', inputname(1), vararg2str({chan1, chan2}));


