function joined = cellstrjoin(C1,C2, delim)


if not(exist('delim','var'))
    delim = '';
end
if not(iscellstr(C1))
    if ischar(C1)
        C1 = {C1};
    else
        error('Input should be a string or cell array of strings');
    end
end
if not(iscellstr(C2))
    if ischar(C2)
        C2 = {C2};
    else
        error('Input should be a string or cell array of strings');
    end
end

if not(ischar(delim))
    error('Delimiter should be a string')
end
joined = cell(numel(C1) * numel(C2),1);

i = 1;
for i1 = 1:numel(C1)
    for i2 = 1:numel(C2)
        joined{i} = [C1{i1} delim C2{i2}];
        i = i+1;
    end
end
