function varargout = doconds(nums,ntri,values)
% conds = doconds(nums [,ntri [,values ]] )
% conds = doconds(values [,ntri])
% [cond1 cond2 ...] = doconds(values [,ntri])
%
% Create matrices containing an equal number of trials in each of numel(nums) conditions.
%
% if the first input is a cell array, it is taken as values.
%
% example: conds = doconds([3 2], 5);
% Can help you create an experiment with 3 x 2 conditions and 5 trials in each condition.
% it returns three matrices, with 1:3 replicated 2 and 5 times along the 2d and 3d dimensions
%                                 1:2 replicated 3 and 5 times along the 1st and 3d dimensions
%                                 1:5 replicated 3 and 2 times along the 1st and 2d dimensions
% think about it.

%Mx Jul 2012

if nargin == 0
    nums = [3 2];
end
nums = nums(:)';
if iscell(nums)
    values = nums;
    nums = cellfun(@numel,values);
end
if exist('ntri','var') && not(isempty(ntri))
    nums(end+1) = ntri;
else
    nums(end+1) = 1;
    ntri = 1;
end
if not(exist('values','var')) || isempty(values)
    for i = 1:numel(nums)
        values{i} = 1:nums(i);
    end
elseif numel(values) < numel(nums)
    values{numel(nums)} = 1:nums(numel(nums));
end

if numel(nums) == 1
    conds{1} = values{1};
elseif numel(nums) == 0
    conds = {};
else
    for i_cond = 1:numel(nums)-(ntri==1)
        repdims = nums;
        repdims(i_cond) = 1;
        repvec = values{i_cond};
        repvecreshape = ones(1,numel(nums));
        repvecreshape(i_cond) = nums(i_cond);
        repvec = reshape(repvec,repvecreshape);
        conds{i_cond} = repmat(repvec,repdims);
        clear repvec
    end
end
if nargin == 0
    for i_cond = 1:numel(conds)
        disp(['condition ' num2str(i_cond)])
        disp(conds{i_cond})
    end
end
if nargout > 1
    for i_cond = 1:numel(conds)
        varargout{i_cond} = conds{i_cond};
    end
else
    varargout{1} = conds;
end
 