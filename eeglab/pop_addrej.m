function EEG = pop_addrej(EEG,name,rej,col)

% EEG = pop_addrej(EEG,name,rej,col)
%
% add the rejections in rej to the EEG structure and prepare to display
% them with color col (RGB) with pop_eegplot
%
%
if ~islogical(rej) && all(ismember(unique(rej) ,[0 1]))
    rej = logical(rej);
end


EEG.reject.(['rej' name]) = zeros(1,EEG.trials);
EEG.reject.(['rej' name])(rej) = 1;
EEG.reject.(['rej' name 'E']) = zeros(EEG.nbchan,EEG.trials);
EEG.reject.(['rej' name 'col']) = col;

EEG.reject.disprej{end+1} = name;
