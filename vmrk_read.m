function [mrk,head] = vmrk_read(file)

head = struct('head',{[]});
section = 'head';
fid = fopen(file,'rt');
while 1
    line = fgetl(fid);
    if  (isnumeric(line) && line == -1)
        break
    end
    if isempty(line)
        continue
    end

    
    if regexp(line,'^\[.*\]$') == 1
        section = line(2:end-1);
        section = strrep(section,' ','_');
        head.(section) = {};
        continue
    end
    head.(section){end+1} = line;
end
fclose(fid);

% markers postprocessing
mrk = flister('Mk(?<Mk>\d+)=(?<Type>[^,]*),(?<Desc>[^,]*),(?<Pos>[^,]*),(?<Siz>[^,]*),(?<Chan>.+?),?(?<Date>.*)?','list',head.Marker_Infos,'noidx',1,'sortfields','');
mrk = rmfield(mrk,'name');
[mrk.Mk] = rep2struct(cellfun(@str2num,{mrk.Mk}));
[mrk.Pos] = rep2struct(cellfun(@str2num,{mrk.Pos}));
[mrk.Siz] = rep2struct(cellfun(@str2num,{mrk.Siz}));
[mrk.Chan] = rep2struct(cellfun(@str2num,{mrk.Chan}));
head = rmfield(head,'Marker_Infos');
