function goback

where = getpref('goto','where',cd);
wherenow = pwd;
cd(where)
setpref('goto','where',wherenow);

