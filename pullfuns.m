function [funs, txtfuns] = pullfuns(f,dowrite)

if not(exist('f','var'))
    f = 'eeg_SASICA.m';
end
if not(exist('dowrite','var'))
    dowrite = 0;
end


txt = readtext(f,'\n',[],[],'textual');

funs = regexpcell(txt,'^\s*function');
comments = regexpcell(txt,'^\s*%');
empty = find(cellfun(@isempty,txt));
commentsorempty = union(comments,empty);

funnames = regexp(txt(funs),'^\s*function.*=\s*(\w+).*','tokens');
funnames(emptycells(funnames)) = regexp(txt(funs(emptycells(funnames))),'^\s*function.*?(\w+).*','tokens');
funnames = cellfun(@(x)x{1}{1},funnames,'uniformoutput',0);

for ifun = 1:numel(funs)
    funs(ifun) = funs(ifun)-1;
    while funs(ifun) > 0 && any(funs(ifun) == commentsorempty)
        funs(ifun) = funs(ifun) - 1;
    end
    funs(ifun) = funs(ifun) +1;
    while any(funs(ifun) == empty)
        funs(ifun) = funs(ifun)+1;
    end
end
funs(end+1) = numel(txt);
for ifun = 1:numel(funs)-1
    txtfuns{ifun} = txt(funs(ifun):funs(ifun+1)-1);
end

if not(dowrite)
    return
end

if not(isdir('private'))
    mkdir('private')
end

for ifun = 1:numel(txtfuns)
    
    fid = fopen(fullfile('private',[funnames{ifun},'.m']),'wt');
    for i_t = 1:numel(txtfuns{ifun})
        fprintf(fid,'%s\n', txtfuns{ifun}{i_t});
    end
    fclose(fid);

end
    
    
