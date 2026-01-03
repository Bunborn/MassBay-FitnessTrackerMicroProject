classdef LoadFitnessDataTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testLoadFitnessData(testCase)
            fitnessData = data.loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
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
            invalidPath = fullfile(testCase.ProjectRoot, 'README.md');  %#ok<NASGU> projectRoot from base class
            
            testCase.verifyError(@() data.loadFitnessData(invalidPath), ...
                'data:loadFitnessData:InvalidFileType');
        end
    end
end
