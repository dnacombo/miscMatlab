function [in,todel] = rmempty(in)
% [out] = rmempty(in)
% remove empty cells from a cellarray
todel = find(emptycells(in));
in(todel) = [];
        