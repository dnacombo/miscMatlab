function [col row] = num2colrow(num,R)
% 
% [col row] = num2colrow(num[,R])
% 
% give me the right number of rows and columns for a subplot that will
% incorporate num axes with an approximate square look.
%
% if R is provided, it is the approximate ratio col/row

if not(exist('R','var'))
    R = 1;
end
col =ceil(sqrt( num .* R ));
row = ceil(col./R);

if nargout == 0
    disp([col(:) row(:)])
    clear col row
end