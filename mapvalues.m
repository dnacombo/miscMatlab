function y = mapvalues(x,from,to)

% y = mapvalues(x,from,to)
%
% replace in x all elements that match from by to
%
% ex:
% mapvalues({'toto' 'tutu'},{'toto'},{'tata'})
% ans =
%   1×2 cell array
%     {'tata'}    {'tutu'}
%
% mapvalues(1:5,1:3,11:13)
% ans =
%     11    12    13     4     5
%

y = x;
if iscell(x)
    if iscellstr(x)
        for i = 1:numel(from)
            ii = strcmp(x , from(i));
            y(ii) = to(i);
        end
    else
        error('not implemented')
    end
else
    for i = 1:numel(from)
        ii = x == from(i);
        y(ii) = to(i);
    end
end