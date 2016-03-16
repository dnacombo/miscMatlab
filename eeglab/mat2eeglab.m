function EEG = mat2eeglab(mat,EEGi)

% EEG = dat2eeglab(mat,EEG)
% 
% Put a data matrix (2-3D) in an EEG structure using what's already in it.
%

EEG = EEGi;
if isstr(mat)
    strmat = mat;
    mat = load(mat);
    f = fieldnames(mat);
    mat = mat.(f{1});
else
    strmat = '<[';
    for i = 1:ndims(mat)
        strmat = [strmat num2str(size(mat,i))];
        if not(i == ndims(mat))
            strmat = [strmat ' '];
        end
    end
    strmat = [strmat '] data>'];
end

EEG.chanlocs = EEGi.chanlocs;
EEG.nbchan = numel(EEG.chanlocs);
EEG.chaninfo = EEGi.chaninfo;
EEG.xmin = EEGi.xmin;
EEG.srate = EEGi.srate;
EEG.pnts = size(mat,2);
EEG.xmax = EEG.xmin + (EEG.pnts-1)/EEG.srate;
EEG.trials = size(mat,3);

EEG.data = mat;

EEG.history = [EEGi.history sprintf('EEG = mat2eeglab(%s)',strmat)];

EEG = eeg_checkset(EEG);
