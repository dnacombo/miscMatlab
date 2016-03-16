function GRAB = datagrabber(re,varargin)

% GRAB = datagrabber(re)
% GRAB = datagrabber(re,'key',val, ...)
% GRAB = datagrabber(GRAB,'rerange',true, ...)
% GRAB = datagrabber(GRAB,'loadmode','eeglab', ...)
% GRAB = datagrabber(GRAB,'loadmode','eeglabstudy', ...)
%
% this function gets data from all files found with re.
% re is of the type 'AP(?<suj>.*)_YN1x2_(?<Noise>Yes|No)Noise_(?<SDT>Hit|Miss)\.set$'
% if a semicolon is found in re, datagrabber will attempt to split the
% grabbed data into different conditions according to an event selection.
% events are rewritten in a string, for each:
% event:##;type: ;latency: ;field1: ;field2: [where ## is the event number
% and spaces are replaced by the values of the field of the given event]
% the last part of re, after the first semicolon is of the form:
% fieldname:(acceptable|values);field2:(.*);field5:(Y|N)
% note that fields should be announced in the same order as they appear in
% the event structure of the EEG structure of the targetted files.
%
% (see regular expressions, named tokens)
%
% optional key-val pair :
%  'channels', chans : pick channels chans (cell array of strings).
%  'time', [min max] : pick time between min and max ms.
%  'trials', idx     : pick trials idx (numeric vector).
%  'loadmode',str
%       'simple' 'list' 'info' 'normal' 'eeglab' 'eeglabstudy'
%       'simple' will simply load all the files listed by flister without any
%       operation/range selection
%       'list' will just list files matching re.
%       'normal' expects EEGLab format and allows selecting a range and
%       doing basic operations on it (see 'range' below)
%       'info' will just pull the EEG structure from the files (assumes
%       EEGlab format).
%       'eeglab' will attempt to load the data in EEGlab. Assumes GRAB
%       structure as first input. Selecting dimensions or range is ignored
%       (i.e. should have been done before).
%       'eeglabstudy' will attempt to load the data in EEGlab and create a
%       study with all the datasets and conditions stored in GRAB.Selecting
%       dimensions or range is ignored (i.e. should have been done before).
% 'range', struct
%       defines the range to pick for each dimension of the data.
%       it is a structure with fields 'channels' 'time' 'trials'
%       for each dimension, a field 'oper' defines the simple operation to
%       perform on the data ('mean','max','min','std', or the default:
%       'none').
% 'rerange', boolean
%       If true, use range, but assume that the data has been read already
%       and will just attempt to pick from it with the new range structure.
% 'exclude', str
%       File names matching regexp str will be excluded from the grab
% 'sparemem', boolean
%       Clear excluded data range from memory.

global ALLEEG STUDY

supported_dimensions = {'channels' 'time' 'trials'};
% just an example of re if nothing entered.
if nargin == 0
    re = 'AP(?<suj>.*)_YN1x2_(?<Noise>Yes|No)Noise_(?<SDT>Hit|Miss)\.set$';
end
if ischar(re)
    re = ['.*' filesep regexprep(re,'^/','')];
end
%%%%%% input check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = finputcheck( varargin, ...
    { 'exclude'   { 'string';'cell' }    []   ''
    'loadmode'   'string'    {'simple' 'list' 'info' 'normal' 'eeglab' 'eeglabstudy'}   'normal'
    'channels'   { 'real'; 'string'; 'cell' } [] ''
    'time'   'real' [] []
    'trials'   'real' [] []
    'range'   'struct'    []  struct([])
    'rerange' {'boolean'} [] false
    'promptorder' 'boolean' [] true
    'sparemem' 'boolean' [] true
    'promptorderwithin' 'boolean' [] true
    'waitafterlisting' 'boolean' [] false
    'simpleloadwhat' 'string' '' ''
    'dir','string','',cd});
if isstr(g)
    error(g);
end
if strncmp(g.loadmode,'eeglab',6)
    evalin('base','eeglab redraw');
end
%%% merge input with defaults
% create default
for i = 1:numel(supported_dimensions)
    defrange.(supported_dimensions{i}) = struct('idx',Inf,'oper','none'); % Inf will mean All.
end
% merge
g.range = setdef(g.range,defrange);
% add other input
for i = 1:numel(supported_dimensions)
    if not(isempty(g.(supported_dimensions{i})))
        g.range.(supported_dimensions{i}).idx = g.(supported_dimensions{i});
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end input check

%%%%%% if we just asked to rerange the grabbed data, do it here and return
% or if asked to extract eeglab
if g.rerange || strncmp(g.loadmode,'eeglab',6)
    ALLEEG = [];
    GRAB = re;
    clear re
    if ischar(GRAB)
        error('Data should already have been loaded. Enter it as first argument...')
%     elseif ischar(GRAB(1).EEG.data)
%         error('Data should already have been loaded. Not just in info mode...')
    end
%     g.range = makerange(GRAB,g.range);
%     for i = 1:numel(GRAB)
%         GRAB(i) = rerange(GRAB(i),g.range,g.sparemem);
%     end
    if strncmp(g.loadmode,'eeglab',6)
        for i = 1:numel(GRAB)
            [ALLEEG] = eeg_store(ALLEEG,GRAB(i).EEG);
        end
        if strcmp(g.loadmode,'eeglab')
            assignin('base','ALLEEG',ALLEEG);
            evalin('base','eeglab redraw');
            return
        end
    end
    if g.rerange
        return
    end
end
if strcmp(g.loadmode,'eeglabstudy')
    % if we requested to create a STUDY, create and return.
    if g.promptorder
        drawnow;
        commandwindow;
        fs = fieldnames(GRAB);
        iidx = regexpcell(fs,'idx$');
        fidx = fs(iidx);
        f = strrep(fidx,'idx','');
        idx = regexpcell(fs,f,'exact');
        for i = 1:numel(f)
            s{i} = sprintf('%s\t\t%d',f{i},i);
        end
        disp(strjust(char(s),'right'));
        s = input('Give order of the factors (1 is subject factor): ','s');
        s = str2num(s);
        fidx = fidx(s);
        f = f(s);
        fs(iidx) = fidx;
        fs(idx) = f;
        GRAB = orderfields(GRAB,fs);
    end
    [STUDY ALLEEG GRAB] = makeeeglabstudy(GRAB,ALLEEG);
    assignin('base','ALLEEG', ALLEEG);
    assignin('base','STUDY', STUDY);
    assignin('base','CURRENTSTUDY', 1);
    evalin('base','eeglab redraw')
    return;
end
% split file and event re.
if not(isempty(regexp(re,';', 'once')))
    revts = re(regexp(re,';','once')+1:end);
    re = re(1:regexp(re,';','once')-1);
else
    revts = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% list all files matching re
[f] = flister(re,'exclude',g.exclude,'dir',g.dir);
% now we have listed all the files and attributed factors as defined in re
% to them.
% r = questdlg({['I''ve found ' num2str(numel(f)) ' files.'] 'Move on?'});
% switch r
%     case {'No' 'Cancel'}
%         return
% end
if g.waitafterlisting
    disp({f.name}')
    pause
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GRAB(1:numel(f),1) = f;

GRAB(1).re = re;
if strcmp(g.loadmode,'list')
    return;
end
disp(['loading ' num2str(numel(f)) ' files.'])
% if simple load requested, assume data is in -mat format.
if strcmp(g.loadmode,'simple')
    disp('loadmode: SIMPLE')
    for i_f = 1:numel(f)
        disp(f(i_f).name);
        if isempty(g.simpleloadwhat)
            GRAB(i_f).DATA = load(f(i_f).name,'-mat');
        else
            GRAB(i_f).DATA = load(f(i_f).name,g.simpleloadwhat,'-mat');
        end
    end
else
    %%%%%%%%%%%%%%%%%%%%% We assume data on disk is in eeglab
    %%%%%%%%%%%%%%%%%%%%% format and will use pop_loadset to load.
    minmin = Inf;maxmax = -Inf;
    for i_f = 1:numel(f)
        GRAB(i_f,1).EEG = pop_loadset('filename',f(i_f).name,'loadmode','info');
    end
    commonlocs = cellfun(@(x)x.chanlocs,{GRAB.EEG},'uniformoutput',0);
    commonlocs = eeg_mergelocs(commonlocs{:});
    GRAB(1).commonlocs = commonlocs;
    g.range = makerange(GRAB,g.range);
end
%%% examine factors at between file level (different files for different
%%% conditions).
grabfs = fieldnames(f);% find all fields
grabiidx = regexpcell(grabfs,'idx$');% find the idx fields (those that are interesting)
grabidxf = grabfs(grabiidx);
grabf = strrep(grabidxf,'idx','');% and find their twin brothers (no idx)
grabif = regexpcell(grabfs,grabf,'exact');

% if we get here, we have to read and rerange the data.
if numel(grabf)
    [GRAB sfact] = computecond(GRAB,1);
else
    sfact = [];
end

for i_f = 1:numel(GRAB)
    % here we read the data.
    if ~strcmp(g.loadmode,'simple') && ~strcmp(g.loadmode,'info')
        GRAB(i_f).EEG = pop_loadset(f(i_f).name);
    end
    GRAB(i_f).name = f(i_f).name;
    for i = 1:numel(grabf)
        GRAB(i_f).(grabf{i}) = f(i_f).(grabf{i});
    end
    GRAB(i_f).data = [];
    GRAB(i_f).range = [];
    % and rerange it
    if ~strcmp(g.loadmode,'simple') && ~strcmp(g.loadmode,'info')
        GRAB(i_f) = rerange(GRAB(i_f),g.range,g.sparemem);
    end
end
if not(isempty(sfact))
    for i_s = 1:numel(unique({GRAB.(sfact)}))
        for i_f = 1:numel(unique([GRAB.cond]))
            idx = [GRAB.cond] == i_f & [GRAB.([sfact 'idx'])] == i_s;
            if all(~idx)
                disp('warning: missing file')
            elseif sum(idx) > 1 && numel(unique([GRAB.cond])) == 1
                disp(['warning subject ' num2str(i_s) ': several files per condition... I''ll be lining them up all along the second dimension of the grab']);
                ii = find(idx);
                for i = 1:numel(ii)
                    GB(i_s,i) = GRAB(ii(i));
                end
            else
                GB(i_s,i_f) = GRAB(idx);
            end
        end
    end
    clear GRAB
    GRAB = GB;
    clear GB
end
if strcmp(g.loadmode,'simple') || strcmp(g.loadmode,'info')
    return
end
if not(isempty(revts))

    revts = regexprep(revts,'(\w+):\((.*?)\)','$1:(?<$1>$2)');
    revts = ['event:(?<event>.*?);' revts ];
    revts = regexprep(revts,';',';.*');
    revts = regexprep(revts,'\((\?\<.*?\>\.\*)\)','($1?)');
    if ~strcmp(revts(end),';')
        revts = [revts ';'];
    end
    for i_s = 1:size(GRAB,1)% for each subj
        for i_c = 1:size(GRAB,2)% for each cond created at the between files level
            if isempty(GRAB(i_s,i_c))
                continue
            end
            evts = elister(revts,GRAB(i_s,i_c).EEG.event);% list all events in grabbed data.
            evts = reevt(evts, g.promptorderwithin);% select those that are relevant
            g.promptorderwithin = false;
            % replicate that GRAB along the 3d dimension as many times as
            % we have conditions.
            nconds = numel(unique([evts.cond]));
            if GRAB(1).nconds > 1 && nconds > 1
                error('At this time, I cannot deal with conditions defined at the same time at the between- and within-files levels (except for subjects). Please choose one.');
            end
            GRAB(i_s,i_c,1:nconds) = repmat(GRAB(i_s,i_c),[1,1,nconds]);
            for ic = 1:nconds
                GRAB(i_s,i_c,ic).evts = evts([evts.cond] == ic);
                evtfs = fieldnames(GRAB(i_s,i_c,ic).evts);
                evtfs(regexpcell(evtfs,'event(idx)?')) = [];
                evtfs = evtfs(regexpcell(evtfs,'idx$'));
                evtfs = regexprep(evtfs,'idx$','');
                str = '';
                for i = 1:numel(evtfs)
                    if not(numel(unique({GRAB(i_s,i_c,ic).evts.(evtfs{i})})) == 1)
                        error('wtf')
                    end
                    str = [str evtfs{i} GRAB(i_s,i_c,ic).evts(1).(evtfs{i})];
                    if not(i == numel(evtfs))
                        str = [str '_'];
                    end
                end
                if not(isempty(GRAB(i_s,i_c,ic).condname))
                    GRAB(i_s,i_c,ic).condname = [GRAB(i_s,i_c,ic).condname ';' str];
                else
                    GRAB(i_s,i_c,ic).condname = str;
                end
                GRAB(i_s,i_c,ic).trials = numel(GRAB(i_s,i_c,ic).evts);
                GRAB(i_s,i_c,ic).range.trials.idx = [GRAB(i_s,i_c,ic).EEG.event([GRAB(i_s,i_c,ic).evts.event]).epoch];
                GRAB(i_s,i_c,ic) = rerange(GRAB(i_s,i_c,ic),GRAB(i_s,i_c,ic).range,g.sparemem);
            end
        end
    end
else
    disp('No conditions based on events. I guess you gave me conditions as files.');
    if isfield(GRAB,'nconds') && GRAB(1).nconds == 1
        disp('You should define conditions before proceeding...')
    end
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GRAB = rerange(GRAB,range,sparemem)

supported_dimensions = fieldnames(range);
GRAB.range = range;

%%%%%% get channels indices from chan labels (avoids confusion if some
%%%%%% datasets have missing channels)
disp('=========================================================')
[GRAB.range.channels.idx] = chnb(range.channels.chans,{GRAB.EEG.chanlocs.labels});
GRAB.range.channels.chans = {GRAB.EEG.chanlocs(GRAB.range.channels.idx).labels};
if numel(GRAB.range.channels.idx) ~= numel(range.channels.chans);
    miss = regexpcell(range.channels.chans,GRAB.range.channels.chans,'exactinv');
    disp(['Warning:  in ' GRAB.name])
    disp([' missing channel(s) ' sprintf('%s ',range.channels.chans{miss})]);
    GRAB.range.channels.chans = {GRAB.EEG.chanlocs(GRAB.range.channels.idx).labels};
end
%%%%%% get time indices
if not(isempty(GRAB.EEG.times))
    [GRAB.range.time.idx GRAB.range.time.times] = timepts(GRAB.range.time.lims,GRAB.EEG.times);
else
    [GRAB.range.time.idx GRAB.range.time.times] = timepts(GRAB.range.time.lims,linspace(GRAB.EEG.xmin*1000, GRAB.EEG.xmax*1000, GRAB.EEG.pnts));
end
GRAB.range.time.lims = [min(GRAB.range.time.times) max(GRAB.range.time.times)];
%%%%%% get trials
if all(isinf(GRAB.range.trials.idx))
    GRAB.range.trials.idx = 1:GRAB.EEG.trials;
else% we must remove out of bounds requested trials
    test = GRAB.range.trials.idx > GRAB.EEG.trials;
    if any(test)
        disp(['Warning: wanted to grab trials ' num2str(GRAB.range.trials.idx(test)) '.'])
        disp([ 'numel(trials) == ' num2str(GRAB.EEG.trials) '. Only existing trials will remain.']);
        GRAB.range.trials.idx(test) = [];
    end
end
%%%%%%

GRAB.data = GRAB.EEG.data(GRAB.range.channels.idx, GRAB.range.time.idx, GRAB.range.trials.idx);
if 0%sparemem
    %Here there's a bug. pop_select removes one time point at the end of
    %the epochs. It's actually in epoch.m that there's a (-1) somewhere.
    GRAB.EEG = pop_select(GRAB.EEG,'time',GRAB.range.time.lims/1000,'channel',GRAB.range.channels.idx, 'trial', GRAB.range.trials.idx);
    disp('Cleared unused data.')
end

for i_dim = 1:numel(supported_dimensions)
    switch GRAB.range.(supported_dimensions{i_dim}).oper
        case 'none'
        case 'mean'
            GRAB.data = mean(GRAB.data,i_dim);
        case 'std'
            GRAB.data = std(GRAB.data,[],i_dim);
        case 'max'
            GRAB.data = max(GRAB.data,[],i_dim);
        case 'min'
            GRAB.data = min(GRAB.data,[],i_dim);
    end
end

function evts = reevt(evts, promptorder)

persistent s
evtfs = fieldnames(evts);
toignore = regexpcell(evtfs,'event(idx)?');
[evts.event] = rep2struct(cellfun(@str2num,{evts.event}));

evtfs(toignore) = [];
iidx = regexpcell(evtfs,'idx$');
clear f
if isempty(iidx)
    f = [];
else
    fidx = evtfs(iidx);
    f = strrep(fidx,'idx','');
    idx = regexpcell(evtfs,f,'exact');
    for i_f = 1:numel(f)
        nf(i_f) = numel(unique({evts.(f{i_f})}));
    end
end
if isempty(f)
    nf = 1;
    promptorder = 0;
end

if promptorder && numel(f) > 1
    s = {};
    drawnow;
    commandwindow;
    for i = 1:numel(f)
        s{i} = sprintf('%s\t\t%d',f{i},i);
    end
    disp(strjust(char(s),'right'));
    ns = [];
    while numel(ns) ~= numel(f)
        ns = input('Give order of the factors: ','s');
        ns = str2num(ns);
    end
    s = ns;
elseif not(isempty(s))
    % this should be the order specified on the previous call.
else
    s = 1:numel(nf);
end
fidx = fidx(s);
f = f(s);
evtfs(iidx) = fidx;
evtfs(idx) = f;
evtfs = {'event' 'eventidx' evtfs{:}};
evts = orderfields(evts,evtfs);

toignore = regexpcell(fieldnames(evts),'event');
[evts] = computecond(evts,toignore(1));

function range = makerange(GRAB,range)
% this function creates a range structure with appropriate fields (idx and
% so on).

%%%%%%%%%%%%%%% using channel names rather than indices
if not(iscell(range.channels.idx)) && isinf(range.channels.idx(1))
    range.channels.idx = 1:numel(GRAB(1).commonlocs);
end
[range.channels.idx range.channels.chans] = chnb(range.channels.idx,{GRAB(1).commonlocs.labels});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% for time, using limits.
if isempty(range.time.idx)
    % time range
    range.time(1).lims = [-Inf +Inf];
elseif isnumeric(range.time.idx)
    if numel(range.time.idx) == 2
        if not(range.time.idx(2) >= range.time.idx(1))
            error('Time limits should be [min max].')
        end
        %assume it's lims
        range.time.lims = range.time.idx;
    elseif isfield(range.time,'lims') && numel(range.time.lims) == 2
        if not(range.time.lims(2) >= range.time.lims(1))
            error('Time limits should be [min max].')
        end
    elseif isinf(range.time.idx)
        range.time(1).lims = [-Inf +Inf];
    else
        error('Time limits should be provided, not time points')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% for trials, use indices
if isempty(range.trials)
    range.trials(1).idx = [Inf];
end
clear GRAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [STUDY ALLEEG GRAB] =  makeeeglabstudy(GRAB,ALLEEG)
%%
%%
[GRAB sfact] = computecond(GRAB,1);
clear STUDY ALLEEG
cmd = ['[STUDY ALLEEG] = std_editset( [], ALLEEG,''name'', ''' GRAB(1).re ''', ''commands'', {'];
for i = 1:numel(GRAB)
    fields = fieldnames(GRAB(i).EEG);
    for i_f = 1:numel(fields)
        ALLEEG(i).(fields{i_f}) = GRAB(i).EEG.(fields{i_f});
    end
    cmd = [cmd '{ ''index'' ' num2str(i) ' ''subject'' ''' GRAB(i).(sfact) ''' ''condition'' ''' num2str(GRAB(i).cond) ''' } '];
end
cmd = [cmd '},''updatedat'',''off'' );'];
eval(cmd);
[ STUDY ALLEEG ] = pop_study(STUDY, ALLEEG, 'gui', 'on');

function [s sfact] = computecond(s,is)
% this creates a field 'cond' according to the factors in s.
% 'is' is the field number of the fields that must be ignored to compute conditions

if not(exist('is','var'))
    is = [];
end
% first list fields and find those corresponding to factors.
fs = fieldnames(s);
fidx = fs(regexpcell(fs,'idx$'));
f = strrep(fidx,'idx','');
if not(isempty(is))
    sfact = f{is};
else
    sfact = '';
end
f(is) = [];%delete to be ignored factors
% count levels for each factor
for i_f = 1:numel(f)
    nf(i_f) = numel(unique({s.(f{i_f})}));
end

if isempty(f)
    % then if there is only one factor one condition, s.cond == 1
    for i = 1:numel(s)
        s(i).cond = 1;
        s(i).condname = '';
    end
    s(1).nconds = 1;
else
    % number of conditions = product of all factor levels.
    conds = 1:prod(nf);
    if numel(nf) > 1% if more than one factor
        % we reshape to create a conds matrix with the right dimensions
        conds = reshape(conds,nf);
        %conds = permute(conds,[numel(f):-1:1]);
    end
    % go find condition number for any combination of dimensions
    for i = 1:numel(s)
        str = 'conds(';
        strn = '';
        for i_f = 1:numel(f)
            strn = [strn f{i_f} '(' num2str(s(i).([f{i_f} 'idx'])) ')'];
            str = [str num2str(s(i).([f{i_f} 'idx'])) ];
            if i_f ~= numel(f)
                str = [str ', '];
            else
                str = [str ');'];
            end
        end
        % enter it as condition for each s.
        s(i).cond   = eval(str);
        s(i).condname = strn;
    end
    s(1).nconds = prod(nf);
end


