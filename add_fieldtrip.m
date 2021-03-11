function add_fieldtrip

% add_fieldtrip
% 

% in case I used eeglab recently, avoid conflicts
rm_frompath('eeglab.*Fieldtrip')

% my fieldtrip is stored under my userpath
addpath(fullfile(userpath, 'fieldtrip'));

% for cleaner output
global ft_default
ft_default.showcallinfo = 'no';

ft_defaults
ft_version
