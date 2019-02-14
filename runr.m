function output = runr(filename,varargin)

% output = runr
% output = runr(filename, ...)
%
% Scan the currently executing file (or the file provided in filename) for
% the string "% rchunk" copy the following commented lines (hereafter named
% chunk) to an R script run it and return the output as a cell array of
% strings 
%
% inputs: 
%   filename: a filename (usually the mfile that runr is called from).
%               if no filename is provided, runr will try to guess where
%               it's being called from...
%   pairs of 'parameter', value arguments:
%       num:        If there are several R chunks, they can be run by number
%       name:       If there are several R chunks, they can be run by name.
%                   the name of the R chunk to run is defined inline with 
%                       % rchunk name
%       trimbefore: Exclude all lines of the output until the first
%                   occurrence of the string in trimbefore (default '>' at
%                   the beginning of a line)
%       trimafter:  Exclude all lines of the output after the last
%                   occurrence of the string in trimafter (default '>' at the
%                   beginning of a line).
%       dir:        set working directory prior to running chunk
%
% example:          in mfile "testit.m"
% 
% load('fisheriris')
% t = table(meas(:,1),meas(:,2),meas(:,3),meas(:,4),species);
% writetable(t,'test.csv')
% % rchunk
% % 
% % a <- read.csv('test.csv')
% % fit <- lm(Var1 ~ Var2, data=a)
% % summary(fit)
% runr
% 
% example:          in mfile "testitagain.m"
% 
% load('fisheriris')
% t = table(meas(:,1),meas(:,2),meas(:,3),meas(:,4),species);
% writetable(t,'test.csv')
% % rchunk
% % 
% % a <- read.csv('test.csv')
% % fit <- lm(Var1 ~ Var2, data=a)
% % summary(fit)
% runr('testitagain.m','trimbefore','','trimafter','')
% 

if ~exist('filename','var') || isempty(filename)
    s = dbstack('-completenames');
    if numel(s) == 1
        error('Please run this from within an mfile or provide filename')
    end
    filename = s(2).file;
end

def = [];
def.name = '';
def.num = [];
def.trimbefore = '^>';
def.trimafter = '^>';
def.dir = cd;

cfg = vararg2cfg(varargin,def,1);

txt = readtext(filename,'\n',[],[],'textual');

starts = find(cellfun(@(x)~isempty(x),regexp(txt,'% *rchunk')));
if isempty(starts)
    error(sprintf(['No R code found in ' filename '\nThere should be a line containing ''rscript starthere'' somewhere in that file']));
end
names = regexp(txt(starts),'% *rchunk(.*)','tokens');
names = cellfun(@(x)strtrim(x{1}{1}),names,'uniformoutput',0);

if not(isempty(cfg.name))% run by name
    torun = regexpcell(names,cfg.name);
elseif not(isempty(cfg.num))% run by num
    torun = cfg.num;
else
    torun = 1;
end
iline = starts(torun)+1;
start = iline;
txt{iline} = strtrim(txt{iline});
while ~isempty(txt{iline}) && strcmp(txt{iline}(1),'%')
    iline = iline+1;
    txt{iline} = strtrim(txt{iline});
end
stop = iline-1;

script = txt(start:stop);
script = cellfun(@(x) x(2:end),script,'uniformoutput',0);

fid = fopen('tmp.R','wt');
fprintf(fid,'setwd("%s")\n',cfg.dir);
for i = 1:numel(script)
    fprintf(fid,'%s\n',script{i});
end
fclose(fid);

!R CMD BATCH --no-save --no-restore tmp.R

output = readtext('tmp.Rout','\n',[],[],'textual');

if ~isempty(cfg.trimbefore)
    starts  = find(cellfun(@(x)~isempty(x),regexp(output,cfg.trimbefore)));
    if not(isempty(starts))
        output  = output(starts(1):end);
    end
end
if ~isempty(cfg.trimafter)
    stop    = find(cellfun(@(x)~isempty(x),regexp(output,cfg.trimafter)));
    if not(isempty(stop))
        output  = output(1:stop(end));
    end
end

function cfg = vararg2cfg(vararg, def,keepempty)

% cfg = vararg2cfg(vararg, def)
% cfg = vararg2cfg(vararg, def,keepempty)
% convert cellarray vararg to a cfg structure, setting fields of cfg with
% default values defined in structure def. 
% vararg should either be a 1x1 cell with a cfg structure or a cell array
% of N elements with N/2 pairs of 'param',value pairs.
% if keepempty is provided and true, then empty fields in s will be left
% empty. otherwise they are populated with default values. default is
% false.

if not(exist('keepempty','var'))
    keepempty = 0;
end


if numel(vararg) == 1
    cfg = setdef(vararg{1},def,keepempty);
elseif ~rem(numel(vararg),2)
    cfg = setdef(vararg2struct(vararg),def,keepempty);
else
    error('arguments in vararg should come in pairs')
end



function idx = regexpcell(c,pat, cmds)

% idx = regexpcell(c,pat, cmds)
%
% Return indices idx of cells in c that match pattern(s) pat (regular expression).
% Pattern pat can be char or cellstr. In the later case regexpcell returns
% indexes of cells that match any pattern in pat.
%
% cmds is a string that can contain one or several of these commands:
% 'inv' return indexes that do not match the pattern.
% 'ignorecase' will use regexpi instead of regexp
% 'exact' performs an exact match (regular expression should match the whole strings in c).
% 'all' (default) returns all indices, including repeats (if several pat match a single cell in c).
% 'unique' will return unique sorted indices.
% 'intersect' will return only indices in c that match ALL the patterns in pat.
% 
% v1 Maximilien Chaumon 01/05/09
% v1.1 Maximilien Chaumon 24/05/09 - added ignorecase
% v2 Maximilien Chaumon 02/03/2010 changed input method.
%       inv,ignorecase,exact,combine are replaced by cmds

narginchk(2,3)
if not(iscellstr(c))
    error('input c must be a cell array of strings');
end
if nargin == 2
    cmds = '';
end
if not(isempty(regexpi(cmds,'inv', 'once' )))
    inv = true;
else
    inv = false;
end
if not(isempty(regexpi(cmds,'ignorecase', 'once' )))
    ignorecase = true;
else
    ignorecase = false;
end
if not(isempty(regexpi(cmds,'exact', 'once' )))
    exact = true;
else
    exact = false;
end
if not(isempty(regexpi(cmds,'unique', 'once' )))
    combine = 2;
elseif not(isempty(regexpi(cmds,'intersect', 'once' )))
    combine = 3;
else
    combine = 1;
end

if ischar(pat)
    pat = cellstr(pat);
end

if exact
    for i_pat = 1:numel(pat)
        pat{i_pat} = ['^' pat{i_pat} '$'];
    end
end
for i_pat = 1:length(pat)
    if ignorecase
        trouv = regexpi(c,pat{i_pat}); % apply regexp on each pattern
    else
        trouv = regexp(c,pat{i_pat}); % apply regexp on each pattern
    end
    idx{i_pat} = find(not(cellfun('isempty',trouv)));
end
if isempty(pat)
    idx = {};
end
makevector = @(x)(x(:));
switch combine
    case 1
        idx = makevector([idx{:}]);
    case 2
        idx = unique([idx{:}]);
    case 3
        for i_pat = 2:length(pat)
            idx{1} = intersect(idx{1},idx{i_pat});
        end
        idx = idx{1};
end
if inv % if we want to invert result, then do so.
    others = 1:numel(trouv);
    others(idx) = [];
    idx = others;
end

function s = vararg2struct(v,tag)

% s = vararg2struct(v,tag)
% 
% translate a sequence of varargin 'name', value pairs into a structure.
% substructure fields can be defined by using underscores (if tag is
% provided, another character can be used)
% 
% ex:   v = {'name','toto','size',55,'hair_style','cool','hair_color','blue'}
%       s = vararg2struct(v)
% s = 
%     name: 'toto'
%     size: 55
%     hair: [1x1 struct]
% s.hair
% ans = 
%     style: 'cool'
%     color: 'blue'
% 

if not(exist('tag','var'))
    tag = '_';
end
s = struct;
f = regexp(v(1:2:end),['[^'  regexptranslate('escape',tag) ']*'],'match');
for i_f = 1:numel(f)
    str = 's';
    for i_ff = 1:numel(f{i_f})
        str = [str '.' f{i_f}{i_ff}];
    end
    str = [str ' = v{i_f*2};'];
    eval(str);
end
function s = setdef(s,d,keepempty)
% s = setdef(s,d)
% s = setdef(s,d,keepempty)
% Merges the two structures s and d recursively.
% Adding the default field values from d into s when not present or empty.
% Keeping order of fields same as in d
% if keepempty is provided and true, then empty fields in s will be left
% empty. otherwise they are populated with default values. default is
% false.
if not(exist('keepempty','var'))
    keepempty = 0;
end

if isstruct(s) && not(isempty(s))
    if not(isstruct(d))
        fields = [];
    else
        fields = fieldnames(d);
    end
    for i_f = 1:numel(fields)
        if isfield(s,fields{i_f})
            s.(fields{i_f}) = setdef(s.(fields{i_f}),d.(fields{i_f}),keepempty);
        else
            [s.(fields{i_f})] = d.(fields{i_f});
        end
    end
    if not(isempty(fields))
        fieldsorig = setdiff(fieldnames(s),fields);
        s = orderfields(s,[fields; fieldsorig]);
    end
elseif not(isempty(s)) || keepempty
    s = s;
elseif isempty(s)
    s = d;    
end