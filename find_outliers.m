function [i_outliers]= find_outliers(data,w)

% [i_outliers]= find_outliers(data,w)
% returns logical yes for outliers in data.
% outliers are defined as data points beyond [q(1) - w * IQR, q(2) + w * IQR]
% with 
%   [q] = quantile(data,[0.25 0.75])
%   IQR = diff(q)
% default value for w is 1.5
% 
% if data is a matrix, separate columns are processed independently.
%
% Max 2016

narginchk(1,2);
if nargin == 1
    w = 1.5;
end
if isvector(data)
    data = data(:);
end
i_outliers = false(size(data));
for i = 1:size(data,2)
    q = quantile(data(:,i),[.25 .75]);
    outlim = q + [-w w] .* diff(q);
    i_outliers(:,i) = data(:,i) < outlim(1) |data(:,i) > outlim(2);
end
