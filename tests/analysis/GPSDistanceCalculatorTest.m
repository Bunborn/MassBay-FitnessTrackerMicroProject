classdef GPSDistanceCalculatorTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testGPSDistanceCalculation(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            results = gpsCalc.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'totalDistanceMiles'));
            testCase.verifyTrue(isfield(results, 'totalDistanceFeet'));
            testCase.verifyTrue(isfield(results, 'estimatedSteps'));
            testCase.verifyGreaterThan(results.totalDistanceMiles, 0);
            testCase.verifyGreaterThan(results.estimatedSteps, 0);
        end
        
        function testGPSDistanceProperties(testCase)
            gpsCalc = GPSDistanceCalculator();
            
            testCase.verifyEqual(gpsCalc.StrideLength, 2.5);
            testCase.verifyEqual(gpsCalc.EarthCircumference, 24901);
            
            % Test property modification
            gpsCalc.StrideLength = 3.0;
            testCase.verifyEqual(gpsCalc.StrideLength, 3.0);
        end
        
        function testGPSDistanceResults(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            results = gpsCalc.analyze(fitnessData);
            
            testCase.verifyTrue(isfield(results, 'segmentDistances'));
            testCase.verifyTrue(isfield(results, 'latitude'));
            testCase.verifyTrue(isfield(results, 'longitude'));
            testCase.verifyTrue(isfield(results, 'numSegments'));
            
            % Verify segment count matches position data
            expectedSegments = length(results.latitude) - 1;
            testCase.verifyEqual(results.numSegments, expectedSegments);
            testCase.verifyEqual(length(results.segmentDistances), expectedSegments);
        end
        
        function testPlotRoute(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            gpsCalc.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() gpsCalc.plotRoute());
            
            close all;
        end
        
        function testPlotSegmentDistances(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            gpsCalc.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() gpsCalc.plotSegmentDistances());
            
            close all;
        end
        
        function testDifferentStrideLengths(testCase)
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
        
        function testDisplayResults(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            gpsCalc = GPSDistanceCalculator();
            gpsCalc.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() gpsCalc.displayResults());
        end
    end
end
