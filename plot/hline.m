function h = hline(y,varargin)

% h = hline(y,varargin)
% add horizontal line(s) on the current axes at y
% optional inputs: 
%   'ticks', [numeric] : position of ticks on the line
%   'ticklength', [scalar]: tick length nth of size of the axis
%                           default = 1/40: ticklength = diff(ylim)/40 
%   'color', [numeric] : color of the lines. may have as many rows as there are lines.
% all other varargin arguments are passed to plot...

y = y(:);
varg = cellfun(@(x)num2str(x),varargin,'uniformoutput',0);
ticks = cellfun(@(x)strcmp(x,'ticks'),varg);
ticklength = cellfun(@(x)strcmp(x,'ticklength'),varg);
if any(ticks)
    iticks = find(ticks);
    ticks = varargin{iticks+1};
    if any(ticklength)
        iticklength = find(ticklength);
        ticklength = varargin{iticklength+1};
        varargin(iticklength:iticklength+1) = [];
    else
        ticklength = 1/40;
    end
    varargin(iticks:iticks+1) = [];
    ys = [y - diff(ylim)*ticklength, y + diff(ylim)*ticklength];
    arrayfun(@(i) line(repmat(ticks(i),size(ys,1),2),ys,'color','k'),1:numel(ticks));
end
ho = ishold;
hold on
c = cellfun(@(x)strcmp(x,'color'),varg);
if any(c)
    cs = varargin{find(c)+1};
    varargin([find(c),find(c)+1]) = [];
end
h = plot(repmat(xlim,numel(y),1)',[y y]',varargin{:});
if any(c)
    if numel(h) == size(cs,1)
        for ih = 1:numel(h)
            set(h(ih),'color',cs(ih,:))
        end
    else
        set(h,'color',cs(1,:))
    end
end
if not(isempty(varargin))
    set(h, varargin{:});
end
if not(ho)
    hold off
end
if nargout == 0
    clear h
end
