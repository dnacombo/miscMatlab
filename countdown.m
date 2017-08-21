function countdown(seconds,step)

% countdown(seconds)
% display a count down of seconds in the command window
if not(exist('step','var'))
    step = .01;
end
tic
n = 0;
try
    while toc < seconds
        pause(step)
        fprintf(repmat('\b',1,n))
        n = fprintf('%g',round(seconds - toc));
    end
    fprintf(repmat('\b',1,n))
catch
    fprintf('\n     User abort...\n')
end


