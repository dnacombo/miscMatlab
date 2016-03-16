function varargout = paste_figpos(where)

% paste_figpos(where)
% paste figure position stored in global variable figpos to current figure
% if where exists, it should be a string will be used as a tag to retrieve
% position from prefs
% 
% see also: copy_figpos, tell_figpos
global figpos
if nargin == 1
    figpos = [];
    if not(isempty(where))
        try
            figpos = getpref('figpos',num2str(where),get(0,'defaultfigureposition'));
        end
    end
end
if not(isempty(figpos)) && nargout ~= 1
    oldu = get(gcf,'units');
    set(gcf,'units','normalized')
    set(gcf,'position',figpos);
    set(gcf,'units',oldu);
end

if nargout == 1
    varargout{1} = figpos;
end
