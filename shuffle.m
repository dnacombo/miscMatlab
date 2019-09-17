function [Y,index] = Shuffle(X,dim,index)
% [Y,index] = Shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
%	for j=1:n, Y(:,j)=X(index(:,j),j).
% 
% [Y,index] = Shuffle(X,dim)
% 
% if provided, dim indicates the dimension along which to
% shuffle. [default dim = longest dimension of X for vectors, dim = 1 for
% matrices] 
% if numel(dim) > 1 perform several Shuffles reccursively. Index follows
% recursions (i.e. can be used to reshuffle with same order).
%
% [Y,index] = Shuffle(X,dim,index)
% 
% if index is provided, sorting according to it. This allows shuffling
% several matrices with the same random order.
%
% Also see SORT, Sample, Randi, and RandSample.

% xx/xx/92  dhb  Wrote it.
% 10/25/93  dhb  Return index.
% 5/25/96   dgp  Made consistent with sort and "for i=Shuffle(1:10)"
% 6/29/96	dgp  Edited comments above.
% 5/18/02   dhb  Modified code to do what comments say, for matrices.
% 6/2/02    dhb  Fixed bug introduced 5/18.
% 2/8/14    mc   Generalize to any dimensional matrix, add target dim
%                input, and index input

if isempty(X)
    Y = X;
    return
end
s = size(X);% original size

if not(exist('dim','var')) || isempty(dim)
    if isvector(X)
        [dum dim] = max(s);
    elseif ismatrix(X)
        dim = 1;
    end
elseif numel(dim) > 1 % recursion to randomize several dimensions in turn
    if exist('index','var')
        if iscell(index) && numel(index) == numel(dim)
            for i = 1:numel(dim)
                [X idx{i}] = Shuffle(X,dim(i),index{i});
            end
        else
            error(['index should be a cell of ' num2str(numel(dim)) ' elements'])
        end
    else
        for i = 1:numel(dim)
            [X idx{i}] = Shuffle(X,dim(i));
        end
    end
    Y = X;
    index = idx;
    return
end

% algorithm: put dimension to sort in first position and merge all other
% dimensions (reshape). Sort according to index (either random or input).
% Reshape and permute back into original size.

d = [dim setxor(dim,1:numel(s))];% dimension order for permute (with dim first)
nus = s(d);% new size (all but first dimension are merged with reshape)
X =  reshape(permute(X,d),s(dim),[]);
if not(exist('index','var')) || isempty(index)
    [null,index] = sort(rand(size(X,1),1),1);
    index = repmat(index,[1 prod(nus(2:end))]);
else
    index = reshape(permute(index,d),s(dim),[]);
end
for j = 1:size(X,2)
	Y(:,j)  = X(index(:,j),j);
end
index = ipermute(reshape(index,nus),d);
Y = ipermute(reshape(Y,nus),d);
