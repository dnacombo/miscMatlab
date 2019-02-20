function c = splitstrcell(str,delim)

if size(str,1) ~= 1
    error('str should be one line');
end
if ischar(delim)
    delim = regexp(str,delim);
end
    
c{1} = str(1:delim(1)-1);
for i = 2:numel(delim)
    if i < numel(delim)
        c{i} = str(delim(i)+1:delim(i+1)-1);
    else
        c{i} = str(delim(i)+1:end);
    end
end