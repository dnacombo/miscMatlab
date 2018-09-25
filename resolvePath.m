function fullpath = resolvePath(filename)

% fullpath = resolvePath(filename)
% 

if strfind(filename,'~') == 1
    filename = strrep(filename,'~',char(java.lang.System.getProperty('user.home')));
end
file=java.io.File(filename);
if file.isAbsolute()
    fullpath = filename;
else
    fullpath = char(file.getCanonicalPath());
end
