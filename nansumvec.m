function s = nansumvec(x)
% s = nansumvec(x)
% same as s = sum(x(:)), ignoring NaN
%
% Max 2016

x = x(~isnan(x(:)));
s = sum(x);