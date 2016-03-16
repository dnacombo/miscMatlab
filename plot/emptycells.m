function idx = emptycells(c)

% idx = emptycells(c)
% return idx same size as c with logical true at indices of c that are
% empty. logical false elsewhere.

idx = cellfun('isempty',c);
% return
% idx = false(size(c));
% for i = 1:numel(c)
%     if isempty(c{i})
%         idx(i) = true;
%     end
% end

