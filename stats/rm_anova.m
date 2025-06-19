function stats = rm_anova_clean(x,fnames)
%
%  RM_ANOVA
%
%  Usage:
%    >> stats = rm_anova(x, fnames);
%       x is a matrix with subjects as 1st dimension
%         factors are along each subsequent dimension
%       fnames is a cell array of factor names (default {'f1','f2'...})
%
% Maximilien Chaumon
% based on
% Valentin Wyart
% Aaron Schurger (2005.02.04)
%   Derived from Keppel & Wickens (2004) "Design and Analysis" ch. 18
%
% MIT License
% 
% Copyright (c) **2025 Maximilien Chaumon**
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

t = doconds(size(x));
s = t{1}; % subjects
f = t(2:end); % factors
clear t

n = numel(f);
is=unique(s);% list of subjects
iff = cellfun(@unique,f,'uniformoutput',false);% list of factor levels

ns=numel(is);% number of subjects
nff = cellfun(@numel,iff,'uniformoutput',false); % number of each factor's levels

ddim = [nff{:} ns];
aver = permute(x,[2:ndims(x) 1]);

st = nansum(aver(:));
ss = nansum(reshape(aver,[prod(ddim(1:end-1)) ns]),1)';
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        sid = ['s' id];
        excl = setdiff(1:n, comb(i1,:));
        excl = sort(excl, 'descend');
        sumdim = [int2str(n+1) '),'];
        for i2 = 1:length(excl)
            sumdim = [sumdim int2str(excl(i2)) '),'];
        end
        resdim = '[';
        for i2 = 1:size(comb, 2)
            resdim = [resdim 'nff{' int2str(comb(i1,i2)) '},'];
        end
        if size(comb, 2) == 1
            resdim = [resdim '1]'];
        else
            resdim = [resdim(1:end-1) ']'];
        end
        command = [sid '=reshape('];
        for i2 = 1:length(excl)+1
            command = [command 'nansum('];
        end
        command = [command 'aver,' sumdim resdim ');'];
        eval(command);
        if i < n
            sid = ['s' id 's'];
            excl = setdiff(1:n, comb(i1,:));
            excl = sort(excl, 'descend');
            sumdim = '';
            for i2 = 1:length(excl)
                sumdim = [sumdim int2str(excl(i2)) '),'];
            end
            resdim = '[';
            for i2 = 1:size(comb, 2)
                resdim = [resdim 'nff{' int2str(comb(i1,i2)) '},'];
            end
            resdim = [resdim 'ns]'];
            command = [sid '=reshape('];
            for i2 = 1:length(excl)
                command = [command 'nansum('];
            end
            command = [command 'aver,' sumdim resdim ');'];
            eval(command);
        end
    end
end
command = 'dfs=ns-1;';
eval(command);
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        name = 'df';
        for i2 = 1:size(comb, 2)
            name = [name int2str(comb(i1,i2))];
        end
        operation = '=';
        for i2 = 1:size(comb, 2)
            operation = [operation '(n' int2str(comb(i1,i2)) '-1)*'];
        end
        operation(end) = [];
        command = [name operation ';'];
        eval(command);
        
        name = [name 's'];
        operation = [operation '*(ns-1)'];
        command = [name operation ';'];
        eval(command);
    end
end

command = 'expx=nansum(x(:).^2);';
eval(command);
id = '';
for i = 1:n
    id = [id int2str(i)];
end
command = ['exp' id 's=expx;'];
eval(command);
command = 'expt=st^2/(';
for i = 1:n
    command = [command 'n' int2str(i) '*'];
end
command = [command 'ns);'];
eval(command);
command = 'exps=nansum(ss(:).^2)./(';
for i = 1:n
    command = [command 'n' int2str(i) '*'];
end
command = [command(1:end-1) ');'];
eval(command);
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        expid = ['exp' id];
        sid = ['s' id];
        excl = setdiff(1:n, comb(i1,:));
        denom = '(1*';
        for i2 = 1:length(excl)
            denom = [denom 'n' int2str(excl(i2)) '*'];
        end
        denom = [denom 'ns)'];
        command = [expid '=nansum(' sid '(:).^2)./' denom ';'];
        eval(command);
        if i < n
            expid = ['exp' id 's'];
            sid = ['s' id 's'];
            excl = setdiff(1:n, comb(i1,:));
            denom = '(1*';
            for i2 = 1:length(excl)
                denom = [denom 'n' int2str(excl(i2)) '*'];
            end
            denom = [denom(1:end-1) ')'];
            command = [expid '=nansum(' sid '(:).^2)./' denom ';'];
            eval(command);
        end
    end
end

command = 'sss=exps-expt;';
eval(command);
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        command = ['ss' id '='];
        op = '+';
        for j = i:-1:1
            combbis = combnk(comb(i1,:), j);
            for j1 = 1:size(combbis, 1)
                idbis = '';
                for j2 = 1:size(combbis, 2)
                    idbis = [idbis int2str(combbis(j1,j2))];
                end
                command = [command op 'exp' idbis];
            end
            if strcmp(op, '+')
                op = '-';
            else
                op = '+';
            end
        end
        command = [command op 'expt;'];
        eval(command);
        command = ['ss' id 's='];
        op = '+';
        for j = i:-1:1
            combbis = combnk(comb(i1,:), j);
            for j1 = 1:size(combbis, 1)
                idbis = '';
                for j2 = 1:size(combbis, 2)
                    idbis = [idbis int2str(combbis(j1,j2))];
                end
                command = [command op 'exp' idbis 's'];
            end
            if strcmp(op, '+')
                op = '-';
            else
                op = '+';
            end
            for j1 = 1:size(combbis, 1)
                idbis = '';
                for j2 = 1:size(combbis, 2)
                    idbis = [idbis int2str(combbis(j1,j2))];
                end
                command = [command op 'exp' idbis];
            end
        end
        command = [command op 'exps'];
        if strcmp(op, '+')
            op = '-';
        else
            op = '+';
        end
        command = [command op 'expt;'];
        eval(command);
    end
end
            
command = 'mss=sss/dfs;';
eval(command);
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        command = ['ms' id '=ss' id '/df' id ';'];
        eval(command);
        command = ['ms' id 's=ss' id 's/df' id 's;'];
        eval(command);
    end
end

for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        command = ['if ms' id 's==0,f' id '=0;else,f' id '=ms' id '/ms' id 's;end'];
        eval(command);
    end
end

for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
        end
        command = ['p' id '=1-fcdf(f' id ',df' id ',df' id 's);'];
        eval(command);
    end
end

command = 'stats=struct;';
for i = 1:n
    comb = combnk(1:n, i);
    for i1 = 1:size(comb, 1)
        id = '';
        fd = '';
        for i2 = 1:size(comb, 2)
            id = [id int2str(comb(i1,i2))];
            fd = [fd 'f' int2str(comb(i1,i2)) 'x'];
        end
        fd = fd(1:end-1);
        command = ['stats.' fd '.fstats=f' id ';'];
        eval(command);
        command = ['stats.' fd '.pvalue=p' id ';'];
        eval(command);
    end
end
