function out = movel(in,from,to)

% out = movel(in,from,to)
% move elements in an array

error(nargchk(3,3,nargin));

n = numel(in);
if from > n || to > n
    error('elements out of range')
end

if from < to
    neworder = [1:from-1 from+1:to from to+1:n];
elseif from > to
    neworder = [1:to-1 from to:from-1 from+1:n];
else
    neworder = 1:n;
end

out = reshape(in(neworder),size(in));


