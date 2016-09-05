function [EEG,com] = pop_chanswap(EEG,chan1,chan2,notnames)

% [EEG,com] = pop_chanswap(EEG,chan1,chan2,notnames)
%
% swap chan1 with chan2.
% if notnames is true, then don't swap names, just data.
%
if ~exist('notnames','var')
    notnames = 0;
end
if isempty(chnb(chan1)) || isempty(chnb(chan2))
    error('channel not found')
end
chan1 = chnb(chan1);
chan2 = chnb(chan2);
d = EEG.data(chnb(chan1),:);
EEG.data(chan1,:) = EEG.data(chan2,:);
EEG.data(chan2,:) = d;
if ~notnames
    c = EEG.chanlocs(chnb(chan1));
    EEG.chanlocs(chan1) = EEG.chanlocs(chan2);
    EEG.chanlocs(chan2) = c;
end

com = sprintf('EEG = pop_chanswap( %s,%s);', inputname(1), vararg2str({chan1, chan2}));


