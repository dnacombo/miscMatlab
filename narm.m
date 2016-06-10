function nona = narm(withna)

% nona = narm(withna)
% remove nans from withna and return nona


nona = withna(~isnan(withna));
