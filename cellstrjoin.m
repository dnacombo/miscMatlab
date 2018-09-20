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

if numel(C1) == numel(C2)
    joined = cell(size(C1));
    for i = 1:numel(C1)
        joined{i} = [C1{i} delim C2{i}];
    end
else
    joined = cell(numel(C1) * numel(C2),1);
    
    i = 1;
    for i1 = 1:numel(C1)
        for i2 = 1:numel(C2)
            joined{i} = [C1{i1} delim C2{i2}];
            i = i+1;
        end
    end
end