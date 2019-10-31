function mymkdir(d)

if iscellstr(d)
    for i = 1:numel(d)
        mymkdir(d{i})
    end
    return
end
if not(exist(d,'dir'))
    mkdir(d)
end

