function txt = struct2table(T,header,fields,sname)

% txt = struct2table(T,header,fields,sname)
% Turn fields fields of structure T into a cell array "txt".
% If header is true, a first header line is added with field names. If
% header is a cell array of strings, these strings are used as headers
% (length(header) must be == length(fields))
% If provided, sname is a string that will be added as a first column to
% each row of txt.

% if nargin == 0
%     T = evalin('caller','T');
%     fields = {'RefDur' 'Freq' 'RT' 'RealT' 'FB'};
% end
if not(exist('fields','var'))
    fields = fieldnames(T);
end
if not(exist('header','var'))
    header = true;
end
if iscellstr(header)
    headerline = header;
    header = true;
else
    headerline = fields;
end
if not(numel(headerline) == numel(fields))
    error('Number of columns inconsistency, check input');
end
gotsname = exist('sname','var');
txt = cell(numel(T)+header,numel(fields)+gotsname);
if header
    if gotsname
        txt(1,:) = {'suj' headerline{:}};
    else
        txt(1,:) = {headerline{:}};
    end
end

for itri = 1:numel(T)
    if gotsname
        txt{itri+header,1} = sname;
    end
    for i_f = 1:numel(fields)
        txt{itri+header,i_f+gotsname} = T(itri).(fields{i_f});
    end
end







