classdef AccelerationAnalysisTest < matlab.unittest.TestCase
    
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
            testCase.testDataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
        end
    end
    
    methods (Test)
        function testAccelerationAnalysis(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            results = analyzer.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'stats'));
            testCase.verifyGreaterThan(results.stats.mean, 0);
        end
        
        function testAccelerationAnalysisResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            results = analyzer.analyze(fitnessData);
            
            testCase.verifyTrue(isfield(results, 'X'));
            testCase.verifyTrue(isfield(results, 'Y'));
            testCase.verifyTrue(isfield(results, 'Z'));
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'stats'));
            
            testCase.verifyEqual(length(results.X), length(results.Y));
            testCase.verifyEqual(length(results.Y), length(results.Z));
        end
        
        function testPlotMagnitude(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plotMagnitude());
            
            close all;
        end
        
        function testPlotComponents(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plotComponents());
            
            close all;
        end
        
        function testDefaultPlot(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plot());
            
            close all;
        end
        
        function testDisplayResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.displayResults());
        end
        
        function testGetResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'tracker', 'data', 'ExampleData.mat');
            fitnessData = data.loadFitnessData(dataPath);
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = analysis.AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            results = analyzer.getResults();
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'magnitude'));
        end
    end
end
