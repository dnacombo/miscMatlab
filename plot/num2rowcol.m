function [row, col,n] = num2rowcol(num,R)
% 
% [row col, n] = num2rowcol(num[,R])
% 
% give me the right number of rows and columns for a subplot that will
% incorporate num axes with an approximate square look.
% n is the number of subplots we'll be missing to use all axes
%
% if R is provided, it is the approximate ratio col/row

if not(exist('R','var'))
    R = 1;
end
col =ceil(sqrt( num .* R ));
row = ceil(col./R);
n = col * row - num;

if nargout == 0
    disp([row(:) col(:)])
    clear row col
end