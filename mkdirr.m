function mkdirr(d)

% recursive mkdir
%
% mkdirr(d)
%

try 
    mkdir(d)
catch
    mkdirr(fileparts(d));
end
    

