function app = eq_approx(x,y,dec)

% app = eq_approx(x,y,dec)
% whether x and y are approximately equal at dec decimals.

if not(exist('dec','var'))
    dec = 3;
end

x = round(x .* 10.^dec) .*10 ^dec;
y = round(y .* 10.^dec) .*10 ^dec;
app = x == y;
