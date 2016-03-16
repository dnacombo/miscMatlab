function editall(str,cmds)

% editall(str,cmds)
% Edit all files matching str
%
% str = search pattern (dir)
% cmds = 'here' : search only in current directory (default, else in the entire path)
% 

if nargin <= 1
    cmds = 'here';
end
if not(exist('str','var')) || isempty(str)
    str = '*.m';
end

if ~isempty(strfind(cmds,'here'))
    f = dir(str);
    for i = 1:numel(f)
        f(i).path = fullfile(cd,f(i).name);
    end
else
    f = whichx(str);
end
if numel(f) > 20
    b = questdlg(['you''re about to edit ' num2str(numel(f)) ' files... proceed?'],'Editing many files...','Yes','No','No');
    if strcmp(b,'No') || isempty(b)
        return
    end
end
for i = 1:numel(f)
    if exist(f(i).path,'dir')
        continue
    end
    edit([f(i).path]);
end

