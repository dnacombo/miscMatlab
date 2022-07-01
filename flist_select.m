function [list, sel] = flist_select(list,varargin)

% list = flist_select(list,field,value,field2,value2, ...)
% 
% select elements of a structure based on value of fields.
% 
% input:
%       list:   a vector structure array. Typically describing a list of
%               items (directory listing) with various attributes stored in
%               several fields
%    following arguments come in pairs:
%       field:  a string for the name of a field
%       value:  a target value for that field
%
% list = flist_select(list,field,value, 'fun', fun, ...)
% 
%   additionally apply the function fun (a function handle) to field-value
%   pairs
%
% example: flist_select(list,'size',19000,'fun',@gt)
%       will select elements of list that have a size field greater than
%       19000
%
% 
% list = flist_select(list,field,value, 'inv', ...)
% 
%   invert selection.
%
%

% Maximilien Chaumon 2017

% parse arguments
todel = [];
inv = 0;
fun = {};
for iv= 1:2:numel(varargin)
    if strcmp(varargin{iv},'fun')
        fun{end+1} = varargin{iv+1};
        todel(end+1:end+2) = [iv iv+1];
    elseif strcmp(varargin{iv},'inv')
        inv = 1;
        todel(end+1) = [iv];
    end
end
varargin(todel) = [];
if isempty(fun)
    fun(1:numel(varargin)/2) = repmat({[]},numel(varargin)/2,1);
end

% scan fields
sel = true(size(list));
for iv = 1:2:numel(varargin)
    if isempty(varargin{iv+1})
        continue
    end
    % depending on the type of data in each field
    if isempty(fun{(iv+1)/2})
        if isnumeric(list(1).(varargin{iv}))
            fun{(iv+1)/2} = @eq;
        elseif ischar(list(1).(varargin{iv}))
            if strncmp(varargin{iv+1},'~',1)
                varargin{iv+1}(1) = [];
                fun{(iv+1)/2} = @(x,y)isempty(regexp(x,y, 'once'));
            else
                fun{(iv+1)/2} = @(x,y)~isempty(regexp(x,y, 'once'));
            end
        end
    end
    for i = 1:numel(list)
        if ~isempty([list(i).(varargin{iv})])
            sel(i) = sel(i) & fun{(iv+1)/2}([list(i).(varargin{iv})],varargin{iv+1});
        else
            sel(i) = false;
        end
    end
end
if inv
    if islogical(sel)
        sel = ~ sel ;
    else
        nusel = 1:numel(list);
        nusel(sel) = [];
        sel = nusel;
    end
end

list = list(sel);









