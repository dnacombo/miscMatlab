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
%       trimfrom:   Exclude all lines of the output until the first
%                   occurrence of the string in trimfrom (default '>' at
%                   the beginning of a line)
%       trimto:     Exclude all lines of the output after the last
%                   occurrence of the string in trimto (default '>' at the
%                   beginning of a line).
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
% runr('testitagain.m','trimfrom','','trimto','')
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
def.trimfrom = '^>';
def.trimto = '^>';

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
for i = 1:numel(script)
    fprintf(fid,'%s\n',script{i});
end
fclose(fid);

!R CMD BATCH tmp.R

output = readtext('tmp.Rout','\n',[],[],'textual');

if ~isempty(cfg.trimfrom)
    starts  = find(cellfun(@(x)~isempty(x),regexp(output,cfg.trimfrom)));
    if not(isempty(starts))
        output  = output(starts(1):end);
    end
end
if ~isempty(cfg.trimto)
    stop    = find(cellfun(@(x)~isempty(x),regexp(output,cfg.trimto)));
    if not(isempty(stop))
        output  = output(1:stop(end));
    end
end

