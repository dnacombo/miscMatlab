function dd = repflipped(d)

if not(isvector(d))
    error('need vector input')
end

s = size(d);
dd = [d(:);flipud(d(:))];
if s(2)>1
    dd = dd';
end