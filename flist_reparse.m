function of = flist_reparse(f,re)

% f = flist_reparse(f,re)
% 
% reparse the contents of f with the regular expression in re. See flister
% for an explanation.
%
%


nf = flister(re,'list',{f.name});

fields = fieldnames(nf);
for i_nf = 1:numel(nf)
    i_f = strcmp(nf(i_nf).name,{f.name});
    if sum(i_f) ~= 1
        continue
    end
    of(i_nf) = copyfields(nf(i_nf),f(i_f),fields);
end