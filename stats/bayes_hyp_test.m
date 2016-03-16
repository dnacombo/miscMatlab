function [BF deltaBIC p0] = bayes_hyp_test(SSE1,SSE0,n)

% [BF deltaBIC p0] = bayes_hyp_test(SSE1,SSE0,n)
% Bayesian information criterion (BIC) approximation of bayesian hypothesis
% testing H0 against one alternative hypothesis, using the SPSS output of
% an ANOVA.
%
% You better read this: Wagenmakers, Psych Bull & Rev 2007. 
%
% inputs:   SSE1: error sum of squares under H1 (SSE of the error in the
%                 ANOVA table)
%           SSE0: error sum of squares under H0 (SSE1 + SSE of the
%                 factor of interest)
%              n: number of subjects (or trials in case of single-subject
%                 analysis)
%
% outputs:    BF: Bayes Factor. values  < 1      argue in favor of H1
%                                       1-3:     weak evidence for H0
%                                       3-20:    positive evidence for H0
%                                       20-150:  strong evidence for H0
%                                       >150:    very strong evidence for
%                                                H0
%       deltaBIC: difference in BIC
%             p0: posterior probability for H0 (p1 = 1-p0)
%

% v0. SoMax 12/05/2011

try
    error(nargchk(3,3,nargin))
catch ME
    help bayes_hyp_test
    rethrow(ME)
end

deltaBIC = n * log(SSE1/SSE0) + log(n);

BF = exp(deltaBIC/2);

p0 = 1/(1 + exp(-deltaBIC/2));
