function cfg = vararg2cfg(vararg, def,keepempty)

% cfg = vararg2cfg(vararg, def)
% cfg = vararg2cfg(vararg, def,keepempty)
% convert cellarray vararg to a cfg structure, setting fields of cfg with
% default values defined in structure def. 
% vararg should either be a 1x1 cell with a cfg structure or a cell array
% of N elements with N/2 pairs of 'param',value pairs.
% if keepempty is provided and true, then empty fields in s will be left
% empty. otherwise they are populated with default values. default is
% false.

if not(exist('keepempty','var'))
    keepempty = 0;
end


if numel(vararg) == 1
    cfg = setdef(vararg{1},def,keepempty);
elseif ~rem(numel(vararg),2)
    cfg = setdef(vararg2struct(vararg),def,keepempty);
else
    error('arguments in vararg should come in pairs')
end



