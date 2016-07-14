function [EEG,com] = pop_addchan(EEG,dat,name,type)

% [EEG,com] = pop_addchan(EEG,dat,name,type)
%
% Insert data dat in EEG as last channel
% optionally name the new channel (default = 'nuchan')
% type of channel is added to EEG.chanlocs if provided
%
narginchk(2,5);

s = size(EEG.data);
ss = size(dat);
if not(isnumeric(dat)) || ~all(s(2:end) == ss(2:end))
    error('data size does not match')
end
if ss(1) ~= 1
    error('add one channel at a time')
end
if not(exist('name','var'))
    name = 'nuchan';
end
if not(exist('type','var'))
    type = [];
end
if not(isempty(chnb(name)))
    error(['channel ' name ' already exists'])
end

EEG.data(end+1,:) = dat(:);
EEG.chanlocs(end+1).labels = name;
EEG.chanlocs(end).type = type;
EEG.nbchan = EEG.nbchan+1;

com = sprintf('EEG = pop_addchan( %s,%s);', inputname(1), vararg2str({['[data ' num2str(size(dat),'%d ') ']'],name,type}));
