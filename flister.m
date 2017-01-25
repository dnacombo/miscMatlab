function [varargout] = flister(re,varargin)

% [filenames, factnames,factidx,factlevelnames] = flister(re)
% [fstruct] = flister(re,'key',val, ...)
% 
% This function lists all files matching re in the current directory and
% subdirectories
% re is of the type 'S(?<suj>.*)_(?<Noise>Yes|No)Noise_(?<SDT>Hit|Miss)\.set$'
% (see regular expressions, named tokens)
%
% optional input key val pairs : 
%           'exclude', str  : file names matching regexp str will be
%                            excluded from the list 
%           'dir',str       : root directory where to search for the files 
%           'isdir',boolean : whether or not listed files should be
%                           directories (defaults to NaN to ignore this filter)
%           'list',cellstr  : any list to process with flister (instead of
%                           listing files)
%           'rename',str    : renaming pattern, using tokens defined in re,
%                           passed to regexprep
%           'isdir',boolean : whether the listed names should be
%                           directories or files
%           'eval', str     : a command to be evaluated on each element of
%                           output structure. e.g. 'pop_loadset(name)' will
%                           run pop_loadset with the value of the field
%                           called name in the output structure for each
%                           element of that structure and store the result
%                           in fstruct.eval. The names of all fields of the
%                           output structure are valid. One and only one
%                           output to the eval command is expected.
%           'evalfname', str : fieldname for the eval result in fstruct.
%           'sortfields', cellstr : fields to sort output structure on
%                           (defaults to all tokens found in re. set to
%                           empty to force not sorting)
%
% outputs:
%           filenames: cell of filenames with absolute path
%           factnames: cell: all the factor names of the named tokens of re
%           factlevelnames cell: the level names of each factor
%           factidx:   cell: for each factor, the level to which each file belongs
% output method 2:
%           f: 	structure with fields name (name of the file), and each of
%               the factor names with the corresponding level to which the file belongs.

% v 1 Max: Basic functionality
% v 1.1 Max: added list input method 01/06/2015
% v 1.2 Max: added eval functionality 03/03/2016

if numel(varargin) == 1 && isstruct(varargin{1})
    varargin = struct2vararg(varargin{1});
end
g = finputcheck( varargin, ...
    {
    'exclude'   { 'string';'cell' }    []   ''
    'dir' { 'string'}    []   cd
    'isdir' {'integer'} [NaN 0 1] NaN
    'list' {'cell'} {''} {}
    'rename' {'string'} [] ''
    'eval' '' [] ''
    'evalfname' '' [] 'eval'
    'sortfields' {'string';'cell'} [] 'all'
    'cmds' {'string'} [] ''
    });
if ischar(g)
    error(g);
end
if ischar(g.sortfields)
    g.sortfields = {g.sortfields};
end
rootdir = g.dir;
% we'll first list
% everything and then filter out.
if isempty(g.list)
    [dum,dum,all] = dirr(rootdir,'name');
    if isempty(all)
        disp('No files found')
        varargout{1} = [];
        return
    end
else
    all = g.list;
end
filenames = all(regexpcell(all,re,g.cmds));
if isempty(filenames)
    disp('All files filtered out');
    varargout{1} = [];
    return
end
if not(isempty(g.exclude))
    filenames(regexpcell(filenames,g.exclude)) = [];
end
if not(isnan(g.isdir))
    aredir = cellfun(@isdir,filenames);
    if g.isdir
        filenames = filenames(aredir);
    else
        filenames = filenames(~aredir);
    end
end
% name unnamed tokens with capital letters
i = 65;
while ~isempty(regexp(re,'\(([^?].*)\)', 'once'))
    re = regexprep(re,'\(([^?].*)\)',['(?<' char(i) '>$1)'],'once');
    i = i+1;
end

% match re to filenames and extract tokens
names = regexp(filenames,re,'names');
if isempty(names) || numel(fieldnames(names{1})) == 0
    % disp('Warning: Could not find tokens in regular expression')
    factnames = {};
    f = struct('name',filenames);
else
    for i = 1:numel(names)
        f(i) = names{i};
    end
    factnames = fieldnames(f);
    [f.name] = filenames{:};
end

for i = 1:numel(factnames)
    factlevelnames{i} = unique({f.(factnames{i})});
    finder = regexptranslate('escape',{f.(factnames{i})});
    empty = cellfun(@isempty,factlevelnames{i});
    if any(empty)
        factlevelnames{i}{empty} = '{{empty}}';
        empty = cellfun(@isempty,finder);
        finder(empty) = {'{{empty}}'};
    end
    factidx{i} = regexpcell(factlevelnames{i},finder,'exact');
end
if not(isempty(factnames))
    for i = 1:numel(filenames)
        for j = 1:numel(factnames)
            f(i).([factnames{j} 'idx']) = factidx{j}(i);
        end
    end
end
if ~isempty(g.sortfields) && strcmp(g.sortfields{1},'all')
    g.sortfields = factnames;
end
wrn = warning('off','sortstruct:sortallfields');
f = sortstruct(f,g.sortfields);
warning(wrn);

if not(isempty(g.rename))
    nf = regexprep({f.name},re,g.rename);
    cellfun(@(x,y)fprintf('%s --> %s\n',x,y),{f.name},nf)
    r = input('Is this ok? (y/n)','s');
    if strcmpi(r,'y')
        for i_f = 1:numel(f)
            if not(isdir(fileparts(nf{i_f})))
                mkdir(fileparts(nf{i_f}));
            end
            movefile(f(i_f).name,nf{i_f});
        end
    end
end

if not(isempty(g.eval))
    for i = 1:numel(f)
        struct2ws(f(i));
        if isa(g.eval,'function_handle')
            f(i).(g.evalfname) = g.eval(f(i));
        else
            f(i).(g.evalfname) = eval(g.eval);
        end
    end
end
if nargout > 1
    varargout{1} = filenames;
    varargout{2} = factnames;
    varargout{3} = factidx;
    varargout{4} = factlevelnames;
elseif nargout == 1
    varargout{1} = f;
else
    for i = 1:numel(f)
        if isdir(f(i).name)
            continue
        end
        [p fn e] = fileparts(f(i).name);
        fl = strrep(p,'''','''''');
        switch e
            case '.m'
                out = sprintf(['<a href="matlab: %s">run</a> %s%s<a href="matlab:edit(''%s'')">%s%s</a>'], fn, p, filesep, f(i).name, fn, e);
            case '.mat'
                out = sprintf(['    %s%s<a href="matlab:load(''%s'')">%s%s</a>'], p, filesep, f(i).name, fn, e);
            otherwise
                out = sprintf(['    %s%s%s%s'], p, filesep, fn, e);
        end
        out = strrep(out,'\','\\');
        out = [out '\n'];
        fprintf(char(out));
    end% for
end
    
 
    
% finputcheck() - check Matlab function {'key','value'} input argument pairs
%
% Usage: >> result = finputcheck( varargin, fieldlist );
%        >> [result varargin] = finputcheck( varargin, fieldlist, ... 
%                                              callingfunc, mode, verbose );
% Input:
%   varargin  - Cell array 'varargin' argument from a function call using 'key', 
%               'value' argument pairs. See Matlab function 'varargin'.
%               May also be a structure such as struct(varargin{:})
%   fieldlist - A 4-column cell array, one row per 'key'. The first
%               column contains the key string, the second its type(s), 
%               the third the accepted value range, and the fourth the 
%               default value.  Allowed types are 'boolean', 'integer', 
%               'real', 'string', 'cell' or 'struct'.  For example,
%                       {'key1' 'string' { 'string1' 'string2' } 'defaultval_key1'}
%                       {'key2' {'real' 'integer'} { minint maxint } 'defaultval_key2'} 
%  callingfunc - Calling function name for error messages. {default: none}.
%  mode        - ['ignore'|'error'] ignore keywords that are either not specified 
%                in the fieldlist cell array or generate an error. 
%                {default: 'error'}.
%  verbose     - ['verbose', 'quiet'] print information. Default: 'verbose'.
%
% Outputs:
%   result     - If no error, structure with 'key' as fields and 'value' as 
%                content. If error this output contain the string error.
%   varargin   - residual varagin containing unrecognized input arguments.
%                Requires mode 'ignore' above.
%
% Note: In case of error, a string is returned containing the error message
%       instead of a structure.
%
% Example (insert the following at the beginning of your function):
%	result = finputcheck(varargin, ...
%               { 'title'         'string'   []       ''; ...
%                 'percent'       'real'     [0 1]    1 ; ...
%                 'elecamp'       'integer'  [1:10]   [] });
%   if isstr(result)
%       error(result);
%   end
%
% Note: 
%   The 'title' argument should be a string. {no default value}
%   The 'percent' argument should be a real number between 0 and 1. {default: 1}
%   The 'elecamp' argument should be an integer between 1 and 10 (inclusive).
%
%   Now 'g.title' will contain the title arg (if any, else the default ''), etc.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 10 July 2002

% Copyright (C) Arnaud Delorme, CNL / Salk Institute, 10 July 2002, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [g, varargnew] = finputcheck( vararg, fieldlist, callfunc, mode, verbose )

	if nargin < 2
		help finputcheck;
		return;
	end;
	if nargin < 3
		callfunc = '';
	else 
		callfunc = [callfunc ' ' ];
	end;
    if nargin < 4
        mode = 'do not ignore';
    end;
    if nargin < 5
        verbose = 'verbose';
    end;
	NAME = 1;
	TYPE = 2;
	VALS = 3;
	DEF  = 4;
	SIZE = 5;
	
	varargnew = {};
	% create structure
	% ----------------
	if ~isempty(vararg)
        if isstruct(vararg)
            g = vararg;
        else
            for index=1:length(vararg)
                if iscell(vararg{index})
                    vararg{index} = {vararg{index}};
                end;
            end;
            try
                g = struct(vararg{:});
            catch
                vararg = removedup(vararg, verbose);
                try
                    g = struct(vararg{:});
                catch
                    g = [ callfunc 'error: bad ''key'', ''val'' sequence' ]; return;
                end;
            end;
        end;
	else 
		g = [];
	end;
	
	for index = 1:size(fieldlist,NAME)
		% check if present
		% ----------------
		if ~isfield(g, fieldlist{index, NAME})
			g = setfield( g, fieldlist{index, NAME}, fieldlist{index, DEF});
		end;
		tmpval = getfield( g, {1}, fieldlist{index, NAME});
		
		% check type
		% ----------
        if ~iscell( fieldlist{index, TYPE} )
            res = fieldtest( fieldlist{index, NAME},  fieldlist{index, TYPE}, ...
                           fieldlist{index, VALS}, tmpval, callfunc );
            if isstr(res), g = res; return; end;
        else 
            testres = 0;
            tmplist = fieldlist;
            for it = 1:length( fieldlist{index, TYPE} )
                if ~iscell(fieldlist{index, VALS})
                     res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                                           fieldlist{index, VALS}, tmpval, callfunc );
                else res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                                           fieldlist{index, VALS}{it}, tmpval, callfunc );
                end;
                if ~isstr(res{it}), testres = 1; end;
            end;
            if testres == 0,
                g = res{1};
                for tmpi = 2:length(res)
                    g = [ g 10 'or ' res{tmpi} ];
                end;
                return; 
            end;
        end;
	end;
    
    % check if fields are defined
	% ---------------------------
	allfields = fieldnames(g);
	for index=1:length(allfields)
		if isempty(strmatch(allfields{index}, fieldlist(:, 1)', 'exact'))
			if ~strcmpi(mode, 'ignore')
				g = [ callfunc 'error: undefined argument ''' allfields{index} '''']; return;
			end;
			varargnew{end+1} = allfields{index};
			varargnew{end+1} = getfield(g, {1}, allfields{index});
		end;
	end;


function g = fieldtest( fieldname, fieldtype, fieldval, tmpval, callfunc );
	NAME = 1;
	TYPE = 2;
	VALS = 3;
	DEF  = 4;
	SIZE = 5;
    g = [];
    
    switch fieldtype
     case { 'integer' 'real' 'boolean' 'float' }, 
      if ~isnumeric(tmpval) && ~islogical(tmpval)
          g = [ callfunc 'error: argument ''' fieldname ''' must be numeric' ]; return;
      end;
      if strcmpi(fieldtype, 'boolean')
          if tmpval ~=0 && tmpval ~= 1
              g = [ callfunc 'error: argument ''' fieldname ''' must be 0 or 1' ]; return;
          end;  
      else 
          if strcmpi(fieldtype, 'integer')
              if ~isempty(fieldval)
                  if (any(isnan(tmpval(:))) && ~any(isnan(fieldval))) ...
                          && (~ismember(tmpval, fieldval))
                      g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
                  end;
              end;
          else % real or float
              if ~isempty(fieldval) && ~isempty(tmpval)
                  if any(tmpval < fieldval(1)) || any(tmpval > fieldval(2))
                      g = [ callfunc 'error: value out of range for argument ''' fieldname '''' ]; return;
                  end;
              end;
          end;
      end;  
      
      
     case 'string'
      if ~isstr(tmpval)
          g = [ callfunc 'error: argument ''' fieldname ''' must be a string' ]; return;
      end;
      if ~isempty(fieldval)
          if isempty(strmatch(lower(tmpval), lower(fieldval), 'exact'))
              g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
          end;
      end;

      
     case 'cell'
      if ~iscell(tmpval)
          g = [ callfunc 'error: argument ''' fieldname ''' must be a cell array' ]; return;
      end;
      
      
     case 'struct'
      if ~isstruct(tmpval)
          g = [ callfunc 'error: argument ''' fieldname ''' must be a structure' ]; return;
      end;
      
      
     case '';
     otherwise, error([ 'finputcheck error: unrecognized type ''' fieldname '''' ]);
    end;

% remove duplicates in the list of parameters
% -------------------------------------------
function cella = removedup(cella, verbose)
% make sure if all the values passed to unique() are strings, if not, exist
%try
    [tmp indices] = unique(cella(1:2:end));
    if length(tmp) ~= length(cella)/2
        myfprintf(verbose,'Note: duplicate ''key'', ''val'' parameter(s), keeping the last one(s)\n');
    end;
    cella = cella(sort(union(indices*2-1, indices*2)));
%catch
    % some elements of cella were not string
%    error('some ''key'' values are not string.');
%end;    

function myfprintf(verbose, varargin)

if strcmpi(verbose, 'verbose')
    fprintf(varargin{:});
end;
