function s = sem(data,dim)

% s = sem(data,dim)
%
% compute standard error of the mean of data along dimension dim
% 
% s = mean(data,dim)./sqrt(std(data,[],dim));

s = mean(data,dim)./sqrt(std(data,[],dim));