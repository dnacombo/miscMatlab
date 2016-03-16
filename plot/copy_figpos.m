function copy_figpos(where)

% copy_figpos(where)
% copy position of the current figure
% and store it in a global variable figpos and in the preference field
% 'where' of preferences 'figpos'
%
% see also: paste_figpos, and tell_figpos
oldu = get(gcf,'units');
set(gcf,'units','normalized')
pos = get(gcf,'position');
set(gcf,'units',oldu);
global figpos
figpos = pos;

if nargin == 1 && not(isempty(where))
    setpref('figpos',num2str(where),pos)
end

