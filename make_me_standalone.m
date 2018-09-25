function dep = make_me_standalone(f,cfg)

def = [];
def.path_re = 'MATLAB\/general';
def.dowrite = 0;
def.fList = [];

cfg = setdef(cfg,def);

fList = cfg.fList;

if isempty(fList)
    [fList] = matlab.codetools.requiredFilesAndProducts(f);
end

tocopy = fList(regexpcell(fList,cfg.path_re));

tocopytxt = cellfun(@(f) readtext(f,'\n',[],[],'textual'),tocopy,'uniformoutput',0);

nuf = [myfileparts(f,'pf'),'_standalone.m'];
copyfile(f,nuf);
% for i = 1:numel(tocopytxt)
%     funnames{i} = regexp(tocopytxt{i},'^\s*function.*=\s*(\w+).*','tokens');
%     funidx = find(~emptycells(funnames{i}));
%     funnames{i} = cellfun(@(x) x{1}{1}, funnames{i}(funidx),'uniformoutput',0);
% end
fid = fopen(nuf,'at');
fprintf(fid,'\n\n');
for ic = 1:numel(tocopytxt)
    fprintf('%s\n',tocopytxt{ic}{:});
    fprintf('\n\n');
end
fclose(fid);





