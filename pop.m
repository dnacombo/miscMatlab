function [val, var] = pop(var,i,varargin)

% [val var] = pop(var)
% returns the value in var(1) and deletes it from var
%
% [val var] = pop(var,i)
% returns the value in var(i) and deletes it from var
%
% [val var] = pop(var,i,'rows')
% returns the value in var(i,:) and deletes it from var
%
if not(exist('i','var'))
    i = 1;
end
if isempty(i)
    val = [];
    return
end
if numel(varargin) > 0 && strcmp(varargin{1},'rows')
    val = var(i,:);
    var(i,:) = [];
else
    val = var(i);
    var(i) = [];
end
