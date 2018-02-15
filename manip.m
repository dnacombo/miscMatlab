% MANIP Project manager for MATLAB
%   MANIP(cmd, projectName) manages current working directory and files
%   that are opened in MATLAB editor (but not the workspace). 
%   Available commands are: 
%     'list', 'show', 'save', 'load', 'close', 'rename', 'delete', 'active'
% 
%   MANIP or
%   MANIP('list') shows all stored manips. Arrow marks active project.
% 
%   MANIP('active') returns the name of the active project
% 
%   MANIP('show') shows information about the current project
%   MANIP('show', project_name) shows information about the project
% 
%   MANIP('close') closes all opened files
% 
%   MANIP('save') saves current working directory and editor state under
%   the active project 
%   MANIP('save', projectName) saves current working directory and
%   editor state under the specified project name
% 
%   MANIP('load') restores the project "default" 
%   MANIP('load', projectName) restores the project with specified name
% 
%   MANIP('open') is synonym for MANIP('load')
% 
%   MANIP('rename', newName) renames the active project
%   MANIP('rename', projectName, newName) renames the project
%
%   MANIP('delete') deletes the active project
%   MANIP('delete', projectName) deletes the project with specified name
% 
%   Examples:
%       manip list
%       manip save myProject
%       manip close
%       manip load default
%       manip rename myProject myLibrary
% 
%   All manips are stored in the %userpath%/manips.mat. This file with
%   empty "default" project is created at the first run of the script. If
%   %userpath% is empty, the script will execute userpath('reset').
%   
%   First project always has name "default"

% Copyright 2012-2013, Vladimir Filimonov (ETH Zurich).
% $Date: 12-May-2012 $ 

function varargout = manip(cmd, varargin)

persistent manip_sessid


if verLessThan('matlab','7.12')
    error('Projects: MATLAB versions older than R2011a (7.12) are not supported')
end

if isempty(userpath)
    userpath('reset');
end

fpath = regexp(userpath,'[^:]*','match');
fpath = fpath{1};
fpath = fullfile(fpath, 'manips.mat');

if ~exist(fpath, 'file')    % first time run
    openDocuments = matlab.desktop.editor.getAll;
    filenames = {openDocuments.Filename};
    
    projectsList = [];
    projectsList(1).ProjectName = 'default';
    projectsList(1).OpenedFiles = {};
    projectsList(1).HomeDir = userpath;
    projectsList(1).HomeDir(end) = [];
    manip_sessid = round(rand*1e15);
    activeProject = [manip_sessid   1];
    save(fpath, 'projectsList', 'activeProject');
else
    load(fpath)
end

% keep number of active projects to a reasonable size
activeProject(1:size(activeProject,1)-10,:) = [];

if isempty(manip_sessid)
    manip_sessid = round(rand*1e15);
    activeProject(end+1,:) = [manip_sessid   activeProject(end,2)];
    save(fpath, 'projectsList', 'activeProject');
end

iid = find(activeProject(:,1) == manip_sessid);

if nargin==0
    cmd = 'list';
end

switch lower(cmd)
    case 'cd'
        if not(isempty(varargin)) && ~strcmpi(manip('active'),varargin{1})
            manip('load',varargin{1})
            iid = find(activeProject(:,1) == manip_sessid);
        end
        cd(projectsList(activeProject(iid,2)).HomeDir);
    case 'close'
        openDocuments = matlab.desktop.editor.getAll;
        openDocuments.close;
        
        load(fpath)
        iid = find(activeProject(:,1) == manip_sessid);
        activeProject(iid,2) = 1;
        save(fpath, 'projectsList', 'activeProject');
        varargout = {true};
        
    %=========================================    
    case 'list'
        disp('List of available manips:')
        for ii = 1:length(projectsList)
            if ii == activeProject(iid,2)
                str = '-> ';
            else
                str = '   ';
            end
            disp([str num2str(ii) ': ' projectsList(ii).ProjectName])
        end
        varargout = {projectsList.ProjectName};
        
    %=========================================    
    case {'show', 'info'}
        if nargin==1
            ind = activeProject(iid,2);
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                error('Projects: unknown project name')
            end
        end
        projectsList(ind)
        varargout{1} = projectsList(activeProject(iid,2));
        
    %=========================================    
    case 'active'
        varargout{1} = projectsList(activeProject(iid,2)).ProjectName;
        if nargout == 0
            disp(['Active project is "' varargout{1} '"'])
        end
    %=========================================    
    case 'save'
        if nargin==1
            ind = activeProject(iid,2);
            prjname = projectsList(ind).ProjectName;
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                ind = length(projectsList) + 1;
            end
        end
        
        openDocuments = matlab.desktop.editor.getAll;
        filenames = {openDocuments.Filename};
        
        projectsList(ind).ProjectName = prjname;
        projectsList(ind).OpenedFiles = filenames;
        if isempty(projectsList(ind).HomeDir)
            projectsList(ind).HomeDir = pwd;
        end
        activeProject(iid,2) = ind;
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Manip "' prjname '" was saved'])
        
    %=========================================    
    case {'sethomedir'}
        if nargin==1
            ind = activeProject(iid,2);
            prjname = projectsList(ind).ProjectName;
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                ind = length(projectsList) + 1;
            end
        end
        projectsList(ind).HomeDir = pwd;
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['HomeDir set for "' prjname '"'])
    case {'open', 'load'}
        if nargin==1
            prjname = 'default';
        else
            prjname = varargin{1};
        end
        ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
        if isempty(ind)
            error('Projects: unknown project name')
        end
                
        if manip('close')
            load(fpath)
            iid = find(activeProject(:,1) == manip_sessid);
        else
            return
        end
        
        try
            cd(projectsList(ind).HomeDir);
        catch
            warning(['Directory "' projectsList(ind).HomeDir '" does not exist'])
        end
        
        filenames = projectsList(ind).OpenedFiles;
        
        for ii = 1:length(filenames)
            if exist(filenames{ii}, 'file')
                matlab.desktop.editor.openDocument(filenames{ii});
            else
                warning(['File "' filenames{ii} '" was not found'])
            end
        end
        od = matlab.desktop.editor.getAll;
        projectsList(ind).OpenedFiles = {od.Filename};
        
        activeProject(iid,2) = ind;
        save(fpath, 'projectsList', 'activeProject');
        disp(['Manip "' prjname '" was restored'])

%     %=========================================    
%     case 'saveload'
%         manip('save');
%         manip('load',varargin{:});
        
    %=========================================    
    case 'rename'
        if nargin==1
            error('Projects: project name was not specified')
        elseif nargin==2
            prjold = projectsList(activeProject(iid,2)).ProjectName;
            prjnew = varargin{1};
        elseif nargin==3
            prjold = varargin{1};
            prjnew = varargin{2};
        end
        ind = find(strcmpi(prjold, {projectsList.ProjectName}), 1);
        if isempty(ind)
            error('Projects: unknown project name')
        end
        
        projectsList(ind).ProjectName = prjnew;
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Manip "' prjold '" was renamed to "' prjnew '"'])
        
        
    %=========================================    
    case 'delete'
        if nargin==1
            ind = activeProject(iid,2);
            new_prj = 'default';
        else
            prjname = varargin{1};
            ind = find(strcmpi(prjname, {projectsList.ProjectName}), 1);
            if isempty(ind)
                error('Projects: required project was not found')
            end
            if ind == activeProject(iid,2)
                new_prj = 'default';
            else
                new_prj = projectsList(activeProject(iid,2)).ProjectName;
            end
        end
        if ind==1
            error('Projects: could not delete "default" project')
        end
        
        prjname = projectsList(ind).ProjectName;
        projectsList(ind) = [];
        activeProject(iid,2) = find(strcmpi(new_prj, {projectsList.ProjectName}), 1);
        
        save(fpath, 'projectsList', 'activeProject');
        disp(['Manip "' prjname '" was deleted'])
        if activeProject(iid,2)==1
            disp('Current project was changed to "default"')
        end

    %=========================================    
    otherwise 
        try
            if strcmp(manip('active'),cmd)
                disp(['manip ' cmd ' already active'])
                manip('cd',cmd)
                return
            else
                manip('load',cmd)
            end
        catch ME
            disp(ME)
            error(['Manip: unknown command: ' cmd '.'])
        end
end

if nargout==0
    varargout = {};
end
