function out = joinstr(in,delim)

if not(exist('delim','var'))
    delim = '-';
end

out = strjoin(num2cellstr(in),delim);