function varargout = mylimo_resultsgui(varargin)
% MYLIMO_RESULTSGUI MATLAB code for mylimo_resultsgui.fig
%      MYLIMO_RESULTSGUI, by itself, creates a new MYLIMO_RESULTSGUI or raises the existing
%      singleton*.
%
%      H = MYLIMO_RESULTSGUI returns the handle to a new MYLIMO_RESULTSGUI or the handle to
%      the existing singleton*.
%
%      MYLIMO_RESULTSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYLIMO_RESULTSGUI.M with the given input arguments.
%
%      MYLIMO_RESULTSGUI('Property','Value',...) creates a new MYLIMO_RESULTSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mylimo_resultsgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mylimo_resultsgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mylimo_resultsgui

% Last Modified by GUIDE v2.5 04-Sep-2014 17:08:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mylimo_resultsgui_OpeningFcn, ...
    'gui_OutputFcn',  @mylimo_resultsgui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before mylimo_resultsgui is made visible.
function mylimo_resultsgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mylimo_resultsgui (see VARARGIN)

% Choose default command line output for mylimo_resultsgui
handles.output = hObject;

set(0,'DefaultFigureRenderer','OpenGL'); % to fix bug when setting transparency on multiple monitor config
handles.COLOR_BCG = [0.8039    0.8784    0.9686];
handles.COLOR_OBJ = [0.7294    0.8314    0.9569];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mylimo_resultsgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mylimo_resultsgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushload.
function pushload_Callback(hObject, eventdata, handles)
% hObject    handle to pushload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

EEG = pop_loadset;
if isempty(EEG)
    try
        EEG = handles.EEG;
    catch
        return
    end
end
EEG.times = EEG.xmin:1/EEG.srate:EEG.xmax;
if EEG.trials > 1
    uiwait(warndlg('Several trials in file. I don''t really know what do do... I''ll average them...'));
end
EEG.data = mean(EEG.data,3);
handles.EEG = EEG;
try
    cd(EEG.filepath);
    set(handles.edit_dir,'String',EEG.filepath);
end
handles.stats = [];
set(handles.check_robust,'value',0);
update_textloaded(handles)
assignin('base','EEG',EEG);
guidata(hObject,handles);

push_eeg_simplesurf_Callback(hObject, eventdata, handles)


% --- Executes on button press in push_pop_topoplot.
function push_pop_topoplot_Callback(hObject, eventdata, handles)
% hObject    handle to push_pop_topoplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pop_topoplot(handles.EEG);

% --- Executes during object creation, after setting all properties.
function push_pop_topoplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_pop_topoplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in push_eeg_simplesurf.
function push_eeg_simplesurf_Callback(hObject, eventdata, handles)
% hObject    handle to push_eeg_simplesurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentelec = 1;
[t handles.currenttime] = timepts(0,handles.EEG.times);
if all(handles.EEG.data(:) >= 0)
	allpos = 1;
else
    allpos = 0;
end

% topo
handles.htopofig = figure(64822);clf;
set(handles.htopofig,'numbertitle','off', 'defaultaxesfontsize',14,'color',handles.COLOR_BCG,'tag','Topo');
topoplot(handles.EEG.data(:,t),handles.EEG.chanlocs,'conv','on','emarker2',{handles.currentelec,'.','k',26,1});
title({handles.EEG.chanlocs(handles.currentelec).labels [num2str(handles.currenttime,'%.3g') 's']})
cx = caxis;
if allpos
    colormap hot
    caxis([0 max(abs(cx))]);
else
    colormap(varycolor(256,'jet'))
    caxis([-max(abs(cx)) max(abs(cx))]);
end
if exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file') && get(handles.check_T,'value')
    load(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'n');
    coloraxis = ['t(' num2str(n(1)-1) ')'];
elseif exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file')
    coloraxis = 'Amplitude (\muV/Std)';
end
h = colorbar;set(get(h,'ylabel'),'string',coloraxis,'fontsize',14);

% time course
handles.hplotfig = figure(6416584);clf;
set(handles.hplotfig,'numbertitle','off', 'defaultaxesfontsize',14,'color',handles.COLOR_BCG,'tag','Time Course');
set(gca,'ylimmode','auto');
handles.hplot = plot(handles.EEG.times,handles.EEG.data(handles.currentelec,:),'linewidth',2);
set(handles.hplot,'Tag','timecourse');
yl = ylim;xlim([handles.EEG.xmin handles.EEG.xmax]);
hold on
plot([handles.EEG.times(1) handles.EEG.times(1)],yl,':k');
hold off
title(handles.EEG.chanlocs(handles.currentelec).labels)

% simple surf
handles.hsimplesurffig = figure(63854);clf;
set(handles.hsimplesurffig,'numbertitle','off','color',handles.COLOR_BCG,'tag','ERPimage');
tmpEEG = handles.EEG;
if exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file') && get(handles.check_T,'value')
    load(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'t','n');
    tmpEEG.data = t;
    coloraxis = ['t(' num2str(n(1)-1) ')'];
elseif exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file')
    load(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'m');
    tmpEEG.data = m;
    coloraxis = 'Amplitude (\muV/Std)';
end
handles.EEG = tmpEEG;
    
[handles.hsimplesurffig, handles.hsimplesurf] = eeg_simplesurf(tmpEEG,[],handles.hsimplesurffig);
set(handles.hsimplesurf,'Tag','simplesurf');
set(get(handles.hsimplesurf,'parent'),'Tag','axessimplesurf');
set(gcf,'UserData',[handles.hplotfig handles.htopofig],'closerequestfcn','try close(get(gcbo,''UserData''));end; delete(gcbo)');
cx = caxis;
if allpos
    colormap hot
    caxis([0 max(abs(cx))]);
else
    colormap(varycolor(256,'jet'))
    caxis([-max(abs(cx)) max(abs(cx))]);
end
h = colorbar;set(get(h,'ylabel'),'string',coloraxis,'fontsize',14);
if get(handles.check_T,'value')
    p = str2num(get(handles.edit_clustpthresh,'String')) / 2;
%     delete(findobj('tag','threshlines'));
%     line('parent',h,'ydata',tinv([p p],n(1)),'xdata',get(h,'XLim'),'color','k','tag','threshlines')
%     line('parent',h,'ydata',tinv(1-[p p],n(1)),'xdata',get(h,'XLim'),'color','k','tag','threshlines')
end
figure(handles.hsimplesurffig);
set(gcf,'windowButtonDownFcn',@updatERP)

guidata(hObject,handles);

function updatERP(fig,evtdata)

% run on click within surface of simplesurf fig

handles = gimme_handles('mylimo_resultsgui');
EEG = handles.EEG;
axes(get(fig,'CurrentAxes'))
% locate point that has been clicked
pos = get(gca,'currentpoint');
if isempty(pos)
    pos = [Inf Inf];
end
pos = pos(1,[1 2]);
xl = xlim;yl = ylim;
pos(2) = floor(pos(2));
[dum pos(1)] = timepts(pos(1));
if pos(1)<xl(1) || pos(1)>xl(2) || pos(2)<=yl(1) || pos(2)>=yl(2)
    %clicked outside of area
    try
        pos = handles.lastpos;
    catch
        pos = [0 1];
    end
end
% translate to electrode numbers and times
elecvector = false(1,EEG.nbchan);newelecvector = elecvector;
elecvector(handles.currentelec) = 1;
newelecvector(chnb(pos(2))) = 1;
if not(isfield(handles,'lastelec'))
    handles.lastelec = find(newelecvector);
end
if not(isfield(handles,'lasttime'))
    [dum handles.lasttime] = timepts(pos(1));
end
if not(isfield(handles,'lastpos'))
    handles.lastpos = pos;
end
% depending on type of click
switch get(gcbf,'selectiontype')
    case 'normal'
        % select this electrode and time point
        [handles.currentelec] = find(newelecvector);
        [handles.currentelec dum handles.currentelecnamestr] = chnb(handles.currentelec);
        [dum handles.currenttime] = timepts(pos(1));
        handles.lasttime = handles.currenttime;
        handles.lastelec = handles.currentelec;
    case 'alt'
        % add/remove this electrode to/from selection
        handles.currentelec = find(xor(elecvector, newelecvector));
        [handles.currentelec dum handles.currentelecnamestr] = chnb(handles.currentelec);
        [dum handles.currenttime] = timepts(pos(1));
        handles.lasttime = handles.currenttime;
        handles.lastelec = find(newelecvector);
    case 'extend'
        % extend selection to electrodes or time points, which ever is
        % closest
        if diff(abs(pos - handles.lastpos)./[diff(xl) diff(yl)]) >= 0
            % elec range
            newsel = handles.lastelec:sign(find(newelecvector)-handles.lastelec):find(newelecvector);
            handles.currentelec = [handles.currentelec newsel];
            [handles.currentelec dum handles.currentelecnamestr] = chnb(handles.currentelec);
            [dum handles.currenttime] = timepts(pos(1));
            handles.lasttime = handles.currenttime;
            handles.lastelec = find(newelecvector);
        else
            % time range
            [handles.currentelec] = find(newelecvector);
            [handles.currentelec dum handles.currentelecnamestr] = chnb(handles.currentelec);
            handles.lastelec = handles.currentelec;
            [ dum tclick] = timepts(pos(1));
            if sign(tclick-handles.lasttime) >= 0
                tmp = [handles.lasttime tclick];
            else
                tmp = [tclick handles.lasttime];
            end
            [dum handles.currenttime] = timepts(tmp);
            [dum handles.lasttime] = timepts(pos(1));
        end
end
handles.lastpos = pos;
handles.lastelec = handles.currentelec;
drawfigs(handles)
guidata(handles.figure1,handles);

function drawfigs(handles)
EEG = handles.EEG;

% now draw each figure
% crosshair on simple surf
figure(handles.hsimplesurffig)
delete(findobj(gca,'-regexp','tag','crosshair'))
hold on
for i = 1:numel(handles.currentelec)
    hline(handles.currentelec(i),':k','tag','crosshairh');
end
if numel(handles.currenttime) == 1
    vline(handles.currenttime,':k','tag','crosshairv');
else
    yl = ylim;
    fill(repflipped([handles.currenttime(1) handles.currenttime(end)]),[yl(1) yl(1) yl(2) yl(2)],'w','facealpha',.2,'tag','crosshairv')
end

hold off

% time course
figure(handles.hplotfig)
clf
[handles.currentelec dum handles.currentelecnamestr] = chnb(handles.currentelec);
set(gcf,'name',['Time course at ' handles.currentelecnamestr])
try 
    tmp = load(handles.EEG.statsfile,'m');
    toplot = tmp.m;
catch 
    toplot = EEG.data;
end
h = plot(EEG.times,toplot(handles.currentelec,:),'linewidth',2);
if get(handles.check_robust,'Value')
    updatestatview(handles);
else
    set(handles.hsimplesurf,'AlphaData',1)
    try
        delete(findobj('tag','simplesurfcontour'))
    end
end
yl = ylim;xlim(round([EEG.xmin EEG.xmax]*1000)./1000);xl = xlim;
hold on
hline(0,'k:')
if numel(handles.currenttime) == 1
    vline(handles.currenttime,':k','tag','crosshairv');
else
    yl = ylim;
    fill(repflipped([handles.currenttime(1) handles.currenttime(end)]),[yl(1) yl(1) yl(2) yl(2)],'w','facealpha',.4,'tag','crosshairv')
end
[~, l] = chnb(handles.currentelec);
legend(h,l,'fontsize',12)
xlabel('Time (s)','FontSize',14)
ylabel('Amplitude (\muV/Std)','FontSize',14)
xtick([0 min(xl(2),.2)],'fontsize',14)
ytick([0 min(yl(2),1)],'fontsize',14)

box off
hold off

% topo plot
figure(handles.htopofig)
clf
hold on
set(gcf,'name',['Topographical map at ' num2str(handles.currenttime(1),4) '-' num2str(handles.currenttime(end),4) 's'] )
set(gcf,'UserData',handles.figure1);
topoplot(mean(EEG.data(:,ismember(EEG.times, handles.currenttime)),2),EEG.chanlocs,'conv','on','electrodes','on');%,'emarker2',{handles.currentelec,'.','k',26,1});

% now we replot the electrodes to be able to click on them
%%% todo: rewrite this function so that the click on elecs updates all
%%% plots...
chi = get(gca,'children');
% chi = chi(1:numel(chanlocs));
todel = [];
for i = 1:numel(chi)
    try
        if numel(get(chi(i),'XData')) == sum(~emptycells({EEG.chanlocs.X}))
            continue % we found electrodes
        else
            todel(end+1) = i;
        end
    catch
        todel(end+1) = i;
    end
end
chi(todel) = [];
hold on
X = get(chi,'XData');
Y = get(chi,'YData');
delete(chi)
for i = 1:numel(X)
    if any(i == handles.currentelec)
        mksiz = 26;
    else
        mksiz = 16;
    end
    plot3(X(i),Y(i),5,'.k',...
    'ButtonDownFcn',['handles = guidata(get(gcf,''UserData''));elecvec = false(1,handles.EEG.nbchan);newelecvec = elecvec;elecvec(handles.currentelec) =1;newelecvec(chnb(' num2str(i) ')) = 1; handles.currentelec = find(xor(elecvec, newelecvec)); ' ... 
    'guidata(get(gcf,''UserData''),handles);mylimo_resultsgui(''drawfigs'',handles);clear handles;'],...
    'markersize',mksiz);
%         'ButtonDownFcn',['chnb(' num2str(i) ')'],...
%         'markersize',mksiz);
end
%%%
if numel(handles.currenttime) > 1
    title({handles.currentelecnamestr [num2str(round(handles.currenttime(1)*100)/100,'%0.2g0') '-' num2str(round(handles.currenttime(end)*100)/100,'%0.2g0') ' s']})
else
    title({handles.currentelecnamestr [num2str(round(handles.currenttime(1)*100)/100,'%0.2g0') ' s']})
end
if exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file') && get(handles.check_T,'value')
    load(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'n');
    coloraxis = ['t(' num2str(n(1)-1) ')'];
elseif exist(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'file')
    coloraxis = 'Amplitude (\muV/Std)';
end

h = colorbar;set(get(h,'ylabel'),'string',coloraxis,'fontsize',14);
hold off
figure(handles.hsimplesurffig);

function edit_dir_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dir as text
%        str2double(get(hObject,'String')) returns contents of edit_dir as a double


% --- Executes during object creation, after setting all properties.
function edit_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',cd)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edit_dir.
function edit_dir_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edit_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

p = uigetdir(cd,'Choose a directory');
try
    cd(p);
    set(hObject,'String',p)
end


% --- Executes on button press in push_robustCI.
function push_robustCI_Callback(hObject, eventdata, handles)
% hObject    handle to push_robustCI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    fprintf('Loading saved confidence intervals... ')
    s = warning('off','MATLAB:load:variableNotFound');
    load(handles.EEG.statsfile,'CIpthresh');
    warning(s.state,s.identifier);
    if CIpthresh == str2num(get(handles.edit_pthresh,'String'))
        handles.stats.CIpthresh = CIpthresh;
        s = warning('off','MATLAB:load:variableNotFound');
        load(handles.EEG.statsfile,'CImask','CILo','CIHi');
        warning(s.state,s.identifier);
        handles.stats.CImask = CImask;
        handles.stats.CILo = CILo;
        handles.stats.CIHi = CIHi;
        fprintf('done\n')
    else
        handles.stats = struct;
        error
    end
catch
    fprintf('failed\n')
    fprintf('Computing robust confidence intervals... ')
    handles.stats.CIpthresh = str2num(get(handles.edit_pthresh,'String'));
    stats = load(handles.EEG.statsfile,'m','sd','n','boottH0');
    [handles.stats.CImask handles.stats.CILo handles.stats.CIHi]  = ...
        limo_robustci(stats.m,stats.sd,stats.n,stats.boottH0,handles.stats.CIpthresh);
    struct2ws(handles.stats);
    save(handles.EEG.statsfile,'-append','CIpthresh','CImask','CILo','CIHi');
    fprintf('done\n')
end

guidata(hObject,handles);

% --- Executes on button press in push_robustSTAT.
function push_robustSTAT_Callback(hObject, eventdata, handles)
% hObject    handle to push_robustSTAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    fprintf('Loading saved robust cluster mask... ')

    s = warning('off','MATLAB:load:variableNotFound');
    load(handles.EEG.statsfile,'STATpthresh');
    load(handles.EEG.statsfile,'STATClustpthresh');
    load(handles.EEG.statsfile,'STATpct');
    try
        load(handles.EEG.statsfile,'STATsepposneg');
        set(handles.check_posneg,'value',STATsepposneg);
    end
    warning(s.state,s.identifier);
    if STATpthresh == str2num(get(handles.edit_pthresh,'String')) ...
            && STATClustpthresh == str2num(get(handles.edit_clustpthresh,'String'))
        handles.stats.STATpthresh = STATpthresh;
        handles.stats.STATClustpthresh = STATClustpthresh;
        handles.stats.STATpct = STATpct;
        s = warning('off','MATLAB:load:variableNotFound');
        load(handles.EEG.statsfile,'STATmask');
        warning(s.state,s.identifier);
        handles.stats.STATmask = STATmask;
        fprintf('done\n')
    else
        handles.stats = struct;
        error
    end
catch
    fprintf('failed\n')
    handles.stats.STATpthresh = str2num(get(handles.edit_pthresh,'String'));
    handles.stats.STATClustpthresh = str2num(get(handles.edit_clustpthresh,'String'));
    fprintf('Loading Bootstrap data... ')
    stats = load(handles.EEG.statsfile,'t','p','n','boottH0','bootpH0');
    fprintf('done\n')
    try
        fprintf('Loading channel neighborhood matrix... ')
        s = warning('off','MATLAB:load:variableNotFound');
        load(handles.EEG.channeighbstructmatfile)
        warning(s.state,s.identifier);
        idxelecs = regexpcell({handles.EEG.chanlocs.labels}, {expected_chanlocs.labels},'exactignorecase');
        handles.stats.channeighbstructmat = channeighbstructmat(idxelecs,idxelecs);
%         figure;pcolor(channeighbstructmat);
        fprintf('done\n')
    catch
        fprintf('failed.\n')
        ok = 0;
        while 1
            resp = 'No, load one';%questdlg('Create a new channel neighborhood matrix?','No channel neighborhood file name in EEG structure','Yes','No, load one','Cancel','Cancel');
            switch resp
                case 'Yes'
                    resp = questdlg('Create from template?','Creating new neighborhood matrix','Yes','No, compute','Cancel','Cancel');
                    switch resp
                        case 'No, compute'
                            limo_expected_chanlocs
                            load expected_chanlocs
                        case 'Yes'
                            goto(fullfile(fileparts(which(mfilename)),'neighbours'))
                            f = uigetfile;
                            s = load(f);
                            neighb_labels = {s.neighbours.label};
                            present_labels = {handles.EEG.chanlocs.labels};
                            channeighbstructmat = eye(numel(present_labels));
                            for i = 1:numel(present_labels)
                                n = s.neighbours(regexpcell(neighb_labels,present_labels{i},'exactignorecase')).neighblabel;
                                channeighbstructmat(i,regexpcell(present_labels,n,'exactignorecase')) = 1;
                            end
                        case 'Cancel'
                            return
                    end
                    handles.stats.channeighbstructmat = channeighbstructmat;
                    %                 figure;pcolor(channeighbstructmat);
                case 'No, load one'
                    [p, f] = fileparts('/Ilse_01/Max/N399Ctxt/data/expected_chanlocs_sym.mat');%[f p] = uigetfile('*.mat','Choose an expected channel location file.','expected_chanlocs.mat');
                    load(fullfile(p, f));
                    channeighbstructmatfile = [p f];
                    handles.EEG.channeighbstructmatfile = channeighbstructmatfile;
                    idxelecs = regexpcell({handles.EEG.chanlocs.labels}, {expected_chanlocs.labels},'exactignorecase');
                    handles.stats.channeighbstructmat = channeighbstructmat(idxelecs,idxelecs);
                    if size(handles.stats.channeighbstructmat,1) ~= size(stats.t,1)
                        msgbox('better remake one')
                        continue
                    end
                    %                 figure;pcolor(channeighbstructmat);
                    pop_saveset(handles.EEG,'savemode','resave');
                case 'Cancel'
                    return
            end
%             pop_showneighb(channeighbstructmat,expected_chanlocs)
%             uiwait(gcf)
            r = 'Yes';%questdlg('Neighborhood ok?','Creating new neighborhood matrix','Yes','No','Cancel','Cancel');
            switch r
                case 'Yes'
                    break
                case 'No'
                    continue
                case 'Cancel'
                    return
            end
        end
    end
    %zeroing the lower triangle, including the diagonal
    % this speeds up the following computation
    for i = 1:size(channeighbstructmat,1)
        channeighbstructmat(i,i:end) = 0;
    end
%     figure;pcolor(channeighbstructmat);
    fprintf('Computing cluster size correction for multiple comparisons... \n')
    handles.stats.STATsepposneg = get(handles.check_posneg,'value');
    if handles.stats.STATsepposneg
        fprintf('Positive effects... \n')
        pperm = stats.bootpH0;
        tperm = stats.boottH0;
        pperm(sign(tperm) ~= 1) = NaN;
        PPreal = stats.p;
        Treal = stats.t;
        PPreal(sign(Treal) ~= 1) = NaN;
        if not(all(isnan(PPreal(:))))
            [mmask{1} ppct{1}] = clusterstats(tperm.^2,pperm,Treal.^2,PPreal, handles.stats.STATClustpthresh,handles.stats.STATpthresh, handles.stats.channeighbstructmat);
        else
            mmask{1} = 1;
            pct{1} = [];
        end
        fprintf('Negative effects... \n')
        pperm = stats.bootpH0;
        tperm = stats.boottH0;
        pperm(sign(tperm) ~= -1) = NaN;
        PPreal = stats.p;
        Treal = stats.t;
        PPreal(sign(Treal) ~= -1) = NaN;
        if not(all(isnan(PPreal(:))))
            [mmask{2} ppct{2}] = clusterstats(tperm.^2,pperm,Treal.^2,PPreal, handles.stats.STATClustpthresh,handles.stats.STATpthresh, handles.stats.channeighbstructmat);
        else
            mmask{2} = 1;
            pct{2} = [];
        end
        mask = mmask{1}|mmask{2};% mmask{1} is for negative values, mmask{2} is for positive
        pct = [ppct{:}];
    else
        pperm = stats.bootpH0;
        tperm = stats.boottH0;
        PPreal = stats.p;
        Treal = stats.t;
        if not(all(isnan(PPreal(:))))
            [mask pct] = clusterstats(tperm.^2,pperm,Treal.^2,PPreal, handles.stats.STATClustpthresh,handles.stats.STATpthresh, handles.stats.channeighbstructmat);
        else
            mmask = 1;
            pct = [];
        end
    end
    handles.stats.STATmask = mask;
    handles.stats.STATpct = pct;
%     [handles.stats.STATmask pct] = clusterstats(stats.boottH0.^2, stats.bootpH0,stats.t.^2,stats.p,handles.stats.STATClustpthresh,handles.stats.STATpthresh,handles.stats.channeighbstructmat);
    struct2ws(handles.stats);
    save(handles.EEG.statsfile,'-append','STATClustpthresh','STATpthresh','STATmask','STATpct');
    fprintf('done\n')
end

guidata(hObject,handles);

function edit_pthresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pthresh as text
%        str2double(get(hObject,'String')) returns contents of edit_pthresh as a double
set(hObject,'String',sprintf('%0.2g',str2num(get(hObject,'String'))));

% --- Executes during object creation, after setting all properties.
function edit_pthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function struct2ws(s,varargin)

% struct2ws(s,varargin)
%
% Description : This function returns fields of scalar structure s in the
% current workspace
% __________________________________
% Inputs :
%   s (scalar structure array) :    a structure that you want to throw in
%                                   your current workspace.
%   re (string optional) :          a regular expression. Only fields
%                                   matching re will be returned
% Outputs :
%   No output : variables are thrown directly in the caller workspace.
%
% _____________________________________
% See also : ws2struct ; regexp
%
% Maximilien Chaumon v1.0 02/2007


if length(s) > 1
    error('Structure should be scalar.');
end
if not(isempty(varargin))
    re = varargin{1};
else
    re = '.*';
end

vars = fieldnames(s);
vmatch = regexp(vars,re);
varsmatch = [];
for i = 1:length(vmatch)
    if isempty(vmatch{i})
        continue
    end
    varsmatch(end+1) = i;
end
for i = varsmatch
    assignin('caller',vars{i},s.(vars{i}));
end


% --- Executes on button press in check_robust.
function check_robust_Callback(hObject, eventdata, handles)
% hObject    handle to check_robust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_robust

handles.transp = .3;
guidata(hObject,handles);

if isfield(handles,'hsimplesurf') && ishandle(handles.hsimplesurf)
    updatERP(handles.hsimplesurffig,[]);
end
update_textloaded(handles)

function updatestatview(handles)

figure(handles.hsimplesurffig);
try
    set(get(handles.hsimplesurf,'parent'),'color','k')
    if get(handles.check_contour,'value')
        load(strrep(fullfile(handles.EEG.filepath,handles.EEG.filename),'.set','.mat'),'p')
        mask = p < handles.stats.STATClustpthresh;
        set(handles.hsimplesurf,'AlphaData',mask*handles.transp+1-handles.transp)
        hold on;
        [dum, h] = contour(handles.EEG.times,1:handles.EEG.nbchan,handles.stats.STATmask,1,'k');
        set(h,'tag','simplesurfcontour')
        hold off;
    else
        set(handles.hsimplesurf,'AlphaData',handles.stats.STATmask*handles.transp+1-handles.transp)
    end
end
figure(handles.hplotfig);
hold on;
try delete(handles.hplotarea); end
try
    handles.hplotarea = fill([handles.EEG.times handles.EEG.times(end:-1:1)], ...
        [handles.stats.CILo(handles.currentelec,:) handles.stats.CIHi(handles.currentelec,end:-1:1)], ...
        'r', 'EdgeColor', 'none', 'FaceColor', [1 0 0 ], 'facealpha', .1);
end
hold off;
update_textloaded(handles);


function handles = gimme_handles(name)

% handles = gimme_handles(name)
% retrieve the handles for the gui called name (str) 

prev = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
handles = guidata(findobj('name',name));
set(0,'ShowHiddenHandles',prev);


% --- Executes on button press in push_clearrobust.
function push_clearrobust_Callback(hObject, eventdata, handles)
% hObject    handle to push_clearrobust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CIHi = [];
CILo = [];
CImask = [];
CIpthresh = [];
STATmask = [];
STATpthresh = [];
try
    handles.EEG.channeighbstructmatfile = '';
    handles.EEG.channeighbstructmat = [];
    handles.EEG.saved = 'no';
    pop_saveset(handles.EEG,'savemode','resave');
end

try
    save(handles.EEG.statsfile,'CIHi','CILo','CImask','CIpthresh','STATmask','STATpthresh','-append');
end
handles.stats = [];
set(handles.check_robust,'value',0);
guidata(hObject,handles)



function edit_clustpthresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_clustpthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_clustpthresh as text
%        str2double(get(hObject,'String')) returns contents of edit_clustpthresh as a double


% --- Executes during object creation, after setting all properties.
function edit_clustpthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_clustpthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function update_textloaded(handles)
try
    EEG = handles.EEG;
catch
    return
end
txt = {};
if not(isempty(EEG))
    txt{end+1} = ['Setname: ' EEG.setname];
    txt{end+1} = ['File: ' EEG.filename];
    txt{end+1} = [num2str(EEG.nbchan) 'x' num2str(EEG.trials) 'x' num2str(EEG.pnts) ' data'];
    txt{end+1} = [num2str(EEG.xmin) '-' num2str(EEG.xmax) ' s (' num2str(EEG.srate) ' Hz)'];
    if EEG.trials>1
        txt{end+1} = '';
        txt{end+1} = ['Warning : we have several trials here. They are averaged.'];
        txt{end+1} = '';
    end
    txt{end+1} = '_______________________________________';
    txt{end+1} = EEG.history;
end

if get(handles.check_robust,'value')
    try
        stats = handles.stats;
        
        txt{end+1} = 'Clusters found and their % significance (if above 50%):';
        
        txt{end+1} = num2str(sort(stats.STATpct(stats.STATpct > .5)));
    end
    
end
set(handles.text_loaded,'String',txt);


% --- Executes on button press in check_posneg.
function check_posneg_Callback(hObject, eventdata, handles)
% hObject    handle to check_posneg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_posneg


% --- Executes on button press in push_snap.
function push_snap_Callback(hObject, eventdata, handles)
% hObject    handle to push_snap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figh = fieldnames(handles);
figh = figh(regexpcell(figh,'.*fig$'));
figh = cellfun(@(x)handles.(x),figh,'uniformoutput',0);
figh = [figh{:}];
figs = get(figh,'tag');
[l ok] = listdlg('liststring',figs);
if not(ok)
    return
end
p = getpref('mylimo','snappath',cd);
goto(p);
[fn, pn] = uiputfile('*.png');
goback;
if isequal(fn,0)
    return
end
if get(handles.check_snapres,'value')
    r = '-r300';
else
    r = '-r150';
end
figh = fieldnames(handles);
figh = figh(regexpcell(figh,'.*fig$'));
for i = 1:numel(l)
    figure(handles.(figh{l(i)}))
    c = get(gcf,'color');
    set(gcf,'color','w');
    drawnow
    if numel(l)>1
        nfn = regexprep(fullfile(pn,fn),'(\..*)$',['_' strrep(figs{l(i)},' ','_') '$1']);
    else
        nfn = fullfile(pn,fn);
    end
    export_fig(nfn,'-nocrop',r);
    set(gcf,'color',c);
end
setpref('mylimo','snappath',pn);

% --- Executes on button press in check_snapres.
function check_snapres_Callback(hObject, eventdata, handles)
% hObject    handle to check_snapres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_snapres


% --- Executes on button press in check_T.
function check_T_Callback(hObject, eventdata, handles)
% hObject    handle to check_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_T
push_eeg_simplesurf_Callback(handles.push_eeg_simplesurf, eventdata, handles)
updatestatview(handles)
updatERP(handles.hsimplesurffig,[])


% --- Executes on button press in check_contour.
function check_contour_Callback(hObject, eventdata, handles)
% hObject    handle to check_contour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_contour
push_eeg_simplesurf_Callback(handles.push_eeg_simplesurf, eventdata, handles)
handles = guidata(hObject);
check_robust_Callback(handles.check_robust, eventdata, handles)
