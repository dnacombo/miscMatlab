function mm = maxmin(a,dim)

% mm = maxmin(a[,dim])
%
% return max and min of an array along specified dimension
% 

if not(exist('dim','var'))
    dim = find(size(a) ~= 1,1,'first');
end

mm{1} = max(a,[],dim);
mm{2} = min(a,[],dim);


mm = cat(dim,mm{:});


