function output = findtextinmfiles(text,varargin)

% output = findtextinmfiles(text,varargin)
% list files where text string is found
%
% findtextinmfiles(text)
% find string text in all mfiles in the current directory.
%
% findtextinmfiles(text, ... 'key', value...)
%       optional 'key', value pairs:
%                       'where', where : operate from directory.
%                       'ignorecase', 0 or 1: ignore case if == 1
%                       'replace', newtext: replace text by string newtext
%                       'backup', 0 or 1: do not create .bak files when
%                       replacing (default = 1)
%                       'filematch', pattern: scan only files matching
%                                             pattern (regexp) (can
%                                             search for other than .m
%                                             files)
%                       'exclude', pattern: file name to exclude 
%                       'recurse', boolean: whether to recurse through
%                                           subdirectories or not (defaults
%                                           to false)
%
replace = [];
setdefvarargin(varargin,'where',cd,'ignorecase',0,'replace',NaN,'filematch','.*\.m$','exclude','','backup',1,'recurse',0,'dispresults',1);

if isstr(backup)
    backup = str2num(backup);
end

if ischar(recurse)
    recurse = str2num(recurse);
end
if recurse
    fs = rdir(fullfile(where,'**', filesep,'*'));
else
    fs = dir(where);
    [fs.name] = rep2struct(cellstrjoin({fs.folder},{fs.name},filesep));
    fs = rmfield(fs,'folder');
end
if not(isempty(exclude))
    fs = fs(regexpcell({fs.name},exclude,'inv'));
end
if not(isempty(filematch))
    fs = fs(regexpcell({fs.name},filematch));
end
output = [];
for i_f = 1:numel(fs)
    if isdir(fs(i_f).name)
        continue
    end
    txt = readtext(fs(i_f).name,'\n',[],[],'textual');
    line = regexpcell(txt,text,fastif(ignorecase,'ignorecase',''));
    if not(isempty(line))
        output(end+1).path = fs(i_f).name;
        output(end).line = [];
        for i = 1:numel(line)
            output(end).line = [output(end).line line(i)];
        end
    end
    if (not(all(isnan(replace))) || isempty(replace)) && not(isempty(line))
        if ignorecase
            txt = regexprep(txt,text,replace,'ignorecase');
        else
            txt = regexprep(txt,text,replace);
        end
        if backup 
            bakf = strrep(fs(i_f).name,myfileparts(fs(i_f).name,'e'),'.bak');
            ibak = 0;
            while exist(bakf,'file')
                ibak = ibak+1;
                bakf = regexprep(bakf,'.bak\d*',['.bak' num2str(ibak)]);
            end
            copyfile(fs(i_f).name,bakf);
        end
        fid = fopen(fs(i_f).name,'wt');
        for i_t = 1:numel(txt)
            fprintf(fid,'%s\n', txt{i_t});
        end
        fclose(fid);
    end
end

if ~isempty(output)
    if dispresults
        if usejava('jvm')
            out = [];
            h = [];
            for i=1:length(output)
                [p f e] = fileparts(output(i).path);
                fl = strrep(output(i).path,'''','''''');
                l = output(i).line;
                out = [out sprintf(['<a href="matlab: %s">run</a> %s%s<a href="matlab:edit(''%s'')">%s%s</a> at line '], f, p, filesep, fl, f, e)];
                for il = 1:numel(l)
                    out = [out sprintf('<a href="matlab:opentoline(''%s'',%g,0)">%g</a> ', fl,l(il),l(il)) ];
                end
                out = strrep(out,'\','\\');
                out = [out '\n'];
                fprintf(char(out));
                out = [];
            end% for
            close(h)
        else
            disp(char(output.path));
        end% if
    end
else
    disp(['''' text '''' ' not found.'])
end% if
if nargout == 0
    clear output
end


% fastif() - fast if function.
%
% Usage:
%  >> res = fastif(test, s1, s2);
%
% Input:
%   test   - logical test with result 0 or 1
%   s1     - result if 1
%   s2     - result if 0
%
% Output:
%   res    - s1 or s2 depending on the value of the test
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
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

function res = fastif(s1, s2, s3);

if s1
	res = s2;
else
	res = s3;
end;
return;
