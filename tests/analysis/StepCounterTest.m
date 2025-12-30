classdef StepCounterTest < matlab.unittest.TestCase
    
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
        function testStepCounter(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter = analysis.StepCounter();
            stepCounter.Threshold = 1.2;
            stepCounter.MinPeakDistance = 0.5;
            results = stepCounter.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'stepCount'));
            testCase.verifyGreaterThanOrEqual(results.stepCount, 0);
        end
        
        function testStepCounterProperties(testCase)
            stepCounter = analysis.StepCounter();
            
            testCase.verifyEqual(stepCounter.Threshold, 1.2);
            testCase.verifyEqual(stepCounter.MinPeakDistance, 0.5);
            
            stepCounter.Threshold = 1.5;
            testCase.verifyEqual(stepCounter.Threshold, 1.5);
        end
        
        function testStepCounterResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter = analysis.StepCounter();
            results = stepCounter.analyze(fitnessData);
            
            testCase.verifyTrue(isfield(results, 'stepCount'));
            testCase.verifyTrue(isfield(results, 'peakLocations'));
            testCase.verifyTrue(isfield(results, 'peakValues'));
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'threshold'));
            
            testCase.verifyEqual(length(results.peakLocations), results.stepCount);
            testCase.verifyEqual(length(results.peakValues), results.stepCount);
        end
        
        function testPlotSteps(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter = analysis.StepCounter();
            stepCounter.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() stepCounter.plotSteps());
            
            close all;
        end
        
        function testDefaultPlot(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter = analysis.StepCounter();
            stepCounter.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() stepCounter.plot());
            
            close all;
        end
        
        function testDifferentThresholds(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            stepCounter1 = analysis.StepCounter();
            stepCounter1.Threshold = 1.0;
            results1 = stepCounter1.analyze(fitnessData);
            
            stepCounter2 = analysis.StepCounter();
            stepCounter2.Threshold = 2.0;
            results2 = stepCounter2.analyze(fitnessData);
            
            testCase.verifyGreaterThanOrEqual(results1.stepCount, results2.stepCount);
        end
    end
end
