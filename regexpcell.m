function idx = regexpcell(c,pat, cmds)

% idx = regexpcell(c,pat, cmds)
%
% Return indices idx of cells in c that match pattern(s) pat (regular expression).
% Pattern pat can be char or cellstr. In the later case regexpcell returns
% indexes of cells that match any pattern in pat.
%
% cmds is a string that can contain one or several of these commands:
% 'inv' return indexes that do not match the pattern.
% 'ignorecase' will use regexpi instead of regexp
% 'exact' performs an exact match (regular expression should match the whole strings in c).
% 'all' (default) returns all indices, including repeats (if several pat match a single cell in c).
% 'unique' will return unique sorted indices.
% 'intersect' will return only indices in c that match ALL the patterns in pat.
% 'logical' will return a logical array instead of the indices.
% 'once' will return only the first index in each c.
% 
% v1 Maximilien Chaumon 01/05/09
% v1.1 Maximilien Chaumon 24/05/09 - added ignorecase
% v2 Maximilien Chaumon 02/03/2010 changed input method.
%       inv,ignorecase,exact,combine are replaced by cmds

narginchk(2,3)
if not(iscellstr(c))
    error('input c must be a cell array of strings');
end
if nargin == 2
    cmds = '';
end
if not(isempty(regexpi(cmds,'inv', 'once' )))
    inv = true;
else
    inv = false;
end
if not(isempty(regexpi(cmds,'ignorecase', 'once' )))
    ignorecase = true;
else
    ignorecase = false;
end
if not(isempty(regexpi(cmds,'exact', 'once' )))
    exact = true;
else
    exact = false;
end
if not(isempty(regexpi(cmds,'logical', 'once' )))
    lo = true;
else
    lo = false;
end
if not(isempty(regexpi(cmds,'once', 'once' )))
    once = true;
else
    once = false;
end
if not(isempty(regexpi(cmds,'unique', 'once' )))
    combine = 2;
elseif not(isempty(regexpi(cmds,'intersect', 'once' )))
    combine = 3;
else
    combine = 1;
end

if ischar(pat)
    pat = {pat};
end

if exact
    for i_pat = 1:numel(pat)
        pat{i_pat} = ['^' pat{i_pat} '$'];
    end
end
for i_pat = 1:length(pat)
    if ignorecase
        if once
            trouv = regexpi(c,pat{i_pat},'once'); % apply regexp on each pattern
        else
            trouv = regexpi(c,pat{i_pat});% apply regexp on each pattern only once
        end
    else
        if once
            trouv = regexp(c,pat{i_pat},'once'); % apply regexp on each pattern
        else
            trouv = regexp(c,pat{i_pat}); % apply regexp on each pattern only once
        end
    end
    idx{i_pat} = find(not(cellfun('isempty',trouv)));
end
if isempty(pat)
    idx = {};
end
makevector = @(x)(x(:));
switch combine
    case 1
        idx = makevector([idx{:}]);
    case 2
        idx = unique([idx{:}]);
    case 3
        for i_pat = 2:length(pat)
            idx{1} = intersect(idx{1},idx{i_pat});
        end
        idx = idx{1};
end
if inv % if we want to invert result, then do so.
    others = 1:numel(trouv);
    others(idx) = [];
    idx = others;
end
if lo
    out = false(size(c));
    out(idx) = true;
    idx = out;
end
