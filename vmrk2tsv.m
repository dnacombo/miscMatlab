function evts = vmrk2tsv(mrk,sfreq)


evts = struct('onset',{},'duration',{},'trial_type',{},'value',{},'sample',{});

values = unique(cellfun(@(x,y)[x '/' y],{mrk.Type},{mrk.Desc},'uniformoutput',0));
for imk = 1:numel(mrk)
    evts(imk).onset = (mrk(imk).Pos - 1) / sfreq;
    evts(imk).duration = mrk(imk).Siz - 1;
    evts(imk).trial_type = [mrk(imk).Type '/' mrk(imk).Desc];
    evts(imk).value = find(strcmp(evts(imk).trial_type,values));
    evts(imk).sample = mrk(imk).Pos - 1;
    
    
end


end



