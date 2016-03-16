function pop_showneighb(channeighbstructmat,chanlocs,varargin)

% pop_showneighb(channeighbstructmat,chanlocs,varargin)
%
% This function shows the layout of channels. Clicking on one channel shows 
% neighbours as defined in channeighbstructmat
%
% pop_showneighb(channeighbstructmat,chanlocs)
%   channeighstructmat is a nbchan x nbchan matrix with 1 where connected
%       zero elsewhere.
%   chanlocs contains location information (in eeglab EEG.chanlocs format)
% 
% 
% pop_showneighb(channeighbstructmat,chanlocs,'labels','on')
%    shows channel names as stored in chanlocs.


g = finputcheck( varargin, ...
                 { 'labels'    'string'    {'on' 'off'}   'off'
                    });


h0 = figure(23537);clf;
set(gcf,'numbertitle','off','name','Channel neighborhood');

topoplot([],chanlocs,'electrodes','on', 'style','blank');
expectchannb = numel(chanlocs(cellfun(@(x)~isempty(x),{chanlocs.X})));

chi = get(gca,'children');
% chi = chi(1:numel(chanlocs));
ok = 0;
for ichi = 1:numel(chi)
    try
        x = get(chi(ichi),'xdata');
        if numel(x) == expectchannb
            allchi = chi;
            chi = chi(ichi);
            ok = 1;
            break
        end
    end
end
if ~ok
    tmpchi = [];
    for ichi = 1:numel(chi)
        try
            m = get(chi(ichi),'Marker');
            if strcmp(m,'.')
                tmpchi(end+1) = chi(ichi);
            end
        end
    end
    chi = tmpchi;
end

if numel(chi) == 1% then we have all channels in one chi
    X = get(chi,'XData');X = X(:)';
    Y = get(chi,'YData');Y = Y(:)';
    delete(chi)
    clear chi
    for i = 1:numel(allchi)
        try 
            x = get(allchi(i),'xdata');
            y = get(allchi(i),'ydata');
            if any(all([x == X;y == Y],1))
                delete(allchi(i))
            end
        end
    end
    hold on
    for i = 1:numel(X)
        chi(i) = plot(X(i),Y(i),'.k');
    end
elseif numel(chi) == expectchannb % then we have all channels in separate chi
    chi = chi(end:-1:1);
    X = get(chi,'XData');
    X = [X{:}];
    Y = get(chi,'YData');
    Y = [Y{:}];
end
% 
extodel = cellfun(@isempty,{chanlocs.X});
chanlocs(extodel) = [];
channeighbstructmat(extodel,:) = [];
channeighbstructmat(:,extodel) = [];
channeighbstructmat = channeighbstructmat|channeighbstructmat';
for i = 1:numel(chi)
    set(chi(i),'userdata',struct('chi',chi,'elec',i),'markersize',20)
    set(chi(i),'buttondownfcn',@(h,e)clicelec(h,e));
end
set(gcf,'userdata',struct('elec',[],'channeighbstructmat',channeighbstructmat));
inn = inputname(1);
if isempty(inn)
    inn = 'channeighbstructmat';
end
set(gcf,'closerequestfcn',['dum = get(gcbo,''userdata'');' inn ' = dum.channeighbstructmat;delete(gcbo);']);
if strcmp(g.labels,'on')
    for i = 1:numel(X)
        text(X(i),Y(i),chanlocs(i).labels);
    end
end

function clicelec(h,e)

datac = get(gcbo,'userdata');
dataf = get(gcbf,'userdata');

switch get(gcbf,'selectiontype')
    case 'normal'
        set(datac.chi,'color','k')
        set(datac.chi(datac.elec),'color','b')
        set(datac.chi(dataf.channeighbstructmat(datac.elec,:)),'color','r')
        dataf.elec = datac.elec;
    case 'alt'
        if isempty(dataf.elec); return; end
        dataf.channeighbstructmat(datac.elec,dataf.elec) = 1 - dataf.channeighbstructmat(datac.elec,dataf.elec);
        dataf.channeighbstructmat(dataf.elec,datac.elec) = 1 - dataf.channeighbstructmat(dataf.elec,datac.elec);
        datac.elec = dataf.elec;
        set(datac.chi,'color','k')
        set(datac.chi(datac.elec),'color','b')
        set(datac.chi(dataf.channeighbstructmat(datac.elec,:)),'color','r')
    case 'extend'
end

set(gcbf,'userdat',dataf);
