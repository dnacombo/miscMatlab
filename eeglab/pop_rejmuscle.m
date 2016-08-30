function [EEG,rej,com] = pop_rejmuscle(EEG,varargin)

% [EEG,rej,com] = pop_rejmuscle(EEG,cfg)
% or
% [EEG,rej,com] = pop_rejmuscle(EEG,param,value...)
% 
% Wrapper for muscle artifact detection of fieldtrip (ft_artifact_muscle).
% Use configuration in cfg structure.
%
% This structure has the form defined in fieldtrip ft_artifact_muscle
%
% if param, value pairs are provided, they should be of the form:
%       'field_subfield_subsubfield', val, ...
%
% ex:
%   EEG = pop_rejmuscle( EEG,'trl',[],'artfctdef_muscle_channel',[1:63] ,...
%       'artfctdef_muscle_trlpadding',0,'artfctdef_muscle_fltpadding',0 );
%
%
if numel(varargin) ==1
    cfg = varargin{1};
elseif numel(varargin) > 1
    cfg = vararg2struct(varargin);
end


if not(exist('cfg','var'))
    cfg = [];
end

def = [];
def.trl = [];
def.artfctdef.muscle = [];
def.artfctdef.muscle.channel = 'all';
def.artfctdef.muscle.trlpadding = 0;
def.artfctdef.muscle.fltpadding = 0;

cfg = setdef(cfg,def);

data = eeglab2fieldtrip(EEG,'preprocessing');

ft_defaults;

[cfg] = ft_artifact_muscle(cfg, data);

[t,tri] = lat2time(EEG,cfg.artfctdef.muscle.artifact);
rej = [];
for i = 1:size(tri,1)
    rej = [rej tri(i,1):tri(i,2)];
end
rej = unique(rej);

if ~isfield(EEG,'rejmuscle') || isempty(EEG.reject.rejmuscle)
    EEG.reject.rejmuscle = false(1,EEG.trials);
    EEG.reject.rejmuscleE = false(EEG.nbchan,EEG.trials);
end
EEG.reject.rejmuscle(rej) = true;

EEG.reject.rejmusclecol = [0.80392     0.43922     0.32941];


com = sprintf('EEG = pop_rejmuscle( %s,%s );', inputname(1),vararg2str(struct2vararg(cfg)));







