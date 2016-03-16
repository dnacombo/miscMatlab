function c = forcecat(dim,varargin)

% c = forcecat(dim,varargin)
% like cat, but works even if varargin{:} do not have same sizes. Padding
% smaller arrays with NaNs.

s = ones(numel(varargin),25);
for i = 1:numel(varargin)
    s(i,1:ndims(varargin{i})) = size(varargin{i});
end
ms = max(s);
cc = {[]};
for i = 1:numel(varargin)
    ms(dim) = s(i,dim);
    if isempty(varargin{i})
        continue
    end
    cc{i} = padarray(varargin{i},ms - s(i,:),NaN,'post');
end
c = cat(dim,cc{:});