function Hash = quickhash(f)

% Hash = quickhash(f)
%
% compute MD5 checksum of the 1st 1000 bytes of a file (char) or a list of files (cell of chars).
% returns a cell array of MD5 checksums.
%
% this is enough to compare MEG data files.
%


if ischar(f)
    f = {f};
end

Chunk = 1000;
Method    = 'MD5';
Engine = java.security.MessageDigest.getInstance(Method);
Hash = {};
for i = 1:numel(f)
    fid = fopen(f{i},'r');
    if fid < 0
        warning(['Could not open ' f{i}])
        Hash{i} = NaN;
        continue
    end
    [Data] = fread(fid, Chunk, '*uint8');
    Engine.update(Data);
    fclose(fid);
    Hash{i} = typecast(Engine.digest, 'uint8');
end