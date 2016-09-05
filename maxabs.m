function m = maxabs(a,opt)
% m = maxabs(a)
% return the maximum of the absolute value of a;
% m = maxabs(a,'+-')
% return two values (a negative and a positive)
% this is useful to scale images.

if ~exist('opt','var') || isempty(opt)
    opt = '';
end
m = max(abs(a(:)));
if not(isempty(strfind(opt,'+-'))) || not(isempty(strfind(opt,'-+')))
    m = [-m m];
end
