function ok = write_table(fname,txt)

% ok = write_table(fname,txt)
% write cell array of strings txt as text to disk under fname.
% 
% txt should be no more than 2D

if ndims(txt) > 2
    error('cell array of text to write should not be more than 2D')
end

fid = fopen(fname,  'w');
if fid == -1
    error('Unable to open file. Check file permissions')
end

for i = 1:size(txt,1)
    for j = 1:size(txt,2)
        if isempty(txt{i,j})
            fprintf(fid,'NaN');
        elseif isnumeric(txt{i,j}) || islogical(txt{i,j})
            fprintf(fid,'%g',txt{i,j});
        elseif iscell(txt{i,j})
            fprintf(fid,'%s',txt{i,j}{1});
        else
            fprintf(fid,'%s',txt{i,j});
        end
        if j ~= size(txt,2)
            fprintf(fid,'\t');
        end
    end
    fprintf(fid,'\n');
end

fclose(fid);

ok = 1;
