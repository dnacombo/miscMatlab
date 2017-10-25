function[fillhandle] = shadebetween(xpoints,upper,lower,color,edge,transparency)
%USAGE: [fillhandle,msg]=jbfill(xpoints,upper,lower,color,edge,transparency)
%This function will fill a region with a color between the two vectors provided
%using the Matlab fill command.
%
%fillhandle is the returned handle to the filled region in the plot.
%xpoints= The horizontal data points (ie frequencies). Note length(Upper)
%         must equal Length(lower)and must equal length(xpoints)!
%upper = the upper curve values (data can be less than lower)
%lower = the lower curve values (data can be more than upper)
%color = the color of the filled area 
%edge  = the color around the edge of the filled area
%transparency = value ranging from 1 for opaque to 0 for invisible for
%       the filled color only.
%
%John A. Bockstege November 2006;
%Example:
%     a=rand(1,20);%Vector of random data
%     b=a+2*rand(1,20);%2nd vector of data points;
%     x=1:20;%horizontal vector
%     [ph,msg]=jbfill(x,a,b,rand(1,3),rand(1,3),0,rand(1,1))
%     grid on
%     legend('Datr')
if not(exist('transparency','var')) || isempty(transparency)
    transparency=.5;
end
if not(exist('edge','var')) || isempty(edge)
    edge = 'k';
end
if not(exist('color','var')) || isempty(color)
    color = 'b';
end
if isvector(xpoints)
    xpoints = xpoints(:);
end
if isvector(upper)
    upper = upper(:);
end
if isvector(lower)
    lower = lower(:);
end
filled=[upper;flipud(lower)];
xpoints=[xpoints;flipud(xpoints)];
nans = isnan(filled) | isnan(xpoints);
filled(nans) = [];
xpoints(nans) = [];

fillhandle=fill(xpoints,filled,color);%plot the data
set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color

if nargout == 0
    clear fillhandle
end