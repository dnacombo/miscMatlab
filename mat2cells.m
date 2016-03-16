function m = mat2cells(c)

str = 'mat2cell(c,';
for i = 1:ndims(c)
    str = [str 'ones(size(c,' num2str(i) '),1),'];
end
str(end) = ')';
m = eval(str);