function redisp(txt)

% disp(txt) after deleting text previously displayed with this function.

persistent nRedisp
if isempty(nRedisp)
    nRedisp = 0;
end
if isnumeric(txt)
    txt = num2str(txt);
end
if exist('txt','var')
    fprintf(repmat('\b',1,nRedisp));
    nRedisp = fprintf(txt);
else
    nRedisp = 0;
end