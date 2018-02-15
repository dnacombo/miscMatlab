function mm = minmax(a,dim)

% mm = minmax(a[,dim])
%
% return min and max of an array along specified dimension
% 

if not(exist('dim','var'))
    dim = find(size(a) ~= 1,1,'first');
end

mm{1} = min(a,[],dim);
mm{2} = max(a,[],dim);


mm = cat(dim,mm{:});


