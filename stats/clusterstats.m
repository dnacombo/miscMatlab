function [mask, pct,C,sig] = clusterstats(input1, pperm,Stat,p, clustpthresh, finalpthresh,channeighbstructmat,use_tfce)

% [mask pct C sig] = clusterstats(StatPerm, pperm,Stat,p, clustpthresh, finalpthresh, channeighbstructmat,use_tfce)
%
% inputs:
%   StatPerm:       matrix of permuted statistic. up to 4D array where last
%                   dimension is permutations
%   pperm:          pvalues associated with StatPerm
%   Stat:           matrix of original statistic. up to 3D.
%   p:              pvalues associated with Stat
%   clustthresh:    threshold pvalue to include clusteres of Stat and
%                   StatPerm in cluster size computation
%   finalpthresh:   pvalue of the test
%   channeighbstructmat: 2 d matrix describing connectivity along the first
%                   dimension of StatPerm and Stat.
%   use_tfce:       NOT WORKING: use tfce method instead of this fixed threshold method
%                   (call tfce.m). (see Smith and Nichols 2009) 
% outputs:
%   mask:           logical matrix, the same size as input Stat, true where
%                   clusters in Stat are considered significant.
%   C:              all N clusters found in Stat, numbered from 1 to N
%   pct:            proportion of permuted clusters smaller than each of
%                   the clusters returned in C
%   sig:            cluster indices in C, that are significant.
%
% alternate input-output method:
%           [statsout] = clusterstats(statsin)
%
% where statsin should contain fields named after the inputs above and
% returned statsout the outputs described above.
%
% Return a mask of clusters of contiguous points in 4D matrix pperm.
% Clusters are delineated as values of pperm that are below clustpthresh.
% The size of the clusters is the sum of StatPerm over all elements of each
% cluster. Cluster sizes are sorted and a threshold cluster size is
% retrieved as the finalpthresh (quantile) of all clusters from StatPerm.
% This cluster size threshold is used to determine if the clusters found in
% Stat are bigger or not. Any bigger cluster is returned in mask. If
% size(StatPerm,1) is larger than one, assume neighborhood based on
% channeighbstructmat.
% if use_tfce is true, then use tfce method instead of this fixed threshold
% method (call tfce.m). (see Smith and Nichols 2009)

% Author: Maximilien Chaumon (~2015)
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

if nargin == 1 % assume one structure input
    def.channeigbstruuctmat = [];
    def.use_tfce = false;
    input1 = setdef(input1,def);
    struct2ws(input1)
else
    StatPerm = input1;
    try
        narginchk(4,8)
    catch
        error(nargchk(4,8,nargin))
    end
    if nargin < 7
        channeighbstructmat = [];
    end
    if nargin < 8
        use_tfce = false;
    end
end

% if we have less than four dimensions, we'll insert dummy singleton
% dimensions before the last one. last dimension thus always contains
% permutations
if ndims(StatPerm) < 4
    s = size(StatPerm);
    StatPerm = reshape(StatPerm,[s(1:end-1) ones(1,4-numel(s)) s(end)] );
    pperm = reshape(pperm,[s(1:end-1) ones(1,4-numel(s)) s(end)] );
end

verbose = 0; % plot clusters distributions if true
SC = [];
if use_tfce
    % to determine a good dh, we lump Stat and StatPerm together, look at
    % the range of the 1%ile to 99%ile of the data, divide that by 50 and
    % use for dh.
    tmp = cat(4,Stat,StatPerm);
    r = diff(quantile(tmp(:),[.01 .99]));
    dh = r/50;
    clear tmp
end
if exist('parpool','file') && ~isempty(gcp('nocreate'))
    SC = parloop(StatPerm,pperm,clustpthresh,channeighbstructmat);
else
%     textprogressbar('Permutation ')
    for i_perm = 1:size(StatPerm,4)
%         textprogressbar(i_perm/size(StatPerm,4)*100);
        if use_tfce
            perm_tfce_loc = tfce(StatPerm(:,:,:,i_perm),channeighbstructmat,dh);
            SC(i_perm) = max(perm_tfce_loc(:));
        else
            StatPerm_loc = StatPerm(:,:,:,i_perm);
            pperm_loc = pperm(:,:,:,i_perm);
            if ~islogical(pperm_loc)
                pperm_loc = pperm_loc <= clustpthresh;
            end
            % first find clusters with matlab's bwlabeln for each boot
            if size(StatPerm,1) == 1
                [C, nb] = bwlabeln(pperm_loc);
            else % if we also have channels, use
                % findcluster function (from fieldtrip toolbox) to find clusters.
                [C, nb] = findcluster(pperm_loc, channeighbstructmat);
            end
            sizeclusts = 0;
            for ic = 1:nb
                % sum across each cluster
                sizeclusts(ic) = sum(StatPerm_loc(C == ic));
            end
            SC(i_perm) = max(sizeclusts);% save the sum of the largest cluster.
        end
    end
%     textprogressbar('Done')
end
% textprogressbar();
sortSC = sort(SC);
clustthresh = ceil((1-finalpthresh) * numel(SC));% threshold index for sorted values
threshT = sortSC(clustthresh);% extract threshold cluster sum
if verbose
    figure;
    hist(SC,100);
    hold on;
    plot([threshT threshT],ylim,'r','linewidth',2)
end

% actual clusters
if use_tfce
    tfce_real = tfce(Stat,channeighbstructmat,dh);
    sizeclusts = unique(tfce_real(:));
    mask = tfce_real > threshT;
    pct = NaN(size(sizeclusts));
    for ic = 1:numel(sizeclusts)
        pct(end+1) = sum(sortSC < sizeclusts(ic)) ./ numel(sortSC);
    end
else
    if size(p,1) == 1
        [C, nb] = bwlabeln(p<clustpthresh);
    else
        [C, nb] = findcluster(p<clustpthresh,channeighbstructmat);
    end
    sig = [];pct = [];sizeclusts = [];
    for ic = 1:nb
        % sum across each cluster
        sizeclusts(ic) = sum(Stat(C == ic));
        
        if sizeclusts(ic) > threshT%min(sortSC)%
            sig(end+1) = ic;
        end
        if sizeclusts(ic) > sortSC(1)
            pct(end+1) = sum(sizeclusts(ic) > sortSC) ./ numel(sortSC);
        end
    end
    %%
    mask = false(size(C));
    for isig = 1:numel(sig)
        mask(C == sig(isig)) = 1;
    end
end
if verbose
    yl = ylim;
    y = yl(1)+diff(yl)/10;
    y = repmat(y,numel(sizeclusts),1);
    scatter(sizeclusts,y,'r')
    title('cluster sizes')
    legend({'all permuted clusters' 'Threshold' 'observed clusters'})
    ylabel('permutations')
    xlabel('cluster size')
end
if nargout == 1 % output one structure
    mask = struct('mask',mask);
    mask.pct = pct;
    mask.C = C;
    mask.sig = sig;
end
    


function [cluster, num] = findcluster(onoff, spatdimneighbstructmat, varargin)

% FINDCLUSTER returns all connected clusters in a 3 dimensional matrix
% with a connectivity of 6.
%
% Use as
%   [cluster, num] = findcluster(onoff, spatdimneighbstructmat, minnbchan)
% or as
%   [cluster, num] = findcluster(onoff, spatdimneighbstructmat, spatdimneighbselmat, minnbchan)
% where
%   onoff                   is a 3D boolean matrix with size N1xN2xN3,
%                           N1=number of channels
%                           N2 & N3 = Time Frequency (any order)
%   spatdimneighbstructmat  defines the neighbouring channels/combinations, see below
%   minnbchan               the minimum number of neighbouring channels/combinations
%   spatdimneighbselmat     is a special neighbourhood matrix that is used for selecting
%                           channels/combinations on the basis of the minnbchan criterium
%
% The neighbourhood structure for the first dimension is specified using
% spatdimneighbstructmat, which is a 2D (N1xN1) matrix. Each row and each column corresponds
% to a channel (combination) along the first dimension and along that row/column, elements
% with "1" define the neighbouring channel(s) (combinations). The first dimension of
% onoff should correspond to the channel(s) (combinations).
% The lower triangle of spatdimneighbstructmat, including the diagonal, is
% assumed to be zero.
%
% See also BWSELECT, BWLABELN (image processing toolbox)
% and SPM_CLUSTERS (spm2 toolbox).

% Copyright (C) 2004, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: findcluster.m 952 2010-04-21 18:29:51Z roboos $
% renamed for integration in LIMO toolbox: GAR, University of Glasgow, June
% 2010

spatdimlength = size(onoff, 1);
nfreq = size(onoff, 2);
ntime = size(onoff, 3);

if length(size(spatdimneighbstructmat))~=2 || ~all(size(spatdimneighbstructmat)==spatdimlength)
    error('invalid dimension of spatdimneighbstructmat');
end

minnbchan=0;
if length(varargin)==1
    minnbchan=varargin{1};
end;
if length(varargin)==2
    spatdimneighbselmat=varargin{1};
    minnbchan=varargin{2};
end;

if minnbchan>0
    % For every (time,frequency)-element, it is calculated how many significant
    % neighbours this channel has. If a significant channel has less than minnbchan
    % significant neighbours, then this channel is removed from onoff.
    
    if length(varargin)==1
        selectmat = single(spatdimneighbstructmat | spatdimneighbstructmat');
    end;
    if length(varargin)==2
        selectmat = single(spatdimneighbselmat | spatdimneighbselmat');
    end;
    nremoved=1;
    while nremoved>0
        nsigneighb=reshape(selectmat*reshape(single(onoff),[spatdimlength (nfreq*ntime)]),[spatdimlength nfreq ntime]);
        remove=(onoff.*nsigneighb)<minnbchan;
        nremoved=length(find(remove.*onoff));
        onoff(remove)=0;
    end;
end;

% for each channel (combination), find the connected time-frequency clusters
labelmat = zeros(size(onoff));
total = 0;
for spatdimlev=1:spatdimlength
    [labelmat(spatdimlev, :, :), num] = bwlabeln(reshape(onoff(spatdimlev, :, :), nfreq, ntime), 4);
    labelmat(spatdimlev, :, :) = labelmat(spatdimlev, :, :) + (labelmat(spatdimlev, :, :)~=0)*total;
    total = total + num;
end

% combine the time and frequency dimension for simplicity
labelmat = reshape(labelmat, spatdimlength, nfreq*ntime);

% combine clusters that are connected in neighbouring channel(s)
% (combinations).
replaceby=1:total;
for spatdimlev=1:spatdimlength
    neighbours=find(spatdimneighbstructmat(spatdimlev,:));
    for nbindx=neighbours
        indx = find((labelmat(spatdimlev,:)~=0) & (labelmat(nbindx,:)~=0));
        for i=1:length(indx)
            a = labelmat(spatdimlev, indx(i));
            b = labelmat(nbindx, indx(i));
            if replaceby(a)==replaceby(b)
                % do nothing
                continue;
            elseif replaceby(a)<replaceby(b)
                % replace all entries with content replaceby(b) by replaceby(a).
                replaceby(replaceby==replaceby(b)) = replaceby(a);
            elseif replaceby(b)<replaceby(a)
                % replace all entries with content replaceby(a) by replaceby(b).
                replaceby(replaceby==replaceby(a)) = replaceby(b);
            end
        end
    end
end

% renumber all the clusters
num = 0;
cluster = zeros(size(labelmat));
for uniquelabel=unique(replaceby(:))'
    num = num+1;
    cluster(ismember(labelmat(:),find(replaceby==uniquelabel))) = num;
end

% reshape the output to the original format of the data
cluster = reshape(cluster, spatdimlength, nfreq, ntime);

function textprogressbar(c)
% This function creates a text progress bar. It should be called with a 
% STRING argument to initialize and terminate. Otherwise the number correspoding 
% to progress in % should be supplied.
% INPUTS:   C   Either: Text string to initialize or terminate 
%                       Percentage number to show progress 
% OUTPUTS:  N/A
% Example:  Please refer to demo_textprogressbar.m

% Author: Paul Proteus (e-mail: proteus.paul (at) yahoo (dot) com)
% Version: 1.0
% Changes tracker:  29.06.2010  - First version

% Inspired by: http://blogs.mathworks.com/loren/2007/08/01/monitoring-progress-of-a-calculation/

%% Initialization
persistent strCR prevc strCRtitle;           %   Carriage return pesistent variable

% Vizualization parameters
strPercentageLength = 10;   %   Length of percentage string (must be >5)
strDotsMaximum      = 10;   %   The total number of dots in a progress bar

%% Main 
if nargin == 0
    % Progress bar  - force termination/initialization
    fprintf('\n');
    strCR = [];
    strCRtitle = [];
    prevc = [];
elseif ischar(c)
    % Progress bar - set/reset title
    if not(isempty(strCR)) && strCR(1) ~= -1
        fprintf(strCR);
    end
    if not(isempty(strCRtitle))
        fprintf(strCRtitle);
    end
    % add trailing space if not one already
    if isempty(regexp(c,'\s$', 'once'))
        c = [c ' '];
    end
    fprintf('%s',c);
    strCR = -1;strCRtitle = repmat('\b',1,numel(c));
elseif isnumeric(c)
    % Progress bar - normal progress
    if isempty(prevc)
        prevc = 0;
    end
    c = floor(c);
    if c == prevc
        return
    else
        prevc = c;
    end
    percentageOut = [num2str(c) '%%'];
    percentageOut = [percentageOut repmat(' ',1,strPercentageLength-length(percentageOut)-1)];
    nDots = floor(c/100*strDotsMaximum);
    dotOut = ['[' repmat('.',1,nDots) repmat(' ',1,strDotsMaximum-nDots) ']'];
    strOut = [percentageOut dotOut];
    
    % Print it on the screen
    if strCR == -1,
        % Don't do carriage return during first run
        fprintf(strOut);
    else
        % Do it during all the other runs
        fprintf([strCR strOut]);
    end
    
    % Update carriage return
    strCR = repmat('\b',1,length(strOut)-1);
    
else
    % Any other unexpected input
    error('Unsupported argument type');
end

function percent = parfor_progress(N)
%PARFOR_PROGRESS Progress monitor (progress bar) that works with parfor.
%   PARFOR_PROGRESS works by creating a file called parfor_progress.txt in
%   your working directory, and then keeping track of the parfor loop's
%   progress within that file. This workaround is necessary because parfor
%   workers cannot communicate with one another so there is no simple way
%   to know which iterations have finished and which haven't.
%
%   PARFOR_PROGRESS(N) initializes the progress monitor for a set of N
%   upcoming calculations.
%
%   PARFOR_PROGRESS updates the progress inside your parfor loop and
%   displays an updated progress bar.
%
%   PARFOR_PROGRESS(0) deletes parfor_progress.txt and finalizes progress
%   bar.
%
%   To suppress output from any of these functions, just ask for a return
%   variable from the function calls, like PERCENT = PARFOR_PROGRESS which
%   returns the percentage of completion.
%
%   Example:
%
%      N = 100;
%      parfor_progress(N);
%      parfor i=1:N
%         pause(rand); % Replace with real code
%         parfor_progress;
%      end
%      parfor_progress(0);
%
%   See also PARFOR.

% By Jeremy Scheff - jdscheff@gmail.com - http://www.jeremyscheff.com/

error(nargchk(0, 1, nargin, 'struct'));

if nargin < 1
    N = -1;
end

percent = 0;
w = 50; % Width of progress bar

if N > 0
    f = fopen('parfor_progress.txt', 'w');
    if f<0
        error('Do you have write permissions for %s?', pwd);
    end
    fprintf(f, '%d\n', N); % Save N at the top of progress.txt
    fclose(f);
    
    if nargout == 0
        disp(['  0%[>', repmat(' ', 1, w), ']']);
    end
elseif N == 0
    delete('parfor_progress.txt');
    percent = 100;
    
    if nargout == 0
        disp([repmat(char(8), 1, (w+9)), char(10), '100%[', repmat('=', 1, w+1), ']']);
    end
else
    if ~exist('parfor_progress.txt', 'file')
        error('parfor_progress.txt not found. Run PARFOR_PROGRESS(N) before PARFOR_PROGRESS to initialize parfor_progress.txt.');
    end
    
    f = fopen('parfor_progress.txt', 'a');
    fprintf(f, '1\n');
    fclose(f);
    
    f = fopen('parfor_progress.txt', 'r');
    progress = fscanf(f, '%d');
    fclose(f);
    percent = (length(progress)-1)/progress(1)*100;
    
    if nargout == 0
        perc = sprintf('%3.0f%%', percent); % 4 characters wide, percentage
        disp([repmat(char(8), 1, (w+9)), perc, '[', repmat('=', 1, round(percent*w/100)), '>', repmat(' ', 1, w - round(percent*w/100)), ']']);
    end
end

function SC = parloop(StatPerm,pperm,clustpthresh,channeighbstructmat)

SC = NaN(1,size(StatPerm,4));
% parfor_progress(size(StatPerm,4));
% disp('parallel computing of cluster size permutations');
parfor i_perm = 1:size(StatPerm,4)
        StatPerm_loc = StatPerm(:,:,:,i_perm);
        pperm_loc = pperm(:,:,:,i_perm);
        % first find clusters with matlab's bwlabeln for each boot
        if size(StatPerm,1) == 1
            [C nb] = bwlabeln(pperm_loc <= clustpthresh);
        else % if we also have channels, use
            % findcluster function (from fieldtrip toolbox) to find clusters.
            [C nb] = findcluster(pperm_loc <= clustpthresh, channeighbstructmat);
        end
        sizeclusts = 0;
        for ic = 1:nb
            % sum across each cluster
            sizeclusts(ic) = sum(StatPerm_loc(C == ic));
        end
        SC(i_perm) = max(sizeclusts);% save the sum of the largest cluster.
%         parfor_progress;
end
% parfor_progress(0);
