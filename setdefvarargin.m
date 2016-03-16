function setdefvarargin(in,varargin)

% assign default 'param' value pairs in the calling workspace
% in should be a varargin cell array.
% input param value pairs are assigned to variables in the calling
% workspace. default values passed in pairs as varargin are assigned if not
% provided as input.

innames = in(1:2:end);
for i = 1:2:numel(varargin)
    idx = regexpcell(innames,varargin{i});
    if not(isempty(idx))
        assignin('caller',varargin{i}, in{2*idx});
    else
        assignin('caller',varargin{i}, varargin{i+1});
    end
end


