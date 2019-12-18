function redisp(txt)

% disp(txt) after deleting text previously displayed with this function.

persistent nRedisp
if isempty(nRedisp)
    nRedisp = 0;
end
if not(exist('txt','var'))
    nRedisp = 0;
    return
end

if isnumeric(txt)
    txt = num2str(txt);
end
if exist('txt','var')
    if isnumeric(txt)
        txt = num2str(txt);
    end
    fprintf(repmat('\b',1,nRedisp));
    nRedisp = fprintf(txt);
end