function str = s2hms(t)

% str = s2hms(t)
% convert time in seconds to hours minutes and seconds
t = t(:);
d = floor(t/(3600*24));
t = t-d*3600*24;
h = floor((t)/3600);
t = t-h*3600;
m = floor((t)/60);
t = t-m*60;
s = t;
if numel(t)==1
    str = tostr(d,h,m,s);
else
    str = cell(numel(t),1);
    for i = 1:numel(t)
        str{i} = tostr(d(i),h(i),m(i),s(i));
    end
end


function str = tostr(d,h,m,s)
    if d > 0
        str = sprintf('%02dd:%02dh:%02dm:%02gs',d,h,m,s);
    elseif h > 0
        str = sprintf('%02dh:%02dm:%02gs',h,m,s);
    elseif m > 0
        str = sprintf('%02dm:%02gs',m,s);
    else
        str = sprintf('%02gs',s);
    end

