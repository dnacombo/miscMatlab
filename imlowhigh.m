function [varargout] = imlowhigh(filename, type, fc, normalize, sharpness)
% 
%  IMLOWHIGH
%
% NB : In this new version, if filename is numeric, it is treated as the actual
% image data. and image data is returned as output.
%
%  Description:
%    - filters image using 2D FIR low/high/band-pass filter,
%    - normalizes filtered image background luminance and contrast (optional),
%    - displays original and filtered images on screen,
%    - writes filtered image on disk.
%
%  Usage:
%    >> imlowhigh(filename, type, fc, normalize);
%    >> imlowhigh(filename, type, fc, normalize, sharpness);
%
%  Input arguments:
%    - filename  = input filename
%    - type      = filter type ('low'/'high'/'band')
%    - fc        = cutoff frequency (in cpi = cycles per image)
%    - normalize = normalize filtered image contrast? ('true'/'false')
%    - sharpness = frequency cutoff sharpness (optional) [0.10]
%
%  Example:
%    >> imlowhigh('face.bmp', 'low', 20, 'true');
%    >> imlowhigh('face.bmp', 'low', 10, 'true', 0.20);
%
%  Notes:
%    When using non-square images, cycles per image refer to smallest side.
%    Usually, try to keep cycles per images between 8 and 32.
%    Filtered images are linearly normalized in terms of background luminance to
%    match original images. Optionally, filtered images can also be normalized
%    in terms of contrast to match original images.
%    Increase frequency cutoff sharpness if warning is displayed.
%
%  Author:
%    Valentin Wyart (valentin.wyart@chups.jussieu.fr)
%
%  Version:
%    2007/02/08
% modified by max. 2008/11/06
%

% check number of input arguments
if nargin < 5
    sharpness = 0.10;
end
if nargin < 4
    error('Not enough input arguments.');
end

if isnumeric(filename)
    im = double(filename)./255;
else
    % read original image
    im = double(imread(filename))./255;
    
    % remove extension from input filename
    while ~strcmp(filename(end), '.')
        filename(end) = [];
    end
    filename(end) = [];
end

% select which processing to apply
switch type
    % apply low-pass filter
    case 'low'
        imf = lowpass(im, fc, sharpness, normalize);
        if not(isnumeric(filename))
        titlef = sprintf('imlowhigh(%s, %s, %dcpi, %s, %4.2f)', filename, type, fc, normalize, sharpness);
            filenamef = sprintf('%s_%s_%dcpi_%s_%4.2f.png', filename, type, fc, normalize, sharpness);
        end
    % apply high-pass filter
    case 'high'
        imf = highpass(im, fc, sharpness, normalize);
        if not(isnumeric(filename))
        titlef = sprintf('imlowhigh(%s, %s, %dcpi, %s, %4.2f)', filename, type, fc, normalize, sharpness);
            filenamef = sprintf('%s_%s_%dcpi_%s_%4.2f.png', filename, type, fc, normalize, sharpness);
        end
    % apply band-pass filter
    case 'band'
        imf = bandpass(im, fc, sharpness, normalize);
        if not(isnumeric(filename))
        titlef = sprintf('imlowhigh(%s, %s, %dto%dcpi, %s, %4.2f)', filename, type, fc(1), fc(2), normalize, sharpness);
            filenamef = sprintf('%s_%s_%dto%dcpi_%s_%4.2f.png', filename, type, fc(1), fc(2), normalize, sharpness);
        end
    % unknown filter type
    otherwise
        error('Unknown filter type.');
end

% % create new figure
% figure('Toolbar', 'none');
% % display original image
% subplot(1, 2, 1);
% imagesc(im, [0 1]);
% axis('image');
% colormap('gray');
% title('Original image');
% % display filtered image
% subplot(1, 2, 2);
% imagesc(imf, [0 1]);
% axis('image');
% colormap('gray');
% title('Filtered image');

if isnumeric(filename)
    varargout{1} = imf;
else
    % write filtered image on disk
    imwrite(imf, filenamef);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: CREATE LOW-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = lowpassfilter(n, wc)
% create low-pass frequency response
[f1 f2] = freqspace(n, 'meshgrid');
r = sqrt(f1.^2 + f2.^2);
Hd = ones(n);
Hd(r > wc) = 0;
% create corresponding 2D FIR low-pass filter
h = fwind1(Hd, hamming(n));
% check frequency cutoff
hf = freqz2(h); hmax = max(hf(:));
if hmax < 0.8, warning('Increase sharpness.'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: CREATE HIGH-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = highpassfilter(n, wc)
% create high-pass frequency response
[f1 f2] = freqspace(n, 'meshgrid');
r = sqrt(f1.^2 + f2.^2);
Hd = ones(n);
Hd(r < wc) = 0;
% create corresponding 2D FIR high-pass filter
h = fwind1(Hd, hamming(n));
% check frequency cutoff
hf = freqz2(h); hmin = min(hf(:));
if hmin > 0.2, warning('Increase sharpness.'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: CREATE BAND-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = bandpassfilter(n, wc)
% create band-pass frequency response
[f1 f2] = freqspace(n, 'meshgrid');
r = sqrt(f1.^2+f2.^2);
Hd = ones(n);
Hd((r < wc(1))|(r > wc(2))) = 0;
% create corresponding 2D FIR band-pass filter
h = fwind1(Hd, hamming(n));
% check frequency cutoff
hf = freqz2(h); hmin = min(hf(:)); hmax = max(hf(:));
if hmin > 0.2 || hmax < 0.8, warning('Increase sharpness.'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: APPLY LOW-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imf = lowpass(im, fc, sharpness, normalize)
% create low-pass filter
n = round(sharpness*min(size(im))/2)*2+1;
wc = 2*fc/min(size(im));
h = lowpassfilter(n, wc);
% apply low-pass filter
imf = imfilter(im, h, 'replicate');
% normalize contrast (optional)
if strcmp(normalize, 'true')
    imf = (imf-min(imf(:))).*(max(im(:))-min(im(:)))./(max(imf(:))-min(imf(:)));
end
% normalize background luminance
imf = imf+im(1,1)-imf(1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: APPLY HIGH-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imf = highpass(im, fc, sharpness, normalize)
% create high-pass filter
n = round(sharpness*min(size(im))/2)*2+1;
wc = 2*fc/min(size(im));
h = highpassfilter(n, wc);
% apply high-pass filter
imf = imfilter(im, h, 'replicate');
% normalize contrast (optional)
if strcmp(normalize, 'true')
    imf = (imf-min(imf(:))).*(max(im(:))-min(im(:)))./(max(imf(:))-min(imf(:)));
end
% normalize background luminance
imf = imf+im(1,1)-imf(1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL FUNCTION: APPLY BAND-PASS FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imf = bandpass(im, fc, sharpness, normalize)
% create band-pass filter
n = round(sharpness*min(size(im))/2)*2+1;
wc = 2*fc/min(size(im));
h = bandpassfilter(n, wc);
% apply band-pass filter
imf = imfilter(im, h, 'replicate');
% normalize contrast (optional)
if strcmp(normalize, 'true')
    imf = (imf-min(imf(:))).*(max(im(:))-min(im(:)))./(max(imf(:))-min(imf(:)));
end
% normalize background luminance
imf = imf+im(1,1)-imf(1,1);
