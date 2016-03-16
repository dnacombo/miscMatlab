function [RTs_out, varargout] = eject_outliers(RTs_in,RT_min,nsigma, dim)

% RTs_out = eject_outliers(RTs_in,RT_min,nsigma,dim)
% Cleans up RTs_in (double) by removing outliers. Replacing by NaN.
% Removes RTs under RT_min (default = .3)
% and RTs otuside +/- nsigma (default = 2) std around the mean.
% If RTs_in is a multidimensional array, operate along dim (default = 1).
% 
% [RTs_out, idx] = eject_outliers(RTs_in,RT_min,nsigma)
% returns idx (double) of removed RTs in RTs_in.

if nargin < 2 || isempty(RT_min)
    RT_min = .3;
end
if nargin < 3 || isempty(nsigma)
    nsigma = 2;
end
if nargin < 4 || isempty(dim)
    dim = 1;
end

RTs_work = RTs_in(:);
RTsize = size(RTs_work);

found1 = RTs_work < RT_min;% find les RTs trop courts
avg = nanmean(RTs_work,dim);
avg = repmat(avg, [ones(1,numel(RTsize(1:dim-1))) RTsize(dim) ones(1,numel(RTsize(dim+1:end)))]);
stdev = nanstd(RTs_work,[],dim);
stdev = repmat(stdev, [ones(1,numel(RTsize(1:dim-1))) RTsize(dim) ones(1,numel(RTsize(dim+1:end)))]);
found2 = RTs_work > avg + nsigma*stdev | RTs_work < avg - nsigma*stdev;% find >< avg +- nsigma ecartypes

RTs_work(found1(:)| found2(:)) = NaN; % efface les 2

RTs_out = RTs_work;

if nargout > 1
    varargout{1} = [found1(:)|found2(:)];
end
