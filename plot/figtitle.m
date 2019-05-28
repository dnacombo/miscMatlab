function hh = figtitle(str,varargin)

% h = figtitle(str,varargin)
% create a title centered to the top of the current figure
% with the string (or cell array of strings) str
% optional argument pairs to uicontrol('style','text', ...)
% are passed via varargin

h = gcf;

switch class(str)
    case 'char'
        w = size(str,2)+4;
        n = size(str,1);
    case 'cell'
        w = max(cellfun(@numel,str))+4;
        n = numel(str);
end
anchor = strcmp(varargin,'anchor');
if any(anchor)
    i = find(anchor);
    anchor = varargin{i+1};
    varargin(i:i+1) = [];
else
    anchor = 'north';
end
p = [.5 .5 .0001 .0001];al = 'center';
if contains(anchor,'north')
    p(2) = 1;
elseif contains(anchor,'south')
    p(2) = 0;
end
if contains(anchor,'west')
    p(1) = 0;
    al = 'left';
elseif contains(anchor,'east')
    p(1) = 1;
    al = 'right';
end


%%%% delete previous figtitle if any
hh = findobj(h,'tag', 'FigTitle');
if ~isempty(hh)
    delete(hh);
end
%%%% keep consistent toolbar appearance
hastoolbar = get(h,'toolbar');
% if strcmp(hastoolbar,'auto')
%     hastoolbar = findobj(h,'type', 'uicontrol');
%     if not(isempty(hastoolbar))
%         hastoolbar = 'none';
%     else
%         hastoolbar = 'figure';
%     end
% end
hasmenubar = get(h,'menubar');
%%%%

%%%% create new figtitle
hh = uicontrol('style','text','backgroundcolor',get(h,'color'),...
    'units','normalized','position',p,'string',str,...
    'horizontalalignment',al,'tag','FigTitle',varargin{:});
%%%% set proper position according to fontsize and number of lines 
set(hh,'units','characters')
p = get(hh,'position');
ff = get(hh,'fontsize')./10;
switch al
    case 'left'
        p(1) = p(1);
    case 'right'
        p(1) = p(1) -  ff*w;
    case 'center'
        p(1) = p(1) -  ff*w/2;
end 
if contains(anchor,'north')
    p(2) = p(2) - ff * n;
elseif contains(anchor,'south')
    p(2) = p(2);
end
p(3:4) = ff*[w n];
set(hh,'position',p)
set(hh,'units','normalize')
%%%%
set(gcf,'toolBar',hastoolbar)
set(gcf,'menubar',hasmenubar)
uistack(hh,'bottom');

