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
event = ft_readmarkerfile(cfgmrk);

% exclude events named cfg.excludename

toexclude = event(strcmp({event.type},cfg.excludename));
if isempty(toexclude)
    warning(['No ' cfg.excludename ' marker found.'])
end
cfgbad = [];
cfgbad.trl = [];
cfgbad.trl(:,1) = [1 [event.sample] + [event.duration]+1]';
cfgbad.trl(:,2) = [[event.sample]-1 cfg.hdr.nSamples]';
cfgbad.trl(:,3) = 0;
cfgbad.trl(cfgbad.trl(:,1)>=numel(data.time{1}),:) = [];

data = ft_redefinetrial(cfgbad,data);




