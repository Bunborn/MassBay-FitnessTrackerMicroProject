function projectRoot = setupPaths()
%SETUPPATHS Add fitness tracker project folders to the MATLAB path
%   projectRoot = setupPaths() adds the tracker & tests folders
%   to the MATLAB path and returns the project root directory.

    % Get project root from this file's location
    projectRoot = fileparts(mfilename('fullpath'));
    
    % Add folders to path
    addpath(fullfile(projectRoot, 'tracker'));
    addpath(fullfile(projectRoot, 'tests'));
end
