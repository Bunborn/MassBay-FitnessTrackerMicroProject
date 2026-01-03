classdef (Abstract) AbstractFitnessTrackerTest < matlab.unittest.TestCase
    % AbstractFitnessTrackerTest - Base class for fitness tracker tests
    % Provides helper for data file paths

    properties (Access = protected)
        ProjectRoot
    end

    methods (TestClassSetup)
        function setupPaths(testCase)
            thisFile = mfilename('fullpath');
            testsFolder = fileparts(thisFile);
            testCase.ProjectRoot = fileparts(testsFolder);
        end
    end
    
    methods (Access = protected)
        function dataPath = getDataPath(testCase, filename)
            dataPath = fullfile(testCase.ProjectRoot, 'data', filename);
        end
    end
end