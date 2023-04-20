function ft_peek(cfg,data)



def = [];
def.blocksize = 10;
def.viewmode = 'butterfly';
def.channel = 'meg';
def.magscale = 100;

cfg = setdef(cfg,def);

if ~exist('data','var')
    if ~isfield(cfg,'dataset')
        error('I need data to plot. A filename in cfg.dataset, or a data structure.')
    else
        data = ft_preprocessing(cfg);
        cfg = rmfield(cfg,'dataset');
    end
end

ft_databrowser(cfg,data);

