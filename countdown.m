function countdown(seconds)

% display a count down of seconds in the command window

tic
n = 0;
try
    while toc < seconds
        pause(.01)
        fprintf(repmat('\b',1,n))
        n = fprintf('%g',round(seconds - toc));
    end
    fprintf(repmat('\b',1,n))
catch
    fprintf('\n     User abort...\n')
end


