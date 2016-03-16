function n = cellstr2num(s)

% n = cellstr2num(s)
% convert cell array of strings s to numeric array n of the same size.
% strings not convertible to numbers by str2double are turned to NaN.
%
% see also: str2double

n = cellfun(@(x)str2double(num2str(x)),s);

% return
% for i = 1:numel(s)
%     n(i) = str2double(num2str(s{i}));
% end
% 
% n= reshape(n,size(s));
