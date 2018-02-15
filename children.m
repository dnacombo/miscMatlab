function h = children(o,varargin)

h = findobj(o,varargin{:},'-depth',1);
% h = get(o,'Children');
