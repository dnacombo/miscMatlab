function Imf = filter_image(Im, type, cutoff, butter)
% Imf = filter_image(Im, type, cutoff,butter)
% filter image Im with 'low', 'high' or 'band' pass filter at cutoff cycles
% per image using a gaussian (or 6th order butterworth if butter is true)
% filter.
% Note: the Butterworth filter is much more accurate 
% plot(circmean(fftshift(abs(fft2(filteredimage))))) will show you how.
%
% Maximilien Chaumon 2015

if not(exist('butter', 'var'))
    butter = 0;
end

if ischar(Im)
    Im = double(imread(Im));
end

picsize=size(Im);


Im_ori = double(Im);
Im_f = zeros(size(Im_ori));
for i_3 = 1:size(Im_ori,3)
    Im = Im_ori(:,:,i_3);
    switch type
        case 'low'
            lp_cutoff = round(cutoff);
            if butter
                L = butter21(lp_cutoff/picsize(1), picsize(1), 'low');
                % L = lpfilter('btw',picsize(1),picsize(2),lp_cutoff,1);
            else
                L = fftshift(gaussian_filter(picsize(1),lp_cutoff/picsize(1)));
            end
            Imf = dftfilt(Im,L);
            %         mean(mean(Imf))
            %         max(max(Imf))
            %         min(min(Imf))
            %set intensity to mean
            %         Imf =Imf-Immean;
        case  'high'
            hp_cutoff = round(cutoff);
            if butter
                H = butter21(hp_cutoff/picsize(1), picsize(1), 'high');
                % H = hpfilter('btw',picsize(1),picsize(2),hp_cutoff,1);
            else
                H = fftshift( 1 - gaussian_filter(picsize(1),hp_cutoff/picsize(1)));
            end
            Imf = dftfilt(Im,H);
            %         Imf = Imf+Immean;
        case 'band'
            if not(length(cutoff) == 2)
                error('Specify two cutoff frequencies for bandpass filtering');
            end
            low_cutoff = round(cutoff(1));
            high_cutoff = round(cutoff(2));
            
            if butter
                BP = butter21([low_cutoff high_cutoff]./picsize(1), picsize(1),'bandpass');
            else
                %             L = lpfilter('gaussian',picsize(1),picsize(2),low_cutoff,1);
                %             H = hpfilter('gaussian',picsize(1),picsize(2),high_cutoff,1);
                H = fftshift( 1 - gaussian_filter(picsize(1),high_cutoff/picsize(1)));
                L = fftshift(gaussian_filter(picsize(1),low_cutoff/picsize(1)));
                BP =  H+L;
            end
            Imf = dftfilt(Im,BP);
    end
    Im_f(:,:,i_3) = Imf;
end
Imf = Im_f;

function f=gaussian_filter(n,s)
%This program generates the 2D gaussian filter.
%To generate the filter,code should be written as f=gaussian_filter(size_of_kernel,sigma);
%This code was developed by Vivek Singh Bhadouria, NIT-Agartala India on 4
%August 2011, 12:59AM (E-mail:vivekalig@gmail.com)
%
% adapted by Maximilien Chaumon: normalize by max instead of sum.

x = -1/2:1/(n-1):1/2;
[Y,X] = meshgrid(x,x);
f = exp( -(X.^2+Y.^2)/(2*s^2) );
% f = f / sum(f(:));
f = f / max(f(:));



function Hd = butter21(band, xySize, filtType)
% function Hd = butter2(band, xySize, which)
% 
% filtType is 'bandpass' (=> band = [W1 W2]), 'low' (=> band = W1), 
% 'high' (idem), or 'stop'  (idem);  and xySize is the size of the 
% *square* image.
% 
% Frederic Gosselin, 28/1/2001

maxRadius = round(xySize / 2);
[b,A] = butter(5,band, filtType);
[H,w] = freqz(b,A, xySize,'whole');
[f1,f2] = freqspace(xySize,'meshgrid');
Hd = zeros(size(f1));
r = min(sqrt(f1.^2 + f2.^2), 1);
H = fftshift(abs(H));
if any(isinf(H(:)))
    warning('filter is messed up')
end
    
Hd = fftshift(H(round(maxRadius * r + maxRadius)));

function g = dftfilt(f, H)
%DFTFILT Performs frequency domain filtering.
%   G = DFTFILT(F, H) filters F in the frequency domain using the
%   filter transfer function H. The output, G, is the filtered
%   image, which has the same size as F.  DFTFILT automatically pads
%   F to be the same size as H.  Function PADDEDSIZE can be used to
%   determine an appropriate size for H.
%
%   DFTFILT assumes that F is real and that H is a real, uncentered
%   circularly-symmetric filter function. 

%   Copyright 2002-2004 R. C. Gonzalez, R. E. Woods, & S. L. Eddins
%   Digital Image Processing Using MATLAB, Prentice-Hall, 2004
%   $Revision: 1.5 $  $Date: 2003/08/25 14:28:22 $

% Obtain the FFT of the padded input.
F = fft2(f, size(H, 1), size(H, 2));

% Perform filtering. 
g = real(ifft2(H.*F));

% Crop to original size.
g = g(1:size(f, 1), 1:size(f, 2));