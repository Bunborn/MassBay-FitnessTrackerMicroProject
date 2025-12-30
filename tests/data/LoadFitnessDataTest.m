classdef LoadFitnessDataTest < matlab.unittest.TestCase
    
    properties
        testDataPath
        projectRoot
    end
    
    methods (TestClassSetup)
        function setupPath(testCase)
            thisFile = mfilename('fullpath');
            testsFolder = fileparts(fileparts(thisFile));
            testCase.projectRoot = fileparts(testsFolder);
            addpath(testCase.projectRoot);
        end
    end
    
    methods (TestMethodSetup)
        function setTestDataPath(testCase)
            testCase.testDataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
        end
    end
    
    methods (Test)
        function testLoadFitnessData(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            
            fitnessData = data.loadFitnessData(dataPath);
            
            testCase.verifyClass(fitnessData, 'struct');
            testCase.verifyTrue(isfield(fitnessData, 'hasAcceleration') || ...
                                isfield(fitnessData, 'hasPosition') || ...
                                isfield(fitnessData, 'hasOrientation'));
        end
        
        function testLoadFitnessDataInvalidPath(testCase)
            invalidPath = "nonexistent_file.mat";
            
            testCase.verifyError(@() data.loadFitnessData(invalidPath), ...
                'data:loadFitnessData:FileNotFound');
        end
        
        function testLoadFitnessDataInvalidFileType(testCase)
            invalidPath = fullfile(testCase.projectRoot, 'README.md');
            
            testCase.verifyError(@() data.loadFitnessData(invalidPath), ...
                'data:loadFitnessData:InvalidFileType');
        end
    end
end
