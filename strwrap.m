function tw = strwrap(t,n)

% tw = strwrap(text,n_char)
% 
% wrap text array t at n characters taking non alphanumeric characters as
% breaking characters (i.e. not cutting words strangely).

t = deblank(t(:)');
whs = '[\s-]';
tw = '';
while not(isempty(t))
    breaks = regexp(t,whs);
    breaks(end+1) = numel(t);
    idx = 1:min(n,breaks(find(breaks < n, 1,'last')));
    if isempty(idx)
        idx = 1:min(n,numel(t));
    end
    tw(end+1,:) = [ t( idx ) repmat( char( 32 ) , [1 n - numel( idx ) ] ) ];
    t(idx)= [];
    t = strtrim(t);
end

