function [in,todel] = rmempty(in)
% [out] = rmempty(in)
% remove empty cells from a cellarray
todel = [];
try
    todel = find(emptycells(in));
catch
    for i = 1:numel(in)
        if isempty(in(i))
            todel(end+1) = i;
        end
    end
end
in(todel) = [];
