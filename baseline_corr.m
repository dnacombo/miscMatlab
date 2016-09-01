function [d] = baseline_corr(d,dim,bl,type)

% [d] = baseline_corr(d,dim,bl,type)
% baseline correct data d, with values extracted from d at indices bl along
% dimension dim.
% type is either 'sub', 'div' or 'divlog' (default 'sub')
% all arguments but d are optional.

if not(exist('dim','var'))||isempty(dim)
    dim = 1;
end
if not(exist('bl','var'))||isempty(bl)
    bl = 1:size(d,dim);
end
if not(exist('type','var'))||isempty(type)
    type = 'sub';
end

dims = 1:ndims(d);
% place dim first
d = permute(d,[dim setdiff(dims,dim)]);

bl = eval(['nanmean(d(bl' repmat(',:',1,ndims(d)-1) '),1);']);

switch type
    case 'sub'
        d = d - repmat(bl,[size(d,1),ones(1,ndims(d)-1)]);
    case 'div'
        d = d ./ repmat(bl,[size(d,1),ones(1,ndims(d)-1)]);
    case {'divlog' 'logdiv'}
        d = log10(d ./ repmat(bl,[size(d,1),ones(1,ndims(d)-1)]));
end

% put dim back in place
d = ipermute(d,[dim setdiff(dims,dim)]);
