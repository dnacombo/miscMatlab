function [h] = fig(varargin)

% bypass builtin figure function to allow creating figures basic
% rectangular geometry.
%
%   fig(geom,...)
%
%   with geom a number between 11 and 99 indicating how many rows and
%   columns the resulting figure should size to.
%
%
% Max 2016

drawnow % finish any ongoing drawing before anything

if numel(varargin) > 0 && isnumeric(varargin{1}) && varargin{1} > 10 && varargin{1} < 100
    % create a figure with geometry according to 2 digit integer
    % figure(21) creates a 2 x 1 wide figure...
    f = varargin{1};    % capture geometry input 
    fr = floor(f/10);   % get number of rows
    fc = rem(f,10);     % get number of columns
    varargin(1) = [];   % remove geometry from original input
    if numel(varargin) >= 1 && all(ishandle(varargin{1}))
        h = varargin{1};
        varargin(1) = [];
        if not(isempty(varargin))
            set(h,varargin{:});
        end
        figure(h);
    else
        [h] = figure(varargin{:});% call builtin figure without geometry input
    end
    u = get(h,'unit');  % make sure we keep original position unit
    set(h,'unit','pixels');% make current position unit to pixels
    p = get(h,'Position');% get current position
    pu = get(0,'defaultfigureposition');% get what a one by one figure should be
    p([3 4]) = pu([3 4]).* [fc fr]; % enlarge expected figure size by number of rows and columns we want
    r = p(3) / p(4);% keep ratio

    s = get(0,'MonitorPositions');% check on which monitor we are
    m = (p(1) > s(1,3)); % m=0 monitor 1, m=1 monitor 2 (to the right)
    sorig = s;
    s = s(m+1,:); % consider only current monitor
    
    p(1) = p(1) - m*sorig(1,3); % if we're on monitor 2, subtract width of 
    %                       monitor 1 from left edge of figure
    
    % below we make sure we don't spread beyond the screen size.
    if p(1) + p(3) > s(3) % if end of figure beyond right edge
        p(1) = s(3) - p(3);% shift to the left as necessary
    end
    if p(1) <= 0 % now if left edge is outside
        p(3) = p(3) + p(1); % shrink width
        p(4) = p(3) / r;% apply ratio to height
        p(1) = 1;% stick to the left
    end
    if p(2) + p(4) > s(4) % if higher than monitor
        p(2) = s(4) - p(4); % shift to bottom as necessary
    end
    if p(2) <= 0 % if bottom is outside
        p(4) = p(4) + p(2);% shrink height
        p(3) = r * p(4);% apply ratio to width
        p(2) = 1;% stick to the bottom
    end        
    p(1) = p(1) + m*sorig(1,3);
    % set figure to the new computed position
    set(h,'Position',p);
    set(h,'unit',u);% set back unit to what it was
else
    [h] = figure(varargin{:});
end