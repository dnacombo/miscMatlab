function defifnotexist(var,def)

% defifnotexist(var,def)
%
% set var in caller workspace to be def if it doesn't exist or is empty
% 



if evalin('caller',['~exist(''' var ''',''var'') || isempty(' var ')'])
    assignin('caller',var,def);
end
