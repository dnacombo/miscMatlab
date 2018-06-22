function [m,i] = maxabs(a,opt)
% [m,i] = maxabs(a)
% return m: the maximum of the absolute value of a;
%        i: the index of maxabs(a) in a
% 
% m = maxabs(a,'-+')
% return m a vector with two values (a negative and a positive)
% this is useful to scale images.

if ~exist('opt','var') || isempty(opt)
    opt = '';
end
[m, i] = max(abs(a(:)));
if not(isempty(strfind(opt,'+-'))) || not(isempty(strfind(opt,'-+')))
    m = [-m m];
end
