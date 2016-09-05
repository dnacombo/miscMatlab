function [nb,channame,strnames] = chty(chantype, varargin)

% chnb() - return channel number corresponding to channel names in an EEG
%           structure
%
% Usage:
%   >> [nb]                 = chnb(channameornb);
%   >> [nb]                 = chnb(channameornb, type);
%   >> [nb,names,strnames]  = chnb(channameornb, EEG);
%   >> [nb,names,strnames]  = chnb(channameornb, type, label);
%
% Input:
%   channameornb  - If a string or cell array of strings, it is assumed to
%                   be (part of) the name of channels to search. Either a
%                   string with space separated channel names, or a cell
%                   array of strings. 
%                   Note that regular expressions can be used to match
%                   several channels. See regexp.
%                   If only one channame pattern is given and the string
%                   'inv' is attached to it, the channels NOT matching the
%                   pattern are returned.
%   types         - Channel types as found in {EEG.chanlocs.type}.
%   label         - Channel labels as found in {EEG.chanlocs.label}.
%
% Output:
%   nb            - Channel numbers in type, or in the EEG structure
%                   found in the caller workspace (i.e. where the function
%                   is called from) or in the base workspace, if no EEG
%                   structure exists in the caller workspace.
%   names         - Channel names, cell array of strings.
%   strnames      - Channel names, one line character array.

error(nargchk(1,3,nargin));
if nargin >= 2
    if isstruct(varargin{1}) && isfield(varargin{1},'setname')
        % assume it's an EEG dataset
        types = {varargin{1}.chanlocs.type};
        labels = {varargin{1}.chanlocs.labels};
    else
        types = varargin{1};
        if nargin == 3
            labels = varargin{2};
        end
    end
else
    
    try
        EEG = evalin('caller','EEG');
    catch
        try
            EEG = evalin('base','EEG');
        catch
            error('Could not find EEG structure');
        end
    end
    if not(isfield(EEG,'chanlocs'))
        error('No channel list found');
    end
    EEG = EEG(1);
    types = {EEG.chanlocs.type};
end

[nb] = chnb(chantype, types);
if exist('labels','var')
    channame = labels(nb);
    strnames = sprintf('%s ',channame{:});
else
    channame = {};
    strnames = '';
end
