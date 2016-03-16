function [h] = psubplot(r,c,i)

[ic,ir] = ind2sub([c,r],i);
p = panel.recover();
p.margintop = 15;
if ~isempty(p) && numel(p.de) == r*c + r
    h = p(ir,ic).select();
else
    p = panel();
    p.pack(r,c);
    h = p(ir,ic).select();
end

if nargout == 0
    clear h
end
