function s = setdef(s,d)
% s = setdef(s,d)
% Merges the two structures s and d recursively.
% Adding the default field values from d into s when not present or empty.
% Keeping order of fields same as in d

if isstruct(s) && not(isempty(s))
    if not(isstruct(d))
        fields = [];
    else
        fields = fieldnames(d);
    end
    for i_f = 1:numel(fields)
        if isfield(s,fields{i_f})
            s.(fields{i_f}) = setdef(s.(fields{i_f}),d.(fields{i_f}));
        else
            [s.(fields{i_f})] = d.(fields{i_f});
        end
    end
    if not(isempty(fields))
        fieldsorig = setdiff(fieldnames(s),fields);
        s = orderfields(s,[fields; fieldsorig]);
    end
elseif not(isempty(s))
    s = s;
elseif isempty(s);
    s = d;    
end
