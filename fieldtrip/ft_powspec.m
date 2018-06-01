function spectrum = ft_powspec(cfg,data)

if not(iscell(data))
    data = {data};
end

def.channel                 = {'all'};
def.method                  = 'mtmfft';
def.output                  = 'pow';
def.foilim                  = [0 110];
def.taper                   = 'hanning';

cfg = setdef(cfg,def);
figure;

spectrum = cell(size(data));
for i_dat = 1:numel(data)
    spectrum{i_dat}                    = ft_freqanalysis(cfg,data{i_dat});
    loglog(spectrum{i_dat}.freq,spectrum{i_dat}.powspctrm(:,:)');
    hold on
end
xlabel('Frequency')
ylabel('Power')
xlim(minmax(spectrum{i_dat}.freq))