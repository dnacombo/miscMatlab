function h = vline(x,varargin)

% h = vline(x,varargin)
% add vertical line(s) on the current axes at x
% all varargin arguments are passed to plot...

x = x(:);
varg = cellfun(@(x)num2str(x),varargin,'uniformoutput',0);
ticks = ~emptycells(regexp(varg,'ticks'));
ticklength = ~emptycells(regexp(varg,'ticklength'));
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
    xs = [x - diff(xlim)*ticklength, x + diff(xlim)*ticklength];
    arrayfun(@(i) line(xs,repmat(ticks(i),size(xs,1),2),'color','k'),1:numel(ticks));
end
ho = ishold;
hold on
h = plot([x x]',repmat(ylim,numel(x),1)',varargin{:});
if not(ho)
    hold off
end
if nargout == 0
    clear h
end
