function [tpts tvals] = timepts(timein, varargin)

% timepts() - return time points corresponding to a certain latency range
%             in an EEG structure.
%
% Usage:
%   >> [tpts] = timepts(timein);
%   >> [tpts tvals] = timepts(timein, times);
%               Note: this last method also works with any type of numeric
%               data entered under times (ex. frequencies, trials...)
%
% Input:
%   timein        - latency range [start stop] (boundaries included). If
%                   second argument 'times' is not provided, EEG.times will
%                   be evaluated from the EEG structure found in the caller
%                   workspace (or base if not in caller).
%   times         - time vector as found in EEG.times
%
% Output:
%   tpts          - index numbers corresponding to the time range.
%   tvals         - values of EEG.times at points tpts
%

error(nargchk(1,2,nargin));
if nargin == 2
    if isstruct(varargin{1}) && isfield(varargin{1},'setname')
        % assume it's an EEG dataset
        times = varargin{1}.times;
    else
        times = varargin{1};
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
    if not(isfield(EEG,'times'))
        error('No time list found');
    end
    times = EEG.times;
end
if isempty(times)
    error('could not find times');
end
if numel(timein) == 1
    [dum tpts] = min(abs(times - timein));% find the closest one
elseif numel(timein) == 2
    tpts = find(times >= timein(1) & times <= timein(2));% find times within bounds
else
    for i = 1:numel(timein)
        [dum tpts(i)] = min(abs(times - timein(i)));
    end
end
if isempty(tpts)
    warning('Empty times?!?');
end
tvals = times(tpts);
