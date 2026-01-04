classdef AccelerationAnalysisTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testAccelerationAnalysis(testCase)
            % Test basic functionality and result structure
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            results = analyzer.analyze(fitnessData);
            
            % Verify result structure
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'X'));
            testCase.verifyTrue(isfield(results, 'Y'));
            testCase.verifyTrue(isfield(results, 'Z'));
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'stats'));
            
            % Verify data consistency
            testCase.verifyEqual(length(results.X), length(results.Y));
            testCase.verifyEqual(length(results.Y), length(results.Z));
            testCase.verifyGreaterThan(results.stats.mean, 0);
        end
        
        function testVisualization(testCase)
            % Test all plotting methods work without errors
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            % Get current figure handles for cleanup
            figHandlesBefore = findall(0, 'Type', 'figure');
            
            % Test all plot methods
            testCase.verifyWarningFree(@() analyzer.plotMagnitude());
            testCase.verifyWarningFree(@() analyzer.plotComponents());
            testCase.verifyWarningFree(@() analyzer.plot());
            
            % Clean up only figures created by this test
            figHandlesAfter = findall(0, 'Type', 'figure');
            newFigs = setdiff(figHandlesAfter, figHandlesBefore);
            testCase.addTeardown(@() close(newFigs));
        end
    end
end
