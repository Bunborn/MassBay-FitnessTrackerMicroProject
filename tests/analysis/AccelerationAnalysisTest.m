classdef AccelerationAnalysisTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testAccelerationAnalysis(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            results = analyzer.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'magnitude'));
            testCase.verifyTrue(isfield(results, 'stats'));
            testCase.verifyGreaterThan(results.stats.mean, 0);
        end
        
        function testAccelerationAnalysisResults(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
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
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plotMagnitude());
            
            close all;
        end
        
        function testPlotComponents(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plotComponents());
            
            close all;
        end
        
        function testDefaultPlot(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.plot());
            
            close all;
        end
        
        function testDisplayResults(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            testCase.verifyWarningFree(@() analyzer.displayResults());
        end
        
        function testGetResults(testCase)
            fitnessData = loadFitnessData(testCase.getDataPath('ExampleData.mat'));
            
            if ~fitnessData.hasAcceleration
                testCase.assumeFail('Test data does not contain acceleration data');
            end
            
            analyzer = AccelerationAnalysis();
            analyzer.analyze(fitnessData);
            
            results = analyzer.getResults();
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'magnitude'));
        end
    end
end
