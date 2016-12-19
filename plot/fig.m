function [h] = fig(varargin)

% bypass builtin figure function to allow creating figures basic
% rectangular geometry.
%
%   figure(geom,...)
%
%   with geom a number between 11 and 99 indicating how many rows and
%   columns the resulting figure should size to.
%
%
% Max 2016



if numel(varargin) > 0 && isnumeric(varargin{1}) && varargin{1} > 10 && varargin{1} < 100
    % create a figure with geometry according to 2 digit integer
    % figure(21) creates a 2 x 1 wide figure...
    f = varargin{1};    % capture geometry input 
    fr = floor(f/10);   % get number of rows
    fc = rem(f,10);     % get number of columns
    varargin(1) = [];   % remove geometry from original input
    [h] = figure(varargin{:});% call builtin figure without geometry input
    u = get(h,'unit');  % make sure we keep original position unit
    set(h,'unit','pixels');% make current position unit to pixels
    p = get(h,'position');% get current position
    pu = get(0,'defaultfigureposition');% get what a one by one figure should be
    p([3 4]) = pu([3 4]).* [fc fr]; % enlarge figure by number of rows and columns we want
    
    s = get(0,'MonitorPositions');% display that on the whole monitor
    % below we make sure we don't spread beyond the screen size.
    if p(1) + p(3) > sum(s(:,3))
        p(1) = sum(s(:,3)) - p(3);
    end
    if p(2) + p(4) > min(s(:,4))
        p(2) = min(s(:,4)) - p(4);
    end
    if p(1) <= 0
        r = p(3) / p(4);
        p(3) = p(3) + p(1);
        p(4) = p(3) / r;
        p(1) = 1;
    end
    if p(2) <= 0
        r = p(3) / p(4);
        p(4) = p(4) + p(2);
        p(3) = r * p(4);
        p(2) = 1;
    end        
    % set figure to the new computed position
    set(h,'position',p)
    set(h,'unit',u);% set back unit to what it was
else
    [h] = figure(varargin{:});
end