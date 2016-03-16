function v = struct2vararg(s,tag)
% v = struct2vararg(s,tag)
% 
% translate a scalar structure into a sequence of varargin 'name', value
% pairs.
% substructure fields are identified by using underscores (if tag is
% provided, another character can be used) in the name strings.
% 
% ex: s.name = 'toto';
%     s.size= 55;
%     s.hair= struct('style','cool','color','blue');
%   v = struct2vararg(s)
% v = 
%     'name'    'toto'    'size'    [55]    'hair_style'    'cool'    'hair_color'    'blue'
%

if not(exist('tag','var'))
    tag = '';
end
if numel(s) ~= 1
    error('input should be 1x1 structure array')
end

fn = fieldnames(s);
v = {};
for i_f = 1:numel(fn)
    if isstruct(s.(fn{i_f}));
        if not(isempty(tag))
            v = [v struct2vararg(s.(fn{i_f}),[tag '_' fn{i_f}])];
        else
            v = [v struct2vararg(s.(fn{i_f}),[fn{i_f}])];
        end
        continue
    end
    if not(isempty(tag))
        v{end+1} = [tag '_' fn{i_f}];
    else
        v{end+1} = [fn{i_f}];
    end
    v{end+1} = s.(fn{i_f});
end
