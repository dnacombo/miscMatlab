
figure(904);clf

p = panel();
p.pack({.2 .8})
p(1).pack('h',[.4 .2 .2 .2])
p(1,1).select()
for i = 1:3
    p(1,i+1).select();
end

p(2).pack('h',3)
p(2).de.marginright = 20;% for each freq band
for i = 1:3
    p(2,i).pack('v',2)
    p(2,i,1).pack('v',{.8 []})
    p(2,i,1,1).select()
    colorbar
    p(2,i,1,1).marginbottom = 0;
    p(2,i,1,2).select()
    p(2,i,1,2).margintop = 0;
end
