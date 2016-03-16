function Ims = fft_phase_scramble(Im,cutbounds,proportion, amount)

% Ims = fft_phase_scramble(Im, cutbounds,proportion, amount)
% 
% Scramble the phase of image Im (filename or image matrix) for frequencies
% defined by cutbounds (see below). Only proportion [0 to 1] of the frequencies are
% actually scrambled. The phases are affected by amount radians at
% most.
%
% Scramble occurs in the interval defined by cutbounds in cycles per image (cpi).
% ex. : fft_phase_scrambler('mybestpicture.jpg',5)
% will scramble phases below 5 cpi (scramble all between 0 and 5)
%       fft_phase_scrambler('mybestpicture.jpg',[5 50])
% will scramble phases between 5 and 50 cpi.
%       fft_phase_scrambler('mybestpicture.jpg',[50 Inf])
% will scramble phases above 50 cpi.
%
% Max 9/13/10
% Max 18.10.2011 : added proportion

if nargin == 0
    help fft_phase_scramble
    return
end
if not(exist('proportion','var'))
    proportion = 1;
end
if not(exist('amount','var'))
    amount = pi;
end
if ischar(Im)
    Im = im2double(imread(Im));
end
if nargin == 1
    cutbounds = [0 Inf];
end
if numel(cutbounds) == 1
    cutbounds = [0 cutbounds];
end

Imsize = size(Im);
if numel(Imsize) == 2
    numLayers = 1;
elseif numel(Imsize) == 3
    numLayers = Imsize(3);
end
cutbounds(cutbounds>Imsize(1:2)) = Imsize(cutbounds>Imsize(1:2));
cutbounds = cutbounds ./ Imsize(1:2);

[Amp, Phase] = fourier_phase_amp(Im);

toscramble(1,:) = round(cutbounds*Imsize(1)/2);
toscramble(2,:) = round(cutbounds*Imsize(2)/2);
idxtoscramble{1} = [1+toscramble(1,1):toscramble(1,2) Imsize(1)-(toscramble(1,1):toscramble(1,2))];
idxtoscramble{2} = [1+toscramble(2,1):toscramble(2,2) Imsize(2)-(toscramble(2,1):toscramble(2,2))];

% applying proportion
idxidxtoscramble = randperm(numel(idxtoscramble{1}));
idxidxtoscramble = sort(idxidxtoscramble(1:round(proportion*numel(idxtoscramble{1}))));
idxtoscramble{1} = idxtoscramble{1}(idxidxtoscramble);
idxidxtoscramble = randperm(numel(idxtoscramble{2}));
idxidxtoscramble = sort(idxidxtoscramble(1:round(proportion*numel(idxtoscramble{2}))));
idxtoscramble{2} = idxtoscramble{2}(idxidxtoscramble);

RandPhase = (2*rand(numel(idxtoscramble{1}),numel(idxtoscramble{2}))-1) * amount;
%angle(fft2(rand(numel(idxtoscramble{1}),numel(idxtoscramble{2}))));% same phase scramble for all layers.
Phases = Phase;
Amps = Amp;
for i_lay = 1:numLayers
    % the trick is to apply the same phase scramble to each of the three
    % layers.
    Phases(idxtoscramble{1},idxtoscramble{2},i_lay) = Phase(idxtoscramble{1},idxtoscramble{2},i_lay) + ...
        RandPhase;
    %imshow(Phases./pi);

    %combine Amp and Phase then perform inverse Fourier
    Imtmp(:,:,i_lay) = ifft2(Amps(:,:,i_lay).*exp(1i*(Phases(:,:,i_lay) )));

end
Ims = real(Imtmp);
% Ims = mat2gray(real(Imtmp));
% figure(1);
% imshow(Ims);
if nargout == 0
    clear Ims
end

return

function [Amp, Phase] = fourier_phase_amp(Im)

% [Amp, Phase] = myfourier(Im)
% retrieve Amplitude and phase of fourier transform of image.

Imsize = size(Im);
if numel(Imsize) == 2
    numLayers = 1;
elseif numel(Imsize) == 3
    numLayers = Imsize(3);
end

for i_layer = 1:numLayers
    %Fast-Fourier transform
    ImFourier(:,:,i_layer) = fft2(Im(:,:,i_layer));
    %amplitude spectrum
    Amp(:,:,i_layer) = abs(ImFourier(:,:,i_layer));
    %phase spectrum
    Phase(:,:,i_layer) = angle(ImFourier(:,:,i_layer));
end


