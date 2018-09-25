function t = removevars(t,v)

% t = removevars(t,v)

vs = t.Properties.VariableNames;

v = vs(regexpcell(vs,v,'exact'));

t(:,v) = [];
