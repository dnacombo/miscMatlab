function c = num2cellstr(num,fmt)
% c = num2cellstr(num,fmt)
% creates a cell array of strings containing numel(num) strings using
% numstr(num) using format string fmt
%
c = cell(size(num));
for i = 1:numel(num)
    c{i} = num2str(num(i),fmt);
end
