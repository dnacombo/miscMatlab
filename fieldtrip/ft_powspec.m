function spectrum = ft_powspec(cfg,data)


def.channel                 = {'all'};
def.method                  = 'mtmfft';
def.output                  = 'pow';
def.foilim                  = [0 110];
def.taper                   = 'hanning';

cfg = setdef(cfg,def);

spectrum                    = ft_freqanalysis(cfg,data);



figure;

loglog(spectrum.freq,spectrum.powspctrm(:,:)')
xlabel('Frequency')
ylabel('Power')