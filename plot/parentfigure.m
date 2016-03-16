function h = parentfigure(h)

% hfig = parentfigure(h)
% return the parent figure of object handle h
%

while get(h,'parent') ~= 0
    h = get(h,'parent');
    h = parentfigure(h);
end
