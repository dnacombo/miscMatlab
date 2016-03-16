function varargout = whichx(inputstr,varargin)
%WHICHX   file search within matlab search path using wildcards
%   For example, WHICHX *.m lists all the M-files in the matlab search paths.
%
%   D = WHICHX('*.m') returns the results in an M-by-1
%   structure with the fields: 
%       name  -- filename
%       date  -- modification date
%       bytes -- number of bytes allocated to the file
%       isdir -- 1 if name is a directory and 0 if not%
%       path  -- directory
%   
%   See also  WHICH, DIR, MATLABPATH.

% Autor: Elmar Tarajan [MCommander@gmx.de]
% Version: 2.0
% Date: 2005/11/18 03:53:05

if nargin == 0
   help('whichx')
   return
end% if
error(nargchk(0,2,nargin))
output = [];
if ispc
   tmp = eval(['{''' strrep(matlabpath,';',''',''') '''}']);
elseif isunix
   tmp = eval(['{''' strrep(matlabpath,':',''',''') '''}']);
else
   error('platform not supported')
end% if
isin = find(strcmpi(tmp,cd), 1);
if isempty(isin)
   tmp = [tmp {cd}];
end% if

for i=tmp
   tmp = dir(fullfile(char(i),inputstr));
   if ~isempty(tmp)
      for j=1:length(tmp)
         tmp(j).path = fullfile(char(i),tmp(j).name);
      end% for
      output = [output;tmp];
   end% if
end% for
%
if nargout==0
   if ~isempty(output)
      if usejava('jvm')
         out = [];
         h = [];
         for i=1:length(output)
            %
            if ~mod(i,200)
               if ishandle(h)
                  waitbar(i/length(output),h,sprintf('%.0f%%',(i*100)/length(output)))
               elseif isempty(h)
                  h = waitbar(i/length(output),'','Name',sprintf('Please wait...%d files are found.',length(output)));
               else
                  return
               end% if
               drawnow
            end% if
            %
            [p f e] = fileparts(output(i).path);
            fl = strrep(output(i).path,'''','''''');
            switch lower(e)
               case ''
                  out = [out sprintf('    %s\n', output(i).path)];               
               case '.m'
                  out = [out sprintf(['<a href="matlab: %s">run</a> %s%s<a href="matlab:edit(''%s'')">%s%s</a>\n'], f, p, filesep, fl, f, e)];
               case {'.asv' '.cdr' '.rtw' '.tmf' '.tlc' '.c' '.h' '.ads' '.adb'}
                  out = [out sprintf(['    %s%s<a href="matlab:open(''%s'')">%s%s</a>\n'], p, filesep, fl, f, e)];
               case '.mat'
                  out = [out sprintf(['    %s%s<a href="matlab:load(''%s'');disp([''%s loaded''])">%s%s</a>\n'], p, filesep, fl, fl, f, e)];
               case '.fig'
                  out = [out sprintf(['    %s%s<a href="matlab:guide(''%s'')">%s%s</a>\n'], p, filesep, fl, f, e)];
               case '.p'
                  out = [out sprintf(['<a href="matlab: %s">run</a> %s\n'], f, fl)];
               case '.mdl'
                  out = [out sprintf(['    %s%s<a href="matlab:open(''%s'')">%s%s</a>\n'], p, filesep, fl, f, e)];
               otherwise
                  out = [out sprintf(['    %s%s<a href="matlab:try;winopen(''%s'');catch;disp(lasterr);end">%s%s</a>\n'], p, filesep, fl, f,e)];                  
            end% switch
         end% for
         close(h)
         disp(char(out));
      else
         disp(char(output.path));
      end% if
   else
      disp(['''' inputstr '''' ' not found.'])
   end% if
else
   varargout{1} = output;
end% if