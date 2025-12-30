classdef GPSDistanceCalculatorTest < matlab.unittest.TestCase
    
    properties
        testDataPath
        projectRoot
    end
    
    methods (TestClassSetup)
        function setupPath(testCase)
            thisFile = mfilename('fullpath');
            testsFolder = fileparts(fileparts(thisFile));
            testCase.projectRoot = fileparts(testsFolder);
            addpath(fullfile(testCase.projectRoot, 'tracker'));
        end
    end
    
    methods (TestMethodSetup)
        function setTestDataPath(testCase)
            testCase.testDataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
        end
    end
    
    methods (Test)
        function testGPSDistanceCalculation(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            calculator = analysis.GPSDistanceCalculator();
            results = calculator.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'totalDistanceMiles'));
            testCase.verifyTrue(isfield(results, 'totalDistanceFeet'));
            testCase.verifyTrue(isfield(results, 'estimatedSteps'));
            testCase.verifyGreaterThan(results.totalDistanceMiles, 0);
            testCase.verifyGreaterThan(results.estimatedSteps, 0);
        end
        
        function testGPSDistanceProperties(testCase)
            calculator = analysis.GPSDistanceCalculator();
            
            testCase.verifyEqual(calculator.StrideLength, 2.5);
            testCase.verifyEqual(calculator.EarthCircumference, 24901);
            
            % Test property modification
            calculator.StrideLength = 3.0;
            testCase.verifyEqual(calculator.StrideLength, 3.0);
        end
        
        function testGPSDistanceResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            calculator = analysis.GPSDistanceCalculator();
            results = calculator.analyze(fitnessData);
            
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
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            calculator = analysis.GPSDistanceCalculator();
            calculator.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() calculator.plotRoute());
            
            close all;
        end
        
        function testPlotSegmentDistances(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            calculator = analysis.GPSDistanceCalculator();
            calculator.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() calculator.plotSegmentDistances());
            
            close all;
        end
        
        function testDifferentStrideLengths(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            % Test with default stride
            calculator1 = analysis.GPSDistanceCalculator();
            results1 = calculator1.analyze(fitnessData);
            
            % Test with longer stride
            calculator2 = analysis.GPSDistanceCalculator();
            calculator2.StrideLength = 3.0;
            results2 = calculator2.analyze(fitnessData);
            
            % Same distance, but fewer steps with longer stride
            testCase.verifyEqual(results1.totalDistanceMiles, results2.totalDistanceMiles);
            testCase.verifyLessThan(results2.estimatedSteps, results1.estimatedSteps);
        end
        
        function testDisplayResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasPosition
                testCase.assumeFail('Test data does not contain position data');
            end
            
            calculator = analysis.GPSDistanceCalculator();
            calculator.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() calculator.displayResults());
        end
    end
end
