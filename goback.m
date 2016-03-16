function goback

where = getpref('goto','where');
wherenow = pwd;
cd(where)
setpref('goto','where',wherenow);

