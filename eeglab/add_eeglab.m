function add_eeglab(redo)

% add_eeglab(redo)
% 
% add all required folders of eeglab13 to the path.
% redo will force creating the list of folders again by launching eeglab.
% 

if not(exist('redo','var'))
    redo = 0;
end

p = getpref('eeglab','path',[]);
fprintf('Setting up EEGLAB...')
if redo || isempty(p)
    rm_frompath('eeglab')
    addpath([cdhome '/eeglab']);
    eeglab rebuild
    addpath(genpath([cdhome '/general/eeglab']));
    set(0,'DefaultTextInterpreter','Tex')
    p = regexp(path,['(.*?eeglab.*?)' pathsep],'match');
    setpref('eeglab','path',p)
else
    addpath(p{:});
end
disp('done')


function rm_frompath(what)

p = [path pathsep];

ps = regexp(p,['(.*?)' pathsep],'tokens');
for i = 1:numel(ps)
    ps{i} = ps{i}{1};
end
ps = ps(regexpcell(ps,what,'inv'));
p = [];
for i= 1:numel(ps)
    p = [p pathsep ps{i}];
end
path(p);

