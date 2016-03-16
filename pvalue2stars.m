function s = pvalue2stars(p)
% s = pvalue2stars(p)
%
% turn pvalue p (numeric) to cell array of strings s, the same size as p
% 
% p(i)<=0.05 : s{i} = '*'
% p(i)<0.01 : s{i} = '**'
% p(i)<0.001 : s{i} = '***'
% p(i)>0.5 : s{i} = 'NS'
% p(i)=NaN : s{i} = 'NaN'

% Proudly: Max August 2012

s = cell(size(p));
for i_p = 1:numel(p)
    
    if isnan(p(i_p))
        s{i_p} = 'NaN';
        continue
    end
    
    if p(i_p) > .05
        s{i_p} = 'NS';
    elseif p(i_p) < 0.001
        s{i_p} = '***';
    elseif p(i_p) < .01
        s{i_p} = '**';
    elseif p(i_p) <= .05
        s{i_p} = '*';
    end
end
