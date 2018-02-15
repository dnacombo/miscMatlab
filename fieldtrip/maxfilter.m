function cfg = maxfilter(cfg)

% cfg = maxfilter(cfg)
% run maxfilter (optionally on a remote host with same filesystem via ssh)
%
% input: cfg = a structure with fields:
%                   f = the input file name (full file name with path)
%                   
%                   corr, st, ctc, cal... all maxfilter options are blindly
%                   passed to maxfilter.
%
%                   maxfilterbin = path to maxfilter on the host
%           
%                   host_with_maxfilter = address to a host running
%                                         maxfilter (can be localhost, in
%                                         which case user, pass,
%                                         ssh_pubkey, and ssh_tbx are
%                                         ignored). 
%                   user = username on remote host (if different from
%                          local)
%                   pass = password associated to user on remote host (this
%                          is not the recommended connection method). It is
%                          recommended to use a public key instead.
%                   ssh_pubkey = path to your public key for
%                                authentification (typically:
%                                '~/.ssh/id_rsa')
%                   ssh_tbx = path to the ssh toolbox on the local machine.
%                   Download the toolbox from the address below and unzip
%                   to ssh_tbx. 
%                   (https://fr.mathworks.com/matlabcentral/fileexchange/35409-ssh-sftp-scp-for-matlab--v2-)
%

def = [];
def.f = '';
def.force = 0;
def.corr = 0.98;
def.st = 2000;
def.maxfilterbin = '/usr/cenir/neuromag/bin/util/maxfilter';
def.ctc = ''; def.cal = '';

% warning: need to change line below
def.ssh_tbx = cdhome('ssh2_v2_m1_r6');
def.user = getenv('USER');
def.pass = 'not recommended';
def.ssh_pubkey = fullfile(getenv('HOME'),'/.ssh/id_rsa');
def.host_with_maxfilter = 'pclx22.meg.chups.jussieu.fr';

if not(exist('cfg','var'))
    cfg = [];
end
cfg = setdef(cfg,def,1);
if not(isfield(cfg,'o'))
    cfg.o = strrep(cfg.f,'.fif','_tsss.fif');
end
if isempty(cfg.f)
    error('input data should be specified under cfg.f')
end
datadir = fileparts(cfg.f);

if isempty(cfg.ctc)
    if exist(fullfile(datadir,'sss_config'),'dir')
        cfg.ctc = fullfile(datadir, '/sss_config/ct_sparse.fif');
    else
        warning('No ctc file provided or next to the data. results may be inaccurate');
    end
end
if isempty(cfg.cal)
    if exist(fullfile(datadir,'sss_config'),'dir')
        cfg.cal = fullfile(datadir, '/sss_config/sss_cal.dat');
    else
        warning('No cal file provided or next to the data. results may be inaccurate');
    end
end

maxfilterbin = cfg.maxfilterbin;
host_with_maxfilter = cfg.host_with_maxfilter;
ssh_tbx = cfg.ssh_tbx;
ssh_pubkey = cfg.ssh_pubkey;
user = cfg.user;
pass = cfg.pass;
if not(strcmp(pass,'not recommended'))
    warning('You typed your password somewhere in a script or in this function... This is not recommended and a potential security threat...')
end
force = cfg.force;
if istrue(force)
    try delete(cfg.o); end        
end
cfg = rmfield(cfg,{'maxfilterbin','host_with_maxfilter','ssh_tbx','ssh_pubkey','user','pass','force'});

str = maxfilterbin;
fs = fieldnames(cfg);
for i = 1:numel(fs)
    if any(ismember(fs{i},{'version','help','v','force', 'def','maint','headpos','hpicons','history'}))
        % first write all options with no parameters
        str = [str ' -' fs{i}];
    elseif isempty(cfg.(fs{i}))
        % skip those that should have a paramter but are empty in the
        % structure
        continue
    elseif ischar(cfg.(fs{i}))
        % write those that are char
        str = [str ' -' fs{i} ' ' cfg.(fs{i})];
    elseif iscellstr(cfg.(fs{i}))
        % write cellstrs separated by space
        str = [str ' -' fs{i} ' ' strjoin(cfg.(fs{i}), ' ')];
    elseif isnumeric(cfg.(fs{i}))
        % write numeric converted to string.
        str = [str ' -' fs{i} ' ' num2str(cfg.(fs{i}))];
    end
end

% write script
fid = fopen(fullfile(datadir,'maxfilter_script'),'wt');
fprintf(fid,'%s\n',str);
fclose(fid);

if any(strcmp(host_with_maxfilter,{'localhost' 'local' '127.0.0.1'}))
    disp(['========== Maxfilter runs locally =========='])
    [status,cmdout] = system(['cd ' datadir ';chmod +x maxfilter_script;./maxfilter_script']);
    if status
        disp('========= Error while running Maxfilter locally ===========')
        disp(cmdout)
        error('Maxfilter')
    end
else
    % run it
    addpath(ssh_tbx)
    disp(['========== Maxfilter on remote host ' host_with_maxfilter ' =========='])
    disp(['Processing ' cfg.f])
    if not(isempty(ssh_pubkey))
        ssh2_conn = ssh2_config_publickey(host_with_maxfilter,user,ssh_pubkey,'');
    else
        ssh2_conn = ssh2_config(host_with_maxfilter,user,pass);
    end
    %%
    [ssh2_conn,command_output] = ssh2_command(ssh2_conn, ['cd ' datadir ';chmod +x maxfilter_script;./maxfilter_script'],1);
    cfg.ssh2_conn = ssh2_conn;
    cfg.command_output = command_output;
    if isempty(command_output{1})
        disp(['======== Seems like this command did not run on ' host_with_maxfilter ' ========='] )
        disp(str)
        disp('You probably want to inspect that...')
        keyboard
    end
end
disp(['========== Checking output file is present =========='])
allexits = regexp(command_output,'^EXIT ([^:]*):.*?(/.*)\.$','tokens');
allexits = allexits(~emptycells(allexits));
if isempty(allexits)
    disp('======== Maxfilter: No output created ===========')
else
    for i = 1:numel(allexits)
        if strcmp(allexits{i}{1}{1},'OK')
            disp(['========== OK =========='])
        else
            warning(['File ' allexits{i}{1}{2} ' not created']);
        end
    end
    disp(['========== Maxfilter DONE. =========='])
end
delete(fullfile(datadir,'maxfilter_script'));

