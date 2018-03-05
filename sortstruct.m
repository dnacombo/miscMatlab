function S = sortstruct(S, by, direction,sorter)

% S = sortstruct(S, by, direction,sorter)
% sort vector structure by values in field(s) by (may be cell array of
% str).
% direction is 'ascend' or 'descend'
% sorter is a list of unique values that will determine output order.
%
% if by is empty, no sorting occurs.

if isscalar(S) || isempty(S)
    return
elseif ~isvector(S)
    error('input structure must be a vector')
end
s = size(S);
S = S(:);
if nargin < 2
    by = fieldnames(S);
    warning('sortstruct:sortallfields','no sorting fields provided. sorting by all of them...')
end
defifnotexist('direction','ascend');
if ischar(by)
    defifnotexist('sorter',[]);
    by = {by};
    sorter = {sorter};
else
    defifnotexist('sorter',repmat({[]},1,numel(by)));
end
if all(cellfun(@isempty,by))
    return
end
if ischar(S(1).(by{1}))
    L = {S.(by{1})};% list all values
    U = unique(L);% unique values (sorted)
    U = [sorter{1} setxor(sorter{1},U)];
    nS = [];
    for i_u = 1:numel(U)% for each unique value
        tmpS = S(strcmp(L,U{i_u}));% extract them
        if numel(by) > 1
            tmpS = sortstruct(tmpS,by(2:end),direction,sorter(2:end));% sort under
        end
        nS = [nS; tmpS];
    end
elseif isnumeric(S(1).(by{1}))
    L = [S.(by{1})];% list all values
    U = unique(L);% unique values (sorted)
    U = [sorter{1} setxor(sorter{1},U)];
    nS = [];
    for i_u = 1:numel(U)% for each unique value
        tmpS = S(L == U(i_u));% extract them
        if numel(by) > 1
            tmpS = sortstruct(tmpS,by(2:end),direction,sorter(2:end));% sort under
        end
        nS = [nS; tmpS];
    end
else
    error todo
end
S = nS;
S = reshape(S,s);

