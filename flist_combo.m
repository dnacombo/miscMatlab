function nm = flist_combo(f,sep)

if not(exist('sep','var'))
    sep = '_';
end

% list all fields
fields = fieldnames(f);
% find those that end with idx
idxfields = fields(regexpcell(fields,'.*idx$'));
ofields = cellfun(@(x) x(1:end-3),idxfields,'uniformoutput',0);
% find all unique values for each of these fields
for i_f = 1:numel(idxfields)
    uf{i_f} = unique([f.(idxfields{i_f})]);
    of{i_f} = unique({f.(ofields{i_f})});
end

for i_f = 1:numel(f)
    nm{i_f} = '';
    for i = 1:numel(of)
        nm{i_f} = [nm{i_f} ofields{i} sep f(i_f).(ofields{i}) sep];
        if i == numel(of)
            nm{i_f}(end) = [];
        end
    end
end
