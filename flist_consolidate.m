function [outf, whichempty] = flist_consolidate(f,fs)

% [outf, whichempty] = flist_consolidate(f[,fields])
% 
% consolidate the output of flister.
% f is a vector structure with several fields. Typically used to list files
% with various attributes extracted from filenames. Each field (e.g. F) has a
% duplicate (e.g. Fidx) that is used to extract unique values.
% This function creates a variable outf with as many dimensions as there
% are fields (ignoring fields ending in idx) and populates the dimensions
% with individual elements of f.
% 
% if provided, fields indicates field names to consolidate on (not ending
% with idx).
%
% missing elements are listed in whichempty.
% 

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
% create an empty template output structure
ef = f(1);
for i_f = 1:numel(fields)
    if isnumeric(ef.(fields{i_f}))
        ef.(fields{i_f}) = [];
    elseif iscell(ef.(fields{i_f}))
        ef.(fields{i_f}) = {};
    elseif ischar(ef.(fields{i_f}))
        ef.(fields{i_f}) = '';
    end
end

% create output with correct shape
outf = repmat(ef,[cellfun(@numel,uf),1]);
% fill with the right values
for i = 1:numel(f)
    str = 'outf(';
    for i_f = 1:numel(idxfields)
        str = [str 'f(i).(''' idxfields{i_f} '''),'];
    end
    str(end) = ')';
    str = [str ' = f(i);'];
    eval(str);
end
% find out which ones are empty
iempty = cellfun(@isempty,{outf.name});
% list all their expected field values
[a,b,c,d,e,f,g,h] = ind2sub(size(outf),find(iempty));
wempty = [a;b;c;d;e;f;g;h];
if not(isempty(wempty))
    i = 8;
    while all(wempty(i,:) == 1)
        wempty(i,:) = [];
        i = i-1;
        if i == 0
            break
        end
    end
end
whichempty = cell(size(wempty));
for i = 1:size(wempty,2)
    for j = 1:size(wempty,1)
        whichempty{j,i} = of{j}{wempty(j,i)};
    end
end

if exist('fs','var')
    fs = cellfun(@(x) [x 'idx'],fs,'uniformoutput',0);
    dperm = find(ismember(idxfields',fs));
    order = 1:numel(idxfields);
    order(ismember(order,dperm)) = [];
    order = [dperm, order];
    outf = permute(outf,order);
    s = size(outf);s = mat2cells(s(1:numel(dperm)));
    s = {s{:} []};
    outf = reshape(outf,s{:});
end

function c = mat2cells(m)
c = cell(size(m));
for i = 1:numel(c)
    c{i} = m(i);
end
