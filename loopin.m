function [i] = loopin(in,i)

% [i] = loopin(in,i)
% return the next integer above i.
% if it is above in, then return 1

i = rem(i,in)+1;