function c = num2cellstr(num)

c = cell(size(num));
for i = 1:numel(num)
    c{i} = num2str(num(i));
end
