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
if isempty(f);outf = [];whichempty = [];return;end
if ~exist('fs', 'var') || isempty(fs)
    % list all fields
    fields = fieldnames(f);
    % remove idxfields (they will be recreated).
    fields(regexpcell(fields,'.*idx$')) = [];
else
    fields = fs;
end
% move field name to the end of the list
if any(strcmp(fields,'name'))
    fields = movel(fields,find(strcmp(fields,'name')),numel(fields));
end
% find those that end with idx
idxfields = fields(regexpcell(fields,'.*idx$'));
if isempty(idxfields)
    % we don't have idx fields. create some.
    idxfields = cellfun(@(x) [x 'idx'],fields,'uniformoutput',0);
    idxfields(strcmp(idxfields,'nameidx')) = [];
    for ifield = 1:numel(idxfields)
        if isnumeric(f(1).(fields{ifield}))
            alluniques{ifield} = unique([f.(fields{ifield})]);
            alluniques{ifield}(isnan(alluniques{ifield})) = [];
        else
            alluniques{ifield} = unique({f.(fields{ifield})});
        end
    end
    for i = 1:numel(f)
        for ifield = 1:numel(idxfields)
            f(i).(idxfields{ifield}) = find(ismember(alluniques{ifield},f(i).(fields{ifield})));
        end
    end
else
    error('Don''t enter field names ending with ''idx'' (reserved)')
end
ofields = cellfun(@(x) x(1:end-3),idxfields,'uniformoutput',0);
% find all unique values for each of these fields
uf = {};
for i_f = 1:numel(idxfields)
    uf{i_f} = unique([f.(idxfields{i_f})]);
    for i = 1:numel(uf{i_f})
        % this is to keep correct shape of the output structure
        nuf{i_f}(uf{i_f}(i)) = i;
    end
    if isnumeric(f(1).(ofields{i_f}))
        of{i_f} = unique([f.(ofields{i_f})]);
    else
        of{i_f} = unique({f.(ofields{i_f})});
    end
end
% create an empty template output structure
ef = f(1);ef = structfun(@(x) [], ef, 'UniformOutput', false);
for i_f = 1:numel(fields)
    if isnumeric(ef.(fields{i_f})) || isstruct(ef.(fields{i_f}))
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
        str = [str 'nuf{' num2str(i_f) '}(f(i).(''' idxfields{i_f} ''')),'];
    end
    str(end) = ')';
    str = [str ' = f(i);'];
    eval(str);
end
% find out which ones are empty
if isfield(outf,'name')
    iempty = cellfun(@isempty,{outf.name});
else
    iempty = cellfun(@isempty,{outf.(fields{1})});
end
if nargout > 1
    % list all their expected field values
    [a,b,c,d,e,ff,g,h] = ind2sub(size(outf),find(iempty));
    wempty = [a;b;c;d;e;ff;g;h];
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
            if iscell(of{j})
                whichempty{j,i} = of{j}{wempty(j,i)};
            else
                whichempty{j,i} = of{j}(wempty(j,i));
            end
        end
    end
end

if exist('fields','var')
    fields = cellfun(@(x) [x 'idx'],fields,'uniformoutput',0);
    dperm = find(ismember(idxfields',fields));
    order = 1:numel(idxfields);
    order(ismember(order,dperm)) = [];
    order = [dperm, order];
    outf = permute(outf,order);
    s = [size(outf) ones(1,numel(dperm)-ndims(outf))];s = mat2cells(s(1:numel(dperm)));
    s = {s{:} []};
    outf = reshape(outf,s{:});
end

if numel(outf) ~= numel(f)
    fprintf('Dropped some data: %d --> %d elements\n', numel(f), numel(outf))
end

function c = mat2cells(m)
c = cell(size(m));
for i = 1:numel(c)
    c{i} = m(i);
end
