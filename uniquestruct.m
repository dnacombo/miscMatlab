function S = uniquestruct(S)

% US = uniquestruct(S)
% Return US, the unique elements of S
% 

i = 1;
while i < numel(S)
    iseq = arrayfun(@(x)isequal(x,S(i)),S);
    iseq(i) = 0;
    S(iseq) = [];
    i = i+1;
end
    

return