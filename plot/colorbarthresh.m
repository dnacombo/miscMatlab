function h = colorbarthresh(thresh,alphaval,varargin)

% h = colorbarthresh(thresh,alphaval,varargin)
% Colorbar to show potential transparency effects in the plot.
% thresh defines a logical operation on a variable called 'val', which
% corresponds to the values of the data. See below.
% alpha will be set to alphaval. Further arguments are passed to
% colorbar().
% thresh is defined as follows:
%   thresh = 'val < .5 & val > -.5';
% then the transparency of all values of the colorbar that are below .5 and
% above -.5 is set to alphaval.

if not(exist('alphaval','var'))
    alphaval = .5;
end
if not(ischar(thresh))
    try
        thresh = ['val < ' num2str(thresh)];
    catch
        error('Transparency should be defined with a string to evaluate or one number below which colorbar will be grayed out. See help colorbarthresh.')
    end
end
ha = gca;
hb = colorbar(varargin{:});
pixlim = 50;% number of pixels to consider an old cbar 
            % is the same as this one and needs to be deleted
set(hb,'Units','Pixels');
pos = round(get(hb,'position')/pixlim)*pixlim;
set(hb,'Units','Normalized');

% remove previous threshcolorbars for that axis
% (trust that position should be the same)
otherthreshcbars = findobj(gcf,'tag','threshColorbar');
if not(isempty(otherthreshcbars))
    oldunits = get(otherthreshcbars,'units');
    set(otherthreshcbars,'units','pixels');
    poss = get(otherthreshcbars,'position');
    if iscell(poss)
        for i = 1:numel(poss)
            try
                if all(round(poss{i}/pixlim)*pixlim == pos)
                    delete(otherthreshcbars(i))
                end
            catch
                set(otherthreshcbars,'units',oldunits{i});
            end
        end
    else
        try
            if all(round(poss/10)*10 == pos)
                delete(otherthreshcbars)
            end
        catch
            set(otherthreshcbars,'units',oldunits);
        end
        
    end
end

lims = get(hb,'clim');
n = size(colormap,1);
h = axes;
cmapthresh = linspace(lims(1),lims(2),n);
if pos(3)<pos(4)
    ll = get(hb,'ylim');
else
    ll = get(hb,'xlim');
end
val = linspace(ll(1),ll(2),n);
idx = eval(thresh);
cmapalpha = ones(size(cmapthresh));
cmapalpha(idx) = alphaval;

if pos(3)>pos(4)
    cmapthresh = cmapthresh';
    cmapalpha = cmapalpha';
end
xl = get(hb,'xlim');
yl = get(hb,'ylim');
xcmap2d = linspace(xl(1),xl(2),n);
ycmap2d = linspace(yl(1),yl(2),n);
himg = imagesc(xcmap2d,ycmap2d, cmapthresh');
set(himg,'alphaData',cmapalpha');
if strcmp(get(gcf,'renderer'),'zbuffer')
    disp('Warning, figure renderer is zbuffer. Transparency is not rendered. Set renderer to openGL or painters.')
end

props2copy = {
    'position'
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

set(h,'tag','threshColorbar');

set(hb,'visible','off');
drawnow
switch get(hb,'location')
    case {'North','South','East','West'}
        % because if we raise the axes again we'll put it on top of the
        % legend...
    otherwise
        axes(ha);
end

return

