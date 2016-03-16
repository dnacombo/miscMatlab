function h = hline(y,varargin)

% h = hline(y,varargin)
% add horizontal line(s) on the current axes at y
% optional inputs: 
%   'ticks', [numeric] : position of ticks on the line
%   'ticklength', [scalar]: tick length nth of size of the axis
%                           default = 1/40: ticklength = diff(ylim)/40 
% all other varargin arguments are passed to plot...

y = y(:);
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
    ys = [y - diff(ylim)*ticklength, y + diff(ylim)*ticklength];
    arrayfun(@(i) line(repmat(ticks(i),size(ys,1),2),ys,'color','k'),1:numel(ticks));
end
ho = ishold;
hold on
h = plot(repmat(xlim,numel(y),1)',[y y]',varargin{:});
if not(ho)
    hold off
end
if nargout == 0
    clear h
end