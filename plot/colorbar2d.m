function h = colorbar2d(alphavals,varargin)

% h = colorbar2d(alphavals,varargin)
% 2 dimensional colorbar with second dimension devined with transparency.
% alphavals are possible transparency values (alpha channel)
% further arguments are passed to colorbar().

if not(exist('alphavals','var'))
    alphavals = linspace(0,1);
end

ha = gca;
hb = colorbar(varargin{:});
pos = get(hb,'position');

% remove previous 2dcolorbars for that axis
% (trust that position should be the same)
other2dcbars = findobj(gcf,'tag','2dColorbar');
if not(isempty(other2dcbars))
    poss = get(other2dcbars,'position');
    if iscell(poss)
        for i = 1:numel(poss)
            try
                if all(poss{i} == pos)
                    delete(other2dcbars(i))
                end
            end
        end
    else
        try
            if all(poss == pos)
                delete(other2dcbars)
            end
        end
    end
end

lims = get(hb,'clim');
n = size(colormap,1);nalpha = numel(alphavals);
h = axes;
cmap2d = repmat(linspace(lims(1),lims(2),n),nalpha,1);
xl = get(hb,'xlim');
yl = get(hb,'ylim');
xcmap2d = linspace(xl(1),xl(2),nalpha);
ycmap2d = linspace(yl(1),yl(2),n);
cmap2dalpha = repmat(alphavals,n,1);

if pos(3)>pos(4)
    cmap2d = cmap2d';
    cmap2dalpha = cmap2dalpha';
end
himg = imagesc(xcmap2d,ycmap2d,cmap2d');
set(himg,'alphaData',cmap2dalpha);

props2copy = {'position'
    'xlim'
    'ylim'
    'xdir'
    'ydir'
    'yaxislocation'
    'xaxislocation'
    'xtick'
    'ytick'
    };


set(h,props2copy,get(hb,props2copy));

set(h,'tag','2dColorbar');

set(hb,'visible','off');
drawnow
switch get(hb,'location')
    case {'North','South','East','West'}
        % because if we raise the axes again we'll put it on top of the
        % legend...
    otherwise
        axes(ha);
    end
