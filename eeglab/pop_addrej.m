function EEG = pop_addrej(EEG,name,rej,rejE,col)

% EEG = pop_addrej(EEG,name,rej[,rejE],col)
%
% add the rejections in rej (and rejE) to the EEG structure and prepare to
% display them with color col (RGB) with pop_eegplot
%
%
narginchk(4,5)
if ~islogical(rej) && all(ismember(unique(rej) ,[0 1])) && isequal(size(rej),[1,EEG.trials])
    rej = logical(rej);
elseif ~islogical(rej)
    nrej = false(1,EEG.trials);
    nrej(rej) = 1;
    rej = nrej;clear nrej
end
if nargin == 4 && numel(rejE) == 3 % assume fourth input is col
    col = rejE;
    rejE = zeros(EEG.nbchan,EEG.trials);
end
if not(isequal(size(rejE),[EEG.nbchan,EEG.trials])) || not(isequal(size(rej),[1,EEG.trials]))
    error('wrong size of rejects')
end

EEG.reject.(['rej' name]) = zeros(1,EEG.trials);
EEG.reject.(['rej' name])(rej) = 1;
EEG.reject.(['rej' name 'E']) = rejE;
EEG.reject.(['rej' name 'col']) = col;

EEG.reject.disprej(strcmp(EEG.reject.disprej,name)) = [];
EEG.reject.disprej{end+1} = name;


com = sprintf('EEG = pop_addrej( %s,%s);', inputname(1), vararg2str({name,rej,col}));