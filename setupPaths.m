function projectRoot = setupPaths()
%SETUPPATHS Add fitness tracker project folders to the MATLAB path
%   projectRoot = setupPaths() adds the tracker, subfolders, and tests folders
%   to the MATLAB path and returns the project root directory.

    % Get project root from this file's location
    projectRoot = fileparts(mfilename('fullpath'));
    
    % Add folders to path
    addpath(fullfile(projectRoot, 'tracker'));
    addpath(fullfile(projectRoot, 'tracker', 'analysis'));
    addpath(fullfile(projectRoot, 'tracker', 'dataloading'));
    addpath(fullfile(projectRoot, 'tracker', 'modeltraining'));
    addpath(fullfile(projectRoot, 'tracker', 'utilities'));
    addpath(fullfile(projectRoot, 'tests'));
end
