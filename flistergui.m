function re = flistergui(wd)

% help creating regular expressions for flister

defifnotexist('wd',cd);
handles.wd = wd;

%%
handles.figure = figure(394780);clf
set(gcf,'name','Flister regexp builder','numbertitle','off')

handles.list = uicontrol('style','list','units','normalized','position',[.01 .01 .98 .8],'Max',2);
handles.re = uicontrol('style','edit','units','normalized','position',[.01 .85 .8 .1],'string',getpref('flistergui','re','.*'));
handles.cd = uicontrol('style','pushbutton','units','normalized','position',[.82 .85 .16 .1],'string','Change Dir');
set(handles.re,'Callback',@updatelist)
set(handles.cd,'Callback',@docd)

hctxt = uicontextmenu;
uimenu(hctxt,'Label','Delete files...','Callback',@delfs);
uimenu(hctxt,'Label','Get corresponding re','Callback',@getRE);
set(handles.list,'uicontextmenu',hctxt);

guidata(gcf,handles)
%updatelist(handles.figure);

function getRE(hObject,eventdata)

handles = guidata(hObject);
allfs = get(handles.list,'UserData');
sel = allfs(get(handles.list,'Value'));
ore = get(handles.re,'String');

re = '';
i = 1;
while 1
    if i > numel(ore)
        break
    end
    if not(strcmp(ore(i:min(numel(ore),i+1)),'(?'))
        re(end+1) = ore(i);
        i = i+1;
        continue
    end
    i = i+3;
    re = [re '(?<'];
    currlab = '';
    while not(strcmp(ore(i),'>'))
        currlab = [currlab ore(i)];
        re = [re ore(i)];
        i = i+1;
    end
    re = [re '>'];
    ucurrlab = unique({sel.(currlab)});
    for i_f = 1:numel(ucurrlab)
        re = [re ucurrlab{i_f} '|'];
    end
    re(end) = ')';
    while not(strcmp(ore(i),')'))
        i = i+1;
    end
    if strcmp(ore(i),')')
        i = i+1;
    end
end
set(handles.re,'string',re);

function delfs(hObject,eventdata)

% Callback for delete files context menu

handles = guidata(hObject);
allfs = get(handles.list,'String');
todel = allfs{get(handles.list,'Value')};

rep = questdlg('Are you sure you want to delete these files?','Delete files...','No');
if strcmp(rep,'Yes')
    delete(todel{:});
end

function docd(hObject,eventdata)
% callback for Change dir button

handles = guidata(hObject);
handles.wd = uigetdir(handles.wd);
if isequal(handles.wd,0)
    return
end
guidata(hObject,handles)
updatelist(handles.list)


function updatelist(hObject, eventdata)
% Callback to update list (e.g. after changing re)
handles = guidata(hObject);
set(handles.re,'string',strtrim(get(handles.re,'string')))
f = flister(get(handles.re,'string'),'dir',handles.wd);
if not(isempty(f))
    set(handles.list,'string',{f.name})
else
    set(handles.list,'string',{})
end
set(handles.list,'UserData',f);
set(handles.list,'value',1);

assignin('base','flist',f)
assignin('base','re',get(handles.re,'string'))
setpref('flistergui','re',get(handles.re,'String'));
assignin('base','wd',handles.wd)
fprintf('\n')
disp(['We are selecting ' num2str(numel(f)) ' files with regular expression'])
disp(get(handles.re,'string'))
fprintf('\n')
disp(f)



