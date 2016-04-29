function ok = writethisbatch(matlabbatch,filename)

% ok = writethisbatch(matlabbatch,filename)
% 
% write an m file to regenerate matlabbatch.

narginchk(1,2);
if nargin == 1
    if not(ischar(matlabbatch))
        error('provide file name')
    end
    filename = [myfileparts(matlabbatch,'pf') '.m'];
end

if ischar(matlabbatch)
    matlabbatch = load(matlabbatch);
end
if isfield(matlabbatch,'matlabbatch')
    matlabbatch = matlabbatch.matlabbatch;
end

towrite = gencode(matlabbatch);
fid = fopen(filename,'wt');
if fid == -1
    error(['Could not open file ' filename]);
end

for i_w = 1:numel(towrite)
    status(i_w) = fprintf(fid,'%s\n',towrite{i_w});
end
fclose(fid);
if any(not(status))
    warning('Could not write all matlabbatch')
end

if all(status)
    status = true;
end
ok = status;
