function goto(where)

wherenow = pwd;
if strncmp(where,'home',4)
    if numel(where > 4)
        cdhome(where(5:end));
    else
        cdhome(where);
    end
else
    cd(where)
end
setpref('goto','where',wherenow)

