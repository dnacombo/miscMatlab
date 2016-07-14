function eeg_multiplotTFR(TF,cfg,what2plot)
% eeg_multiplotTFR(TF,cfg,what2plot)
% 
% create multiplotTFR using fieldtrip routine.
%
% inputs:
%       TF:     a TF structure with fields: chanlocs, freqs, times, amps
%               (or see what2plot), and a mask (name provided in
%               cfg.maskparameter)
%               Note: input dimord: freq, time, chan
%       cfg:    fieldtrip config structure with optional field
%               maskparameter = name of the field in which to look for a
%               mask in TF
%       what2plot: in what field of TF should we look for data to plot
%               (default 'amps')

if not(exist('cfg','var'))
    cfg = [];
end
if not(exist('what2plot','var'))
    what2plot = 'amps';
end
% if ischar(EEG.data)
%     EEG.data = NaN(EEG.nbchan,EEG.pnts,EEG.trials);% just filling up the matrix to avoid crash
% end
EEG = eeg_emptyset;
EEG.times = TF.times;
EEG.pnts = numel(TF.times);
EEG.chanlocs = TF.chanlocs;
EEG.nbchan = numel(EEG.chanlocs);
EEG.icachansind = 1:numel(EEG.chanlocs);
EEG.trials = 1;
EEG.data = NaN(EEG.nbchan,EEG.pnts,EEG.trials,'single');
data = eeglab2fieldtrip(EEG,'preprocessing','none');

% note TF input is freq time chan
dimord = 'chan_freq_time';
reorder = [3 1 2];

freq = struct('label',{data.label},'dimord',dimord,'freq',TF.freqs,...
    'time',{TF.times},'powspctrm',permute(TF.(what2plot),reorder),...
    'elec',data.elec);

if isfield(cfg,'maskparameter')
    freq.(cfg.maskparameter) = logical(permute(TF.(cfg.maskparameter),reorder));
end

if not(isfield(cfg,'layout'))
    cfg.layout = 'biosemi64.lay';
end
% cfg.masknans = 'yes';
% p = path;
% try
%     rm_frompath('eeglab')
%     rm_frompath('spm')
%     addpath(cdhome('fieldtrip'))
    ft_defaults
    ft_multiplotTFR(cfg,freq);
% catch ME
%     path(p)
%     rethrow(ME);
% end
% path(p)
