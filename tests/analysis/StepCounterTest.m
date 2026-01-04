classdef StepCounterTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testStepCounter(testCase)
            % Test basic functionality and result structure
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter = StepCounter();
            stepCounter.Threshold = 1.2;
            stepCounter.MinPeakDistance = 0.5;
            results = stepCounter.analyze(fitnessData);
            
            % Verify result structure
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'stepCount'));
            testCase.verifyTrue(isfield(results, 'peakLocations'));
            testCase.verifyTrue(isfield(results, 'peakValues'));
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'threshold'));
            
            % Verify data consistency
            testCase.verifyGreaterThanOrEqual(results.stepCount, 0);
            testCase.verifyEqual(length(results.peakLocations), results.stepCount);
            testCase.verifyEqual(length(results.peakValues), results.stepCount);
        end
        
        function testStepCounterProperties(testCase)
            % Test property configuration
            stepCounter = StepCounter();
            
            testCase.verifyEqual(stepCounter.Threshold, 1.2);
            testCase.verifyEqual(stepCounter.MinPeakDistance, 0.5);
            
            stepCounter.Threshold = 1.5;
            testCase.verifyEqual(stepCounter.Threshold, 1.5);
        end
        
        function testDifferentThresholds(testCase)
            % Test behavior verification: lower threshold detects more steps
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter1 = StepCounter();
            stepCounter1.Threshold = 1.0;
            results1 = stepCounter1.analyze(fitnessData);
            
            stepCounter2 = StepCounter();
            stepCounter2.Threshold = 2.0;
            results2 = stepCounter2.analyze(fitnessData);
            
            testCase.verifyGreaterThanOrEqual(results1.stepCount, results2.stepCount);
        end
    end
end
