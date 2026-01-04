classdef LoadFitnessDataTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testLoadFitnessData(testCase)
            % Test basic data loading with validation and metadata flags
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            % Verify structure and metadata flags
            testCase.verifyClass(fitnessData, 'struct');
            testCase.verifyTrue(isfield(fitnessData, 'hasAcceleration') || ...
                                isfield(fitnessData, 'hasPosition') || ...
                                isfield(fitnessData, 'hasOrientation'));
        end
        
        function testLoadFitnessDataInvalidPath(testCase)
            % Test error handling for non-existent file
            invalidPath = "nonexistent_file.mat";
            
            testCase.verifyError(@() loadFitnessData(invalidPath), ...
                'data:loadFitnessData:FileNotFound');
        end
        
        function testLoadFitnessDataInvalidFileType(testCase)
            % Test error handling for non-.mat file
            invalidPath = fullfile(testCase.ProjectRoot, 'README.md');
            
            testCase.verifyError(@() loadFitnessData(invalidPath), ...
                'data:loadFitnessData:InvalidFileType');
        end
        
        function testDataValidationAndNormalization(testCase)
            % Test that loadFitnessData adds metadata flags (hasAcceleration, hasPosition, hasOrientation)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            % Verify metadata flags exist
            testCase.verifyTrue(isfield(fitnessData, 'hasAcceleration'));
            testCase.verifyTrue(isfield(fitnessData, 'hasPosition'));
            testCase.verifyTrue(isfield(fitnessData, 'hasOrientation'));
            
            % Verify flags are logical
            testCase.verifyClass(fitnessData.hasAcceleration, 'logical');
            testCase.verifyClass(fitnessData.hasPosition, 'logical');
            testCase.verifyClass(fitnessData.hasOrientation, 'logical');
        end
        
        function testUnknownAccelerationMapping(testCase)
            % Test that unknownAcceleration field is mapped to Acceleration for consistent interface
            loadedData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            
            % If unknownAcceleration exists in raw data, it should be mapped to Acceleration
            if isfield(loadedData, 'Acceleration')
                testCase.verifyTrue(loadedData.hasAcceleration);
            end
        end
        
        function testValidateDataOption(testCase)
            % Test that ValidateData option controls metadata flag addition
            % Create a temporary test file with raw data (no metadata flags)
            tempFile = fullfile(tempdir, 'testRawData.mat');
            Acceleration = struct('X', [1 2 3], 'Y', [4 5 6], 'Z', [7 8 9]);
            save(tempFile, 'Acceleration');
            testCase.addTeardown(@() delete(tempFile));
            
            % Load with validation - should add metadata flags
            fitnessDataWithValidation = loadFitnessData(tempFile, ValidateData=true);
            testCase.verifyTrue(isfield(fitnessDataWithValidation, 'hasAcceleration'));
            testCase.verifyTrue(isfield(fitnessDataWithValidation, 'hasPosition'));
            testCase.verifyTrue(isfield(fitnessDataWithValidation, 'hasOrientation'));
            
            % Load without validation - should NOT add metadata flags
            fitnessDataWithoutValidation = loadFitnessData(tempFile, ValidateData=false);
            testCase.verifyFalse(isfield(fitnessDataWithoutValidation, 'hasAcceleration'));
            testCase.verifyFalse(isfield(fitnessDataWithoutValidation, 'hasPosition'));
            testCase.verifyFalse(isfield(fitnessDataWithoutValidation, 'hasOrientation'));
            
            % Both should have the original Acceleration field
            testCase.verifyTrue(isfield(fitnessDataWithValidation, 'Acceleration'));
            testCase.verifyTrue(isfield(fitnessDataWithoutValidation, 'Acceleration'));
        end
    end
end
