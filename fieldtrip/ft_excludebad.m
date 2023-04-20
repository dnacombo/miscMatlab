function [data] = ft_excludebad(cfg,data)

% [data] = ft_excludebad(cfg,data)
%
% redefine trials in data so as to exclude segments of data
% 
% inputs: cfg structure with fields:
%               markerfile: the marker file to find bad segments in
%       and/or  dataset: the dataset to process (for hdr information)
%               excludename: name of marker of segments to exclude

% set defaults
def = [];
def.markerfile = '';
def.dataset = '';
def.excludename = 'BAD';
def.hdr = [];
cfg = setdef(cfg,def);

if isempty(cfg.markerfile) && isempty(cfg.dataset)
    error('cfg.dataset or cfg.markerfile should be provided')
elseif isempty(cfg.markerfile)
    cfg.markerfile = strrep(cfg.dataset,'.fif','.mrk');
elseif isempty(cfg.dataset) && isempty(cfg.hdr)
    cfg.dataset = strrep(cfg.markerfile,'.mrk','.fif');
end

if isempty(cfg.hdr)
    cfg.hdr = ft_read_header(cfg.dataset);
end

% read marker file
cfgmrk = [];
cfgmrk.markerfile = cfg.markerfile;
cfgmrk.hdr = cfg.hdr;
disp(['Excluding segments marked with marker ' cfg.excludename ])
switch myfileparts(cfg.markerfile,'e')
    case '.mrk'
        event = ft_readmarkerfile(cfgmrk);
    case '.txt'
        event = ft_readcsvmarkerfile(cfgmrk);
end

% exclude events named cfg.excludename

toexclude = event(strcmp({event.type},cfg.excludename));
if isempty(toexclude)
    warning(['No ' cfg.excludename ' marker found.'])
end
% now crop events at the beginning or end of the recording
todel = [];
for i = 1:numel(event)
    % set negative samples to 0
    if event(i).offset < 0
        if event(i).duration < -event(i).offset
            % plan to remove if both beginning and end are before data
            todel(end+1) = i;
            continue
        end
        event(i).duration = event(i).duration + event(i).offset + 1;
        event(i).offset = 0;
        event(i).sample = 1;
    end
    if event(i).sample + event(i).duration -1 > cfgmrk.hdr.nSamples
        if event(i).sample > cfgmrk.hdr.nSamples
            todel(end+1) = i;
        end
        event(i).duration = cfgmrk.hdr.nSamples - event(i).sample;
    end
end
event(todel) = [];

cfgbad = [];
cfgbad.trl = [];
cfgbad.trl(:,1) = [1 [event.sample] + [event.duration]+1]';
cfgbad.trl(:,2) = [[event.sample]-1 cfg.hdr.nSamples]';
cfgbad.trl(:,3) = 0;
% remove exclude after end of data
cfgbad.trl(cfgbad.trl(:,1)>=numel(data.time{1}),:) = [];
% remove exclude before beginning of data
cfgbad.trl(cfgbad.trl(:,2)<=1,:) = [];

data = ft_redefinetrial(cfgbad,data);




