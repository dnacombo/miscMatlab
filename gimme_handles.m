function handles = gimme_handles(name)

% handles = gimme_handles(name)
% retrieve the handles for the gui called name (str, regexp) 

prev = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
try
    handles = guidata(findobj('-regexp','name',name));
catch
    handles = findobj('-regexp','name',name);
end
set(0,'ShowHiddenHandles',prev);


