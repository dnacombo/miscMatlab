function status = vmrk_write(file,mrk,head,overwrite)

% status = vmrk_write(file,mrk,head,overwrite)
%
% write vmrk file
% mrk is a structure array with N elements, N being the number of markers
% to include.
% mrk structure fields are:
%   Mk:     numeric, marker number (starts with 1)
%   Type:   string, marker type
%   Desc:   string, description
%   Pos:    numeric, position in data points
%   Siz:    numeric, size in data points
%   Chan:   numeric, channel number (0 = marker is related to all channels)
%   Date:   string, only in markers with type 'New Segment',
%               acquisition date (YYYYMMDDhhmmssuuuuuu).
%
% head is a structure array with header information. If this is empty,
% default values will be written.

if ~exist('overwrite','var')
    overwrite = 0;
end
if exist(file,'file') && ~overwrite
    error([file ' exists. Set overwrite to true?'])
end
if not(isfield(head,'head'))
    head.head = {'Brain Vision Data Exchange Marker File, Version 1.0'};
end
if not(isfield(head,'Common_Infos'))
    head.Common_Infos = {'Codepage=UTF-8' 'DataFile=Unknown'};
end

sections = fieldnames(head);

head.head{end+1} = ';Edited with vmrk_write.m v0';

fid = fopen(file,'wt');
for i_s = 1:numel(sections)
    section = sections{i_s};
    if ~strcmp(section,'head')
        fprintf(fid,'\n[%s]\n',strrep(section,'_',' '));
    end
    for i = 1:numel(head.(section))
        fprintf(fid,'%s\n',head.(section){i});
    end
end

fprintf(fid,'\n');    
comment = {'[Marker Infos]'
'; Each entry: Mk<Marker number>=<Type>,<Description>,<Position in data points>,'
';             <Size in data points>, <Channel number (0 = marker is related to all channels)>'
';             <Date (YYYYMMDDhhmmssuuuuuu)>'
'; Fields are delimited by commas, some fields might be omitted (empty).'
'; Commas in type or description text are coded as "\1".'};
fprintf(fid,'%s\n',comment{:});
if ~strcmp(mrk(1).Type,'New Segment')
    ns = struct('Type','New Segment','Desc','','Pos',1,'Siz',1,'Chan',0,'Date',[datestr(now,'yymmddHHMMSSFFF') '000']);
    mrk = [ns mrk];
end

if ~isequal([mrk.Mk],1:numel(mrk))
    warning('Marker numbers (Mk) inconsistent.')
end
for i = 1:numel(mrk)
    mk = mrk(i);
    if strcmp(mk.Type,'New Segment')
        fprintf(fid,'Mk%d=%s,%s,%d,%d,%d,%s\n',mk.Mk,mk.Type,mk.Desc,mk.Pos,mk.Siz,mk.Chan,mk.Date);
    else
        fprintf(fid,'Mk%d=%s,%s,%d,%d,%d\n',mk.Mk,mk.Type,mk.Desc,mk.Pos,mk.Siz,mk.Chan);
    end
end
ok = fclose(fid);
    
    
    