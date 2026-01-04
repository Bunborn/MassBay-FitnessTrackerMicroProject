classdef GPSDistanceCalculatorTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testGPSDistanceCalculation(testCase)
            % Test basic functionality and result structure
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            results = gpsCalc.analyze(fitnessData);
            
            % Verify result structure
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'totalDistanceMiles'));
            testCase.verifyTrue(isfield(results, 'totalDistanceFeet'));
            testCase.verifyTrue(isfield(results, 'estimatedSteps'));
            testCase.verifyTrue(isfield(results, 'segmentDistances'));
            testCase.verifyTrue(isfield(results, 'latitude'));
            testCase.verifyTrue(isfield(results, 'longitude'));
            testCase.verifyTrue(isfield(results, 'numSegments'));
            
            % Verify data consistency
            testCase.verifyGreaterThan(results.totalDistanceMiles, 0);
            testCase.verifyGreaterThan(results.estimatedSteps, 0);
            expectedSegments = length(results.latitude) - 1;
            testCase.verifyEqual(results.numSegments, expectedSegments);
            testCase.verifyEqual(length(results.segmentDistances), expectedSegments);
        end
        
        function testVisualization(testCase)
            % Test all plotting methods work without errors
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            gpsCalc.analyze(fitnessData);
            
            % Get current figure handles for cleanup
            figHandlesBefore = findall(0, 'Type', 'figure');
            
            % Test all plot methods
            testCase.verifyWarningFree(@() gpsCalc.plotRoute());
            testCase.verifyWarningFree(@() gpsCalc.plotSegmentDistances());
            
            % Clean up only figures created by this test
            figHandlesAfter = findall(0, 'Type', 'figure');
            newFigs = setdiff(figHandlesAfter, figHandlesBefore);
            testCase.addTeardown(@() close(newFigs));
        end
        
        function testDifferentStrideLengths(testCase)
            % Test behavior verification: longer stride results in fewer steps
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            % Test with default stride
            gpsCalc1 = GPSDistanceCalculator();
            results1 = gpsCalc1.analyze(fitnessData);
            
            % Test with longer stride
            gpsCalc2 = GPSDistanceCalculator();
            gpsCalc2.StrideLength = 3.0;
            results2 = gpsCalc2.analyze(fitnessData);
            
            % Same distance, but fewer steps with longer stride
            testCase.verifyEqual(results1.totalDistanceMiles, results2.totalDistanceMiles);
            testCase.verifyLessThan(results2.estimatedSteps, results1.estimatedSteps);
        end
    end
end
