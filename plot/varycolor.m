function ColorSet=varycolor(numberOfColors,colorMap,varybrightness,showit)
% VARYCOLOR Produces various color sets with maximum variation for plots.
%
%     VARYCOLOR(numberOfColors) returns a matrix of dimension
%     numberOfColors by 3.  The matrix may be used in conjunction with the
%     plot command option 'color' to vary the color of lines.
%
%     VARYCOLOR(numberOfColors,colorMap) returns a matrix of dimension numberOfColors by 3 using
%     algorhythm defined by colorMap.
%       colorMap can be:
%                   - a string for a named color. This will vary colors from
%                       that color to white.
%                   - a cell array of strings of color names. This will
%                       vary colors between them (linearly in rgb space)
%                   - a string '-name' will vary colors from that color to black.
%                   - a 1x3 vector specifying RGB values will vary colors from
%                       that color to white.
%                   - a 1x3 vector specifying negative RGB values will vary
%                       colors from that color to black.
%                   - a nx3 vector specifying RGB values will vary colors
%                       between these colors. 
%                   - a string 'rainbow' 'lines10' or any of the standard
%                       matlab colormaps just try it. 
%                   - a string 'auto' (default) will use lines10 if less
%                       than 10 colors and rainbow otherwise
%
%     VARYCOLOR(numberOfColors,'colorbrewer',javascript) use the colormap
%       obtained from www.colorbrewer2.org (see that website)
%       Important note: copy paste the text from the website in EXPORT,
%       Javascript, AND replace the square brackets around the text
%       by curly braces {} (see example below).
%
%     VARYCOLOR([],'gallery') creates a galery of many different possible
%       color sets obtained by using the following inputs to varycolor
%     Inputs:    numberOfColors  colorMap        varybrightness
%                 8               'auto'              0
%                 100             'auto'              0
%                 8                'red'              0
%                 10              'blue'              0
%                 10               'jet'              0
%                 100             'bone'              0
%                 3               '-red'              0
%                 7               '-blue'             0
%                 100    [255 255 178;189 0 0]/255    0
%                 100    [255 127 0;0 127 127]/255    1
%                 100    [255 127 0;0 127 127]/255    -1
%                 100        'colorbrewer'            {'rgb(241,238,246)','rgb(189,201,225)','rgb(116,169,207)','rgb(43,140,190)','rgb(4,90,141)'}
%
%     VARYCOLOR(numberOfColors,colorMap,varybrightness) attempts to vary the brightness of
%       the colors (from darkest to brightest of input colors if
%       varybrightness == 1 and from brightest to darkest if varybrightness
%       == -1) (experimental)
%
%     VARYCOLOR(numberOfColors,colorMap,varybrightness, showit)
%               if showit is true, show the output colors in a figure.
%
%     Example Usage:
%       figure;
%       colormap(varycolor(100,'-red'));
%       colorbar
%
%       figure;
%       colormap(varycolor(100,'colorbrewer',{'rgb(241,238,246)','rgb(189,201,225)','rgb(116,169,207)','rgb(43,140,190)','rgb(4,90,141)'}));
%       colorbar
%
%       varycolor(100,'gallery');
%
% v1 Maximilien Chaumon 2013: added various colormaps
% v2 Maximilien Chaumon 2014: added varybrightness colorbrewer & gallery
% v3 Maximilien Chaumon 2015: added viridis colormap
% v4 Maximilien Chaumon 2016: added named colors from R standard colors()

%
% based on Daniel Helmick 8/12/2008

narginchk(0,4)%correct number of input arguements??
nargoutchk(0, 1)%correct number of output arguements??

if not(exist('numberOfColors','var')) || isempty(numberOfColors)
    numberOfColors = 256;
end
if not(exist('colorMap','var')) || isempty(colorMap)
    colorMap = 'auto';
end
if not(exist('varybrightness','var')) || isempty(varybrightness)
    varybrightness = 0;
end
if not(exist('showit','var')) || isempty(showit)
    showit = 0;
end
if numberOfColors<1
    ColorSet=[];
    return
end
if isnumeric(colorMap) && numel(colorMap) == 3
    % just one color specified as RGB triplet
    % we'll shade this color to white or black
    if size(colorMap,1)>1
        colorMap = colorMap';
    end
    if all(colorMap >= 0)% to white
        for i = 1:3
            ColorSet(:,i) = linspace(colorMap(i),1,numberOfColors)';
        end
    elseif all(colorMap <= 0)% to black
        for i = 1:3
            ColorSet(:,i) = flipud(linspace(0,-colorMap(i),numberOfColors)');
        end
    else
        error('Color value triplet should be all positive or all negative')
    end
    return
elseif isnumeric(colorMap) && ~rem(numel(colorMap),3)
    % a list N x 3 rgb triplets. shade between them
    if numberOfColors == size(colorMap,1)
        ColorSet = colorMap;
    else% we'll shade between these colors
        if size(colorMap,1)>round(numel(colorMap)/3)
            colorMap = colorMap';
        end
        ColorSet = [];
        for j = 1:size(colorMap,1)-1
            for i = 1:3
                ColorSet(:,j,i) = linspace(colorMap(j,i),colorMap(j+1,i),ceil(numberOfColors/(size(colorMap,1)-1)))';
            end
        end
        ColorSet = reshape(ColorSet,[ceil(numberOfColors/(size(colorMap,1)-1))*(size(colorMap,1)-1) 3]);
    end
elseif isnumeric(colorMap)
    help varycolor
    error('Colormap should be a string or a N x 3 numeric variable')
end
% below is if we use names for colors
if not(isnumeric(colorMap))
    if iscellstr(colorMap)
        % several colors in a cell array of names
        c = cellfun(@colors,colorMap,'uniformoutput',0);
        c = vertcat(c{:});
        ColorSet = varycolor(numberOfColors,c,varybrightness,showit);
        return
    end
    
    % color names handled by colors()
    if strncmp(colorMap,'-',1)
        toblack = 1;
        colorMap(1) = [];
    else
        toblack = 0;
    end
    if not(isempty(colors(colorMap)))
        c = colors(colorMap);
        if toblack
            c = [c; colors('black')];
        else
            c = [c; colors('white')];
        end
        ColorSet = varycolor(numberOfColors,[c],varybrightness,showit);
        return
    end
    
    % matlab standard colormaps and legacy code
    if strcmp(colorMap,'auto')
        if numberOfColors <= 10
            colorMap = 'lines10';
        else
            colorMap = 'rainbow';
        end
    end
    switch colorMap
        case 'lines10'
            ColorSet = lines10(numberOfColors);
        case 'rainbow'
            %Take care of the anomalies
            if numberOfColors <= 5
                ColorSet = [0 1 0
                    0 1 1
                    0 0 1
                    1 0 1
                    1 0 0];
                ColorSet = ColorSet(1:numberOfColors,:);
                return
            end
            %we have 5 segments to distribute the plots
            EachSec=floor(numberOfColors/5);
            
            %how many extra lines are there?
            ExtraPlots=mod(numberOfColors,5);
            
            %initialize our vector
            ColorSet=zeros(numberOfColors,3);
            
            %This is to deal with the extra plots that don't fit nicely into the
            %segments
            Adjust=zeros(1,5);
            for m=1:ExtraPlots
                Adjust(m)=1;
            end
            
            SecOne   =EachSec+Adjust(1);
            SecTwo   =EachSec+Adjust(2);
            SecThree =EachSec+Adjust(3);
            SecFour  =EachSec+Adjust(4);
            SecFive  =EachSec;
            
            for m=1:SecOne
                ColorSet(m,:)=[0 1 (m-1)/(SecOne-1)];
            end
            
            for m=1:SecTwo
                ColorSet(m+SecOne,:)=[0 (SecTwo-m)/(SecTwo) 1];
            end
            
            for m=1:SecThree
                ColorSet(m+SecOne+SecTwo,:)=[(m)/(SecThree) 0 1];
            end
            
            for m=1:SecFour
                ColorSet(m+SecOne+SecTwo+SecThree,:)=[1 0 (SecFour-m)/(SecFour)];
            end
            
            for m=1:SecFive
                ColorSet(m+SecOne+SecTwo+SecThree+SecFour,:)=[(SecFive-m)/(SecFive) 0 0];
            end
        case 'viridis'
            ColorSet = viridis(numberOfColors);
        case 'colorbrewer'
            % you should paste a cell array of exported javascript rgb values
            m = [cellfun(@eval,varybrightness,'uniformoutput',0)];
            varybrightness = 0;
            m = vertcat(m{:});
            ColorSet = varycolor(numberOfColors,m);
        case 'gallery'
            figure;
            shows = {8 'auto' 0
                100 'auto' 0
                8 'red' 0
                10 'blue' 0
                10 'jet' 0
                100 'bone' 0
                3 '-red' 0
                7 '-blue' 0
                100 [255 255 178;189 0 0]/255 0
                100 [255 127 0;0 127 127]/255 1
                100 [255 127 0;0 127 127]/255 -1
                100 'colorbrewer' {'rgb(241,238,246)','rgb(189,201,225)','rgb(116,169,207)','rgb(43,140,190)','rgb(4,90,141)'}};
            for i = 1:size(shows,1)
                subplot(3,4,i)
                imthis(varycolor(shows{i,:}))
                if ischar(shows{i,2})
                    titstr = shows{i,2};
                else
                    titstr = ['custom colors'];
                end
                if ~iscell(shows{i,3}) && shows{i,3} ~= 0
                    if shows{i,3} > 0
                        titstr = {titstr 'varybrightness'};
                    else
                        titstr = {titstr '-varybrightness'};
                    end
                end
                title(titstr)
            end
        otherwise
            if strncmp(colorMap,'-',1)
                reversecolorSet = 1;
                colorMap = colorMap(2:end);
            else
                reversecolorSet = 0;
            end
            try 
                ColorSet = eval([colorMap '(' num2str(numberOfColors) ')']);
                if reversecolorSet
                    ColorSet = ColorSet(end:-1:1,:);
                end
            catch
                error('unknown colormap');
            end
    end
end
if varybrightness ~= 0
    ColorBright = rgb2hsv(ColorSet);
    if varybrightness > 0
        allbright = linspace(min(ColorBright(:,3)),max(ColorBright(:,3)),size(ColorBright,1));
    else
        allbright = linspace(max(ColorBright(:,3)),min(ColorBright(:,3)),size(ColorBright,1));
    end
    ColorBright(:,3) = allbright;
    ColorSet = hsv2rgb(ColorBright);
end
if showit
    figure('color','w');
    imagesc(1:size(ColorSet,1)');
    colormap(ColorSet)
    axis off
end

function colorMap = lines10(n)
%LINES10  Color colorMap with the line colors.
%   LINES10(M) returns an M-by-3 matrix containing a "ColorOrder"
%   colormap. LINES10, by itself, is the same length as the current
%   colormap.
%   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

if nargin<1, n = 10; end

c = [0,0,1
    0,0.5,0
    .8 0 0
    0,0.75,0.75
    0.75,0,0.75
    0.75,0.75,0
    0.3 .3 .3
    0,.7,0
    0.5,0.5,0
    0,0.5,0.5];


colorMap = c(rem(0:n-1,size(c,1))+1,:);

function imthis(cmap)

imagesc(permute(cmap,[1 3 2]))
axis off xy

function cols = rgb(r,g,b)
cols = [r g b]/255;

function cols = viridis(numberOfColors)

viridis = [...
0.26700401  0.00487433  0.32941519
0.26851048  0.00960483  0.33542652
0.26994384  0.01462494  0.34137895
0.27130489  0.01994186  0.34726862
0.27259384  0.02556309  0.35309303
0.27380934  0.03149748  0.35885256
0.27495242  0.03775181  0.36454323
0.27602238  0.04416723  0.37016418
0.2770184   0.05034437  0.37571452
0.27794143  0.05632444  0.38119074
0.27879067  0.06214536  0.38659204
0.2795655   0.06783587  0.39191723
0.28026658  0.07341724  0.39716349
0.28089358  0.07890703  0.40232944
0.28144581  0.0843197   0.40741404
0.28192358  0.08966622  0.41241521
0.28232739  0.09495545  0.41733086
0.28265633  0.10019576  0.42216032
0.28291049  0.10539345  0.42690202
0.28309095  0.11055307  0.43155375
0.28319704  0.11567966  0.43611482
0.28322882  0.12077701  0.44058404
0.28318684  0.12584799  0.44496   
0.283072    0.13089477  0.44924127
0.28288389  0.13592005  0.45342734
0.28262297  0.14092556  0.45751726
0.28229037  0.14591233  0.46150995
0.28188676  0.15088147  0.46540474
0.28141228  0.15583425  0.46920128
0.28086773  0.16077132  0.47289909
0.28025468  0.16569272  0.47649762
0.27957399  0.17059884  0.47999675
0.27882618  0.1754902   0.48339654
0.27801236  0.18036684  0.48669702
0.27713437  0.18522836  0.48989831
0.27619376  0.19007447  0.49300074
0.27519116  0.1949054   0.49600488
0.27412802  0.19972086  0.49891131
0.27300596  0.20452049  0.50172076
0.27182812  0.20930306  0.50443413
0.27059473  0.21406899  0.50705243
0.26930756  0.21881782  0.50957678
0.26796846  0.22354911  0.5120084 
0.26657984  0.2282621   0.5143487 
0.2651445   0.23295593  0.5165993 
0.2636632   0.23763078  0.51876163
0.26213801  0.24228619  0.52083736
0.26057103  0.2469217   0.52282822
0.25896451  0.25153685  0.52473609
0.25732244  0.2561304   0.52656332
0.25564519  0.26070284  0.52831152
0.25393498  0.26525384  0.52998273
0.25219404  0.26978306  0.53157905
0.25042462  0.27429024  0.53310261
0.24862899  0.27877509  0.53455561
0.2468114   0.28323662  0.53594093
0.24497208  0.28767547  0.53726018
0.24311324  0.29209154  0.53851561
0.24123708  0.29648471  0.53970946
0.23934575  0.30085494  0.54084398
0.23744138  0.30520222  0.5419214 
0.23552606  0.30952657  0.54294396
0.23360277  0.31382773  0.54391424
0.2316735   0.3181058   0.54483444
0.22973926  0.32236127  0.54570633
0.22780192  0.32659432  0.546532  
0.2258633   0.33080515  0.54731353
0.22392515  0.334994    0.54805291
0.22198915  0.33916114  0.54875211
0.22005691  0.34330688  0.54941304
0.21812995  0.34743154  0.55003755
0.21620971  0.35153548  0.55062743
0.21429757  0.35561907  0.5511844 
0.21239477  0.35968273  0.55171011
0.2105031   0.36372671  0.55220646
0.20862342  0.36775151  0.55267486
0.20675628  0.37175775  0.55311653
0.20490257  0.37574589  0.55353282
0.20306309  0.37971644  0.55392505
0.20123854  0.38366989  0.55429441
0.1994295   0.38760678  0.55464205
0.1976365   0.39152762  0.55496905
0.19585993  0.39543297  0.55527637
0.19410009  0.39932336  0.55556494
0.19235719  0.40319934  0.55583559
0.19063135  0.40706148  0.55608907
0.18892259  0.41091033  0.55632606
0.18723083  0.41474645  0.55654717
0.18555593  0.4185704   0.55675292
0.18389763  0.42238275  0.55694377
0.18225561  0.42618405  0.5571201 
0.18062949  0.42997486  0.55728221
0.17901879  0.43375572  0.55743035
0.17742298  0.4375272   0.55756466
0.17584148  0.44128981  0.55768526
0.17427363  0.4450441   0.55779216
0.17271876  0.4487906   0.55788532
0.17117615  0.4525298   0.55796464
0.16964573  0.45626209  0.55803034
0.16812641  0.45998802  0.55808199
0.1666171   0.46370813  0.55811913
0.16511703  0.4674229   0.55814141
0.16362543  0.47113278  0.55814842
0.16214155  0.47483821  0.55813967
0.16066467  0.47853961  0.55811466
0.15919413  0.4822374   0.5580728 
0.15772933  0.48593197  0.55801347
0.15626973  0.4896237   0.557936  
0.15481488  0.49331293  0.55783967
0.15336445  0.49700003  0.55772371
0.1519182   0.50068529  0.55758733
0.15047605  0.50436904  0.55742968
0.14903918  0.50805136  0.5572505 
0.14760731  0.51173263  0.55704861
0.14618026  0.51541316  0.55682271
0.14475863  0.51909319  0.55657181
0.14334327  0.52277292  0.55629491
0.14193527  0.52645254  0.55599097
0.14053599  0.53013219  0.55565893
0.13914708  0.53381201  0.55529773
0.13777048  0.53749213  0.55490625
0.1364085   0.54117264  0.55448339
0.13506561  0.54485335  0.55402906
0.13374299  0.54853458  0.55354108
0.13244401  0.55221637  0.55301828
0.13117249  0.55589872  0.55245948
0.1299327   0.55958162  0.55186354
0.12872938  0.56326503  0.55122927
0.12756771  0.56694891  0.55055551
0.12645338  0.57063316  0.5498411 
0.12539383  0.57431754  0.54908564
0.12439474  0.57800205  0.5482874 
0.12346281  0.58168661  0.54744498
0.12260562  0.58537105  0.54655722
0.12183122  0.58905521  0.54562298
0.12114807  0.59273889  0.54464114
0.12056501  0.59642187  0.54361058
0.12009154  0.60010387  0.54253043
0.11973756  0.60378459  0.54139999
0.11951163  0.60746388  0.54021751
0.11942341  0.61114146  0.53898192
0.11948255  0.61481702  0.53769219
0.11969858  0.61849025  0.53634733
0.12008079  0.62216081  0.53494633
0.12063824  0.62582833  0.53348834
0.12137972  0.62949242  0.53197275
0.12231244  0.63315277  0.53039808
0.12344358  0.63680899  0.52876343
0.12477953  0.64046069  0.52706792
0.12632581  0.64410744  0.52531069
0.12808703  0.64774881  0.52349092
0.13006688  0.65138436  0.52160791
0.13226797  0.65501363  0.51966086
0.13469183  0.65863619  0.5176488 
0.13733921  0.66225157  0.51557101
0.14020991  0.66585927  0.5134268 
0.14330291  0.66945881  0.51121549
0.1466164   0.67304968  0.50893644
0.15014782  0.67663139  0.5065889 
0.15389405  0.68020343  0.50417217
0.15785146  0.68376525  0.50168574
0.16201598  0.68731632  0.49912906
0.1663832   0.69085611  0.49650163
0.1709484   0.69438405  0.49380294
0.17570671  0.6978996   0.49103252
0.18065314  0.70140222  0.48818938
0.18578266  0.70489133  0.48527326
0.19109018  0.70836635  0.48228395
0.19657063  0.71182668  0.47922108
0.20221902  0.71527175  0.47608431
0.20803045  0.71870095  0.4728733 
0.21400015  0.72211371  0.46958774
0.22012381  0.72550945  0.46622638
0.2263969   0.72888753  0.46278934
0.23281498  0.73224735  0.45927675
0.2393739   0.73558828  0.45568838
0.24606968  0.73890972  0.45202405
0.25289851  0.74221104  0.44828355
0.25985676  0.74549162  0.44446673
0.26694127  0.74875084  0.44057284
0.27414922  0.75198807  0.4366009 
0.28147681  0.75520266  0.43255207
0.28892102  0.75839399  0.42842626
0.29647899  0.76156142  0.42422341
0.30414796  0.76470433  0.41994346
0.31192534  0.76782207  0.41558638
0.3198086   0.77091403  0.41115215
0.3277958   0.77397953  0.40664011
0.33588539  0.7770179   0.40204917
0.34407411  0.78002855  0.39738103
0.35235985  0.78301086  0.39263579
0.36074053  0.78596419  0.38781353
0.3692142   0.78888793  0.38291438
0.37777892  0.79178146  0.3779385 
0.38643282  0.79464415  0.37288606
0.39517408  0.79747541  0.36775726
0.40400101  0.80027461  0.36255223
0.4129135   0.80304099  0.35726893
0.42190813  0.80577412  0.35191009
0.43098317  0.80847343  0.34647607
0.44013691  0.81113836  0.3409673 
0.44936763  0.81376835  0.33538426
0.45867362  0.81636288  0.32972749
0.46805314  0.81892143  0.32399761
0.47750446  0.82144351  0.31819529
0.4870258   0.82392862  0.31232133
0.49661536  0.82637633  0.30637661
0.5062713   0.82878621  0.30036211
0.51599182  0.83115784  0.29427888
0.52577622  0.83349064  0.2881265 
0.5356211   0.83578452  0.28190832
0.5455244   0.83803918  0.27562602
0.55548397  0.84025437  0.26928147
0.5654976   0.8424299   0.26287683
0.57556297  0.84456561  0.25641457
0.58567772  0.84666139  0.24989748
0.59583934  0.84871722  0.24332878
0.60604528  0.8507331   0.23671214
0.61629283  0.85270912  0.23005179
0.62657923  0.85464543  0.22335258
0.63690157  0.85654226  0.21662012
0.64725685  0.85839991  0.20986086
0.65764197  0.86021878  0.20308229
0.66805369  0.86199932  0.19629307
0.67848868  0.86374211  0.18950326
0.68894351  0.86544779  0.18272455
0.69941463  0.86711711  0.17597055
0.70989842  0.86875092  0.16925712
0.72039115  0.87035015  0.16260273
0.73088902  0.87191584  0.15602894
0.74138803  0.87344918  0.14956101
0.75188414  0.87495143  0.14322828
0.76237342  0.87642392  0.13706449
0.77285183  0.87786808  0.13110864
0.78331535  0.87928545  0.12540538
0.79375994  0.88067763  0.12000532
0.80418159  0.88204632  0.11496505
0.81457634  0.88339329  0.11034678
0.82494028  0.88472036  0.10621724
0.83526959  0.88602943  0.1026459 
0.84556056  0.88732243  0.09970219
0.8558096   0.88860134  0.09745186
0.86601325  0.88986815  0.09595277
0.87616824  0.89112487  0.09525046
0.88627146  0.89237353  0.09537439
0.89632002  0.89361614  0.09633538
0.90631121  0.89485467  0.09812496
0.91624212  0.89609127  0.1007168 
0.92610579  0.89732977  0.10407067
0.93590444  0.8985704   0.10813094
0.94563626  0.899815    0.11283773
0.95529972  0.90106534  0.11812832
0.96489353  0.90232311  0.12394051
0.97441665  0.90358991  0.13021494
0.98386829  0.90486726  0.13689671
0.99324789  0.90615657  0.1439362]; 

idx = round(linspace(1,size(viridis,1),numberOfColors));
cols = viridis(idx,:);


function [rgb] = colors(name)

% [rgb] = colors(name)
% 
% return the RGB triplet for a named color
% names are taken from the 657 default colors from R (colors())
%
% colors(list) returns the list of all names
% 
% colors or colors('gallery')
%
% opens an interactive window to select a color.
%
%

% v0. Max 2016

if nargin == 0
    name = 'gallery';
end

cols = {
    'white'	255	255	255
    'aliceblue'	240	248	255
    'antiquewhite'	250	235	215
    'antiquewhite1'	255	239	219
    'antiquewhite2'	238	223	204
    'antiquewhite3'	205	192	176
    'antiquewhite4'	139	131	120
    'aquamarine'	127	255	212
    'aquamarine1'	127	255	212
    'aquamarine2'	118	238	198
    'aquamarine3'	102	205	170
    'aquamarine4'	69	139	116
    'azure'	240	255	255
    'azure1'	240	255	255
    'azure2'	224	238	238
    'azure3'	193	205	205
    'azure4'	131	139	139
    'beige'	245	245	220
    'bisque'	255	228	196
    'bisque1'	255	228	196
    'bisque2'	238	213	183
    'bisque3'	205	183	158
    'bisque4'	139	125	107
    'black'	0	0	0
    'blanchedalmond'	255	235	205
    'blue'	0	0	255
    'blue1'	0	0	255
    'blue2'	0	0	238
    'blue3'	0	0	205
    'blue4'	0	0	139
    'blueviolet'	138	43	226
    'brown'	165	42	42
    'brown1'	255	64	64
    'brown2'	238	59	59
    'brown3'	205	51	51
    'brown4'	139	35	35
    'burlywood'	222	184	135
    'burlywood1'	255	211	155
    'burlywood2'	238	197	145
    'burlywood3'	205	170	125
    'burlywood4'	139	115	85
    'cadetblue'	95	158	160
    'cadetblue1'	152	245	255
    'cadetblue2'	142	229	238
    'cadetblue3'	122	197	205
    'cadetblue4'	83	134	139
    'chartreuse'	127	255	0
    'chartreuse1'	127	255	0
    'chartreuse2'	118	238	0
    'chartreuse3'	102	205	0
    'chartreuse4'	69	139	0
    'chocolate'	210	105	30
    'chocolate1'	255	127	36
    'chocolate2'	238	118	33
    'chocolate3'	205	102	29
    'chocolate4'	139	69	19
    'coral'	255	127	80
    'coral1'	255	114	86
    'coral2'	238	106	80
    'coral3'	205	91	69
    'coral4'	139	62	47
    'cornflowerblue'	100	149	237
    'cornsilk'	255	248	220
    'cornsilk1'	255	248	220
    'cornsilk2'	238	232	205
    'cornsilk3'	205	200	177
    'cornsilk4'	139	136	120
    'cyan'	0	255	255
    'cyan1'	0	255	255
    'cyan2'	0	238	238
    'cyan3'	0	205	205
    'cyan4'	0	139	139
    'darkblue'	0	0	139
    'darkcyan'	0	139	139
    'darkgoldenrod'	184	134	11
    'darkgoldenrod1'	255	185	15
    'darkgoldenrod2'	238	173	14
    'darkgoldenrod3'	205	149	12
    'darkgoldenrod4'	139	101	8
    'darkgray'	169	169	169
    'darkgreen'	0	100	0
    'darkgrey'	169	169	169
    'darkkhaki'	189	183	107
    'darkmagenta'	139	0	139
    'darkolivegreen'	85	107	47
    'darkolivegreen1'	202	255	112
    'darkolivegreen2'	188	238	104
    'darkolivegreen3'	162	205	90
    'darkolivegreen4'	110	139	61
    'darkorange'	255	140	0
    'darkorange1'	255	127	0
    'darkorange2'	238	118	0
    'darkorange3'	205	102	0
    'darkorange4'	139	69	0
    'darkorchid'	153	50	204
    'darkorchid1'	191	62	255
    'darkorchid2'	178	58	238
    'darkorchid3'	154	50	205
    'darkorchid4'	104	34	139
    'darkred'	139	0	0
    'darksalmon'	233	150	122
    'darkseagreen'	143	188	143
    'darkseagreen1'	193	255	193
    'darkseagreen2'	180	238	180
    'darkseagreen3'	155	205	155
    'darkseagreen4'	105	139	105
    'darkslateblue'	72	61	139
    'darkslategray'	47	79	79
    'darkslategray1'	151	255	255
    'darkslategray2'	141	238	238
    'darkslategray3'	121	205	205
    'darkslategray4'	82	139	139
    'darkslategrey'	47	79	79
    'darkturquoise'	0	206	209
    'darkviolet'	148	0	211
    'deeppink'	255	20	147
    'deeppink1'	255	20	147
    'deeppink2'	238	18	137
    'deeppink3'	205	16	118
    'deeppink4'	139	10	80
    'deepskyblue'	0	191	255
    'deepskyblue1'	0	191	255
    'deepskyblue2'	0	178	238
    'deepskyblue3'	0	154	205
    'deepskyblue4'	0	104	139
    'dimgray'	105	105	105
    'dimgrey'	105	105	105
    'dodgerblue'	30	144	255
    'dodgerblue1'	30	144	255
    'dodgerblue2'	28	134	238
    'dodgerblue3'	24	116	205
    'dodgerblue4'	16	78	139
    'firebrick'	178	34	34
    'firebrick1'	255	48	48
    'firebrick2'	238	44	44
    'firebrick3'	205	38	38
    'firebrick4'	139	26	26
    'floralwhite'	255	250	240
    'forestgreen'	34	139	34
    'gainsboro'	220	220	220
    'ghostwhite'	248	248	255
    'gold'	255	215	0
    'gold1'	255	215	0
    'gold2'	238	201	0
    'gold3'	205	173	0
    'gold4'	139	117	0
    'goldenrod'	218	165	32
    'goldenrod1'	255	193	37
    'goldenrod2'	238	180	34
    'goldenrod3'	205	155	29
    'goldenrod4'	139	105	20
    'gray'	190	190	190
    'gray0'	0	0	0
    'gray1'	3	3	3
    'gray2'	5	5	5
    'gray3'	8	8	8
    'gray4'	10	10	10
    'gray5'	13	13	13
    'gray6'	15	15	15
    'gray7'	18	18	18
    'gray8'	20	20	20
    'gray9'	23	23	23
    'gray10'	26	26	26
    'gray11'	28	28	28
    'gray12'	31	31	31
    'gray13'	33	33	33
    'gray14'	36	36	36
    'gray15'	38	38	38
    'gray16'	41	41	41
    'gray17'	43	43	43
    'gray18'	46	46	46
    'gray19'	48	48	48
    'gray20'	51	51	51
    'gray21'	54	54	54
    'gray22'	56	56	56
    'gray23'	59	59	59
    'gray24'	61	61	61
    'gray25'	64	64	64
    'gray26'	66	66	66
    'gray27'	69	69	69
    'gray28'	71	71	71
    'gray29'	74	74	74
    'gray30'	77	77	77
    'gray31'	79	79	79
    'gray32'	82	82	82
    'gray33'	84	84	84
    'gray34'	87	87	87
    'gray35'	89	89	89
    'gray36'	92	92	92
    'gray37'	94	94	94
    'gray38'	97	97	97
    'gray39'	99	99	99
    'gray40'	102	102	102
    'gray41'	105	105	105
    'gray42'	107	107	107
    'gray43'	110	110	110
    'gray44'	112	112	112
    'gray45'	115	115	115
    'gray46'	117	117	117
    'gray47'	120	120	120
    'gray48'	122	122	122
    'gray49'	125	125	125
    'gray50'	127	127	127
    'gray51'	130	130	130
    'gray52'	133	133	133
    'gray53'	135	135	135
    'gray54'	138	138	138
    'gray55'	140	140	140
    'gray56'	143	143	143
    'gray57'	145	145	145
    'gray58'	148	148	148
    'gray59'	150	150	150
    'gray60'	153	153	153
    'gray61'	156	156	156
    'gray62'	158	158	158
    'gray63'	161	161	161
    'gray64'	163	163	163
    'gray65'	166	166	166
    'gray66'	168	168	168
    'gray67'	171	171	171
    'gray68'	173	173	173
    'gray69'	176	176	176
    'gray70'	179	179	179
    'gray71'	181	181	181
    'gray72'	184	184	184
    'gray73'	186	186	186
    'gray74'	189	189	189
    'gray75'	191	191	191
    'gray76'	194	194	194
    'gray77'	196	196	196
    'gray78'	199	199	199
    'gray79'	201	201	201
    'gray80'	204	204	204
    'gray81'	207	207	207
    'gray82'	209	209	209
    'gray83'	212	212	212
    'gray84'	214	214	214
    'gray85'	217	217	217
    'gray86'	219	219	219
    'gray87'	222	222	222
    'gray88'	224	224	224
    'gray89'	227	227	227
    'gray90'	229	229	229
    'gray91'	232	232	232
    'gray92'	235	235	235
    'gray93'	237	237	237
    'gray94'	240	240	240
    'gray95'	242	242	242
    'gray96'	245	245	245
    'gray97'	247	247	247
    'gray98'	250	250	250
    'gray99'	252	252	252
    'gray100'	255	255	255
    'green'	0	255	0
    'green1'	0	255	0
    'green2'	0	238	0
    'green3'	0	205	0
    'green4'	0	139	0
    'greenyellow'	173	255	47
    'grey'	190	190	190
    'grey0'	0	0	0
    'grey1'	3	3	3
    'grey2'	5	5	5
    'grey3'	8	8	8
    'grey4'	10	10	10
    'grey5'	13	13	13
    'grey6'	15	15	15
    'grey7'	18	18	18
    'grey8'	20	20	20
    'grey9'	23	23	23
    'grey10'	26	26	26
    'grey11'	28	28	28
    'grey12'	31	31	31
    'grey13'	33	33	33
    'grey14'	36	36	36
    'grey15'	38	38	38
    'grey16'	41	41	41
    'grey17'	43	43	43
    'grey18'	46	46	46
    'grey19'	48	48	48
    'grey20'	51	51	51
    'grey21'	54	54	54
    'grey22'	56	56	56
    'grey23'	59	59	59
    'grey24'	61	61	61
    'grey25'	64	64	64
    'grey26'	66	66	66
    'grey27'	69	69	69
    'grey28'	71	71	71
    'grey29'	74	74	74
    'grey30'	77	77	77
    'grey31'	79	79	79
    'grey32'	82	82	82
    'grey33'	84	84	84
    'grey34'	87	87	87
    'grey35'	89	89	89
    'grey36'	92	92	92
    'grey37'	94	94	94
    'grey38'	97	97	97
    'grey39'	99	99	99
    'grey40'	102	102	102
    'grey41'	105	105	105
    'grey42'	107	107	107
    'grey43'	110	110	110
    'grey44'	112	112	112
    'grey45'	115	115	115
    'grey46'	117	117	117
    'grey47'	120	120	120
    'grey48'	122	122	122
    'grey49'	125	125	125
    'grey50'	127	127	127
    'grey51'	130	130	130
    'grey52'	133	133	133
    'grey53'	135	135	135
    'grey54'	138	138	138
    'grey55'	140	140	140
    'grey56'	143	143	143
    'grey57'	145	145	145
    'grey58'	148	148	148
    'grey59'	150	150	150
    'grey60'	153	153	153
    'grey61'	156	156	156
    'grey62'	158	158	158
    'grey63'	161	161	161
    'grey64'	163	163	163
    'grey65'	166	166	166
    'grey66'	168	168	168
    'grey67'	171	171	171
    'grey68'	173	173	173
    'grey69'	176	176	176
    'grey70'	179	179	179
    'grey71'	181	181	181
    'grey72'	184	184	184
    'grey73'	186	186	186
    'grey74'	189	189	189
    'grey75'	191	191	191
    'grey76'	194	194	194
    'grey77'	196	196	196
    'grey78'	199	199	199
    'grey79'	201	201	201
    'grey80'	204	204	204
    'grey81'	207	207	207
    'grey82'	209	209	209
    'grey83'	212	212	212
    'grey84'	214	214	214
    'grey85'	217	217	217
    'grey86'	219	219	219
    'grey87'	222	222	222
    'grey88'	224	224	224
    'grey89'	227	227	227
    'grey90'	229	229	229
    'grey91'	232	232	232
    'grey92'	235	235	235
    'grey93'	237	237	237
    'grey94'	240	240	240
    'grey95'	242	242	242
    'grey96'	245	245	245
    'grey97'	247	247	247
    'grey98'	250	250	250
    'grey99'	252	252	252
    'grey100'	255	255	255
    'honeydew'	240	255	240
    'honeydew1'	240	255	240
    'honeydew2'	224	238	224
    'honeydew3'	193	205	193
    'honeydew4'	131	139	131
    'hotpink'	255	105	180
    'hotpink1'	255	110	180
    'hotpink2'	238	106	167
    'hotpink3'	205	96	144
    'hotpink4'	139	58	98
    'indianred'	205	92	92
    'indianred1'	255	106	106
    'indianred2'	238	99	99
    'indianred3'	205	85	85
    'indianred4'	139	58	58
    'ivory'	255	255	240
    'ivory1'	255	255	240
    'ivory2'	238	238	224
    'ivory3'	205	205	193
    'ivory4'	139	139	131
    'khaki'	240	230	140
    'khaki1'	255	246	143
    'khaki2'	238	230	133
    'khaki3'	205	198	115
    'khaki4'	139	134	78
    'lavender'	230	230	250
    'lavenderblush'	255	240	245
    'lavenderblush1'	255	240	245
    'lavenderblush2'	238	224	229
    'lavenderblush3'	205	193	197
    'lavenderblush4'	139	131	134
    'lawngreen'	124	252	0
    'lemonchiffon'	255	250	205
    'lemonchiffon1'	255	250	205
    'lemonchiffon2'	238	233	191
    'lemonchiffon3'	205	201	165
    'lemonchiffon4'	139	137	112
    'lightblue'	173	216	230
    'lightblue1'	191	239	255
    'lightblue2'	178	223	238
    'lightblue3'	154	192	205
    'lightblue4'	104	131	139
    'lightcoral'	240	128	128
    'lightcyan'	224	255	255
    'lightcyan1'	224	255	255
    'lightcyan2'	209	238	238
    'lightcyan3'	180	205	205
    'lightcyan4'	122	139	139
    'lightgoldenrod'	238	221	130
    'lightgoldenrod1'	255	236	139
    'lightgoldenrod2'	238	220	130
    'lightgoldenrod3'	205	190	112
    'lightgoldenrod4'	139	129	76
    'lightgoldenrodyellow'	250	250	210
    'lightgray'	211	211	211
    'lightgreen'	144	238	144
    'lightgrey'	211	211	211
    'lightpink'	255	182	193
    'lightpink1'	255	174	185
    'lightpink2'	238	162	173
    'lightpink3'	205	140	149
    'lightpink4'	139	95	101
    'lightsalmon'	255	160	122
    'lightsalmon1'	255	160	122
    'lightsalmon2'	238	149	114
    'lightsalmon3'	205	129	98
    'lightsalmon4'	139	87	66
    'lightseagreen'	32	178	170
    'lightskyblue'	135	206	250
    'lightskyblue1'	176	226	255
    'lightskyblue2'	164	211	238
    'lightskyblue3'	141	182	205
    'lightskyblue4'	96	123	139
    'lightslateblue'	132	112	255
    'lightslategray'	119	136	153
    'lightslategrey'	119	136	153
    'lightsteelblue'	176	196	222
    'lightsteelblue1'	202	225	255
    'lightsteelblue2'	188	210	238
    'lightsteelblue3'	162	181	205
    'lightsteelblue4'	110	123	139
    'lightyellow'	255	255	224
    'lightyellow1'	255	255	224
    'lightyellow2'	238	238	209
    'lightyellow3'	205	205	180
    'lightyellow4'	139	139	122
    'limegreen'	50	205	50
    'linen'	250	240	230
    'magenta'	255	0	255
    'magenta1'	255	0	255
    'magenta2'	238	0	238
    'magenta3'	205	0	205
    'magenta4'	139	0	139
    'maroon'	176	48	96
    'maroon1'	255	52	179
    'maroon2'	238	48	167
    'maroon3'	205	41	144
    'maroon4'	139	28	98
    'mediumaquamarine'	102	205	170
    'mediumblue'	0	0	205
    'mediumorchid'	186	85	211
    'mediumorchid1'	224	102	255
    'mediumorchid2'	209	95	238
    'mediumorchid3'	180	82	205
    'mediumorchid4'	122	55	139
    'mediumpurple'	147	112	219
    'mediumpurple1'	171	130	255
    'mediumpurple2'	159	121	238
    'mediumpurple3'	137	104	205
    'mediumpurple4'	93	71	139
    'mediumseagreen'	60	179	113
    'mediumslateblue'	123	104	238
    'mediumspringgreen'	0	250	154
    'mediumturquoise'	72	209	204
    'mediumvioletred'	199	21	133
    'midnightblue'	25	25	112
    'mintcream'	245	255	250
    'mistyrose'	255	228	225
    'mistyrose1'	255	228	225
    'mistyrose2'	238	213	210
    'mistyrose3'	205	183	181
    'mistyrose4'	139	125	123
    'moccasin'	255	228	181
    'navajowhite'	255	222	173
    'navajowhite1'	255	222	173
    'navajowhite2'	238	207	161
    'navajowhite3'	205	179	139
    'navajowhite4'	139	121	94
    'navy'	0	0	128
    'navyblue'	0	0	128
    'oldlace'	253	245	230
    'olivedrab'	107	142	35
    'olivedrab1'	192	255	62
    'olivedrab2'	179	238	58
    'olivedrab3'	154	205	50
    'olivedrab4'	105	139	34
    'orange'	255	165	0
    'orange1'	255	165	0
    'orange2'	238	154	0
    'orange3'	205	133	0
    'orange4'	139	90	0
    'orangered'	255	69	0
    'orangered1'	255	69	0
    'orangered2'	238	64	0
    'orangered3'	205	55	0
    'orangered4'	139	37	0
    'orchid'	218	112	214
    'orchid1'	255	131	250
    'orchid2'	238	122	233
    'orchid3'	205	105	201
    'orchid4'	139	71	137
    'palegoldenrod'	238	232	170
    'palegreen'	152	251	152
    'palegreen1'	154	255	154
    'palegreen2'	144	238	144
    'palegreen3'	124	205	124
    'palegreen4'	84	139	84
    'paleturquoise'	175	238	238
    'paleturquoise1'	187	255	255
    'paleturquoise2'	174	238	238
    'paleturquoise3'	150	205	205
    'paleturquoise4'	102	139	139
    'palevioletred'	219	112	147
    'palevioletred1'	255	130	171
    'palevioletred2'	238	121	159
    'palevioletred3'	205	104	137
    'palevioletred4'	139	71	93
    'papayawhip'	255	239	213
    'peachpuff'	255	218	185
    'peachpuff1'	255	218	185
    'peachpuff2'	238	203	173
    'peachpuff3'	205	175	149
    'peachpuff4'	139	119	101
    'peru'	205	133	63
    'pink'	255	192	203
    'pink1'	255	181	197
    'pink2'	238	169	184
    'pink3'	205	145	158
    'pink4'	139	99	108
    'plum'	221	160	221
    'plum1'	255	187	255
    'plum2'	238	174	238
    'plum3'	205	150	205
    'plum4'	139	102	139
    'powderblue'	176	224	230
    'purple'	160	32	240
    'purple1'	155	48	255
    'purple2'	145	44	238
    'purple3'	125	38	205
    'purple4'	85	26	139
    'red'	255	0	0
    'red1'	255	0	0
    'red2'	238	0	0
    'red3'	205	0	0
    'red4'	139	0	0
    'rosybrown'	188	143	143
    'rosybrown1'	255	193	193
    'rosybrown2'	238	180	180
    'rosybrown3'	205	155	155
    'rosybrown4'	139	105	105
    'royalblue'	65	105	225
    'royalblue1'	72	118	255
    'royalblue2'	67	110	238
    'royalblue3'	58	95	205
    'royalblue4'	39	64	139
    'saddlebrown'	139	69	19
    'salmon'	250	128	114
    'salmon1'	255	140	105
    'salmon2'	238	130	98
    'salmon3'	205	112	84
    'salmon4'	139	76	57
    'sandybrown'	244	164	96
    'seagreen'	46	139	87
    'seagreen1'	84	255	159
    'seagreen2'	78	238	148
    'seagreen3'	67	205	128
    'seagreen4'	46	139	87
    'seashell'	255	245	238
    'seashell1'	255	245	238
    'seashell2'	238	229	222
    'seashell3'	205	197	191
    'seashell4'	139	134	130
    'sienna'	160	82	45
    'sienna1'	255	130	71
    'sienna2'	238	121	66
    'sienna3'	205	104	57
    'sienna4'	139	71	38
    'skyblue'	135	206	235
    'skyblue1'	135	206	255
    'skyblue2'	126	192	238
    'skyblue3'	108	166	205
    'skyblue4'	74	112	139
    'slateblue'	106	90	205
    'slateblue1'	131	111	255
    'slateblue2'	122	103	238
    'slateblue3'	105	89	205
    'slateblue4'	71	60	139
    'slategray'	112	128	144
    'slategray1'	198	226	255
    'slategray2'	185	211	238
    'slategray3'	159	182	205
    'slategray4'	108	123	139
    'slategrey'	112	128	144
    'snow'	255	250	250
    'snow1'	255	250	250
    'snow2'	238	233	233
    'snow3'	205	201	201
    'snow4'	139	137	137
    'springgreen'	0	255	127
    'springgreen1'	0	255	127
    'springgreen2'	0	238	118
    'springgreen3'	0	205	102
    'springgreen4'	0	139	69
    'steelblue'	70	130	180
    'steelblue1'	99	184	255
    'steelblue2'	92	172	238
    'steelblue3'	79	148	205
    'steelblue4'	54	100	139
    'tan'	210	180	140
    'tan1'	255	165	79
    'tan2'	238	154	73
    'tan3'	205	133	63
    'tan4'	139	90	43
    'thistle'	216	191	216
    'thistle1'	255	225	255
    'thistle2'	238	210	238
    'thistle3'	205	181	205
    'thistle4'	139	123	139
    'tomato'	255	99	71
    'tomato1'	255	99	71
    'tomato2'	238	92	66
    'tomato3'	205	79	57
    'tomato4'	139	54	38
    'turquoise'	64	224	208
    'turquoise1'	0	245	255
    'turquoise2'	0	229	238
    'turquoise3'	0	197	205
    'turquoise4'	0	134	139
    'violet'	238	130	238
    'violetred'	208	32	144
    'violetred1'	255	62	150
    'violetred2'	238	58	140
    'violetred3'	205	50	120
    'violetred4'	139	34	82
    'wheat'	245	222	179
    'wheat1'	255	231	186
    'wheat2'	238	216	174
    'wheat3'	205	186	150
    'wheat4'	139	126	102
    'whitesmoke'	245	245	245
    'yellow'	255	255	0
    'yellow1'	255	255	0
    'yellow2'	238	238	0
    'yellow3'	205	205	0
    'yellow4'	139	139	0
    'yellowgreen'	154	205	50
    };
cols(:,2:end) = cellfun(@(x)x/255,cols(:,2:end),'uniformoutput',0);

if strcmp(name,'list')
    rgb = cols(:,1);
    return
elseif strcmp(name,'gallery')
    allcols = cell2mat(cols(:,2:end));
    s = size(allcols);
    [r,c,n] = num2rowcol(s(1));
    allcols = padarray(allcols,[n,0],NaN,'post');
    allcols = reshape(allcols,r,c,[]);
    figure(158866);
    set(gcf,'numbertitle','off','name','colors')
    h = imagesc(allcols);
    set(h,'UserData',cols);
    h = datacursormode(gcf);
    set(h,'enable','on','updatefcn',@datatxt);
    return
end

rgb = cell2mat(cols(strcmp(cols(:,1),name),2:end));

function [row, col,n] = num2rowcol(num,R)
% 
% [row col, n] = num2rowcol(num[,R])
% 
% give me the right number of rows and columns for a subplot that will
% incorporate num axes with an approximate square look.
% n is the number of subplots we'll be missing to use all axes
%
% if R is provided, it is the approximate ratio col/row

if not(exist('R','var'))
    R = 1;
end
col =ceil(sqrt( num .* R ));
row = ceil(col./R);
n = col * row - num;

if nargout == 0
    disp([row(:) col(:)])
    clear row col
end

function output_txt = datatxt(~,event_obj)
% ~            Currently not used (empty)
% event_obj    Object containing event data structure
% output_txt   Data cursor text (string or cell array 
%              of strings)

cols = get(event_obj.Target,'UserData');
CData = get(event_obj.Target,'CData');
pos = event_obj.Position;
col = reshape(CData(pos(2),pos(1),:),1,[]);
c = cell2mat(cols(:,2:end));
nm = cols(all(bsxfun(@eq,col,c),2),1);

if not(isempty(nm))
    output_txt = [nm
                ['RGB: ' num2str(col)]];
else
    output_txt = '';
end

disp(output_txt)


