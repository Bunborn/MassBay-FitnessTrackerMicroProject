classdef ActivityClassifierTest < matlab.unittest.TestCase
    
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
            testCase.testDataPath = fullfile(testCase.projectRoot, 'data', 'ActivityLogs.mat');
        end
    end
    
    methods (Test)
        function testModelLoading(testCase)
            % Test that model loads successfully
            try
                classifier = analysis.ActivityClassifier();
                testCase.verifyNotEmpty(classifier);
            catch ME
                if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
                    testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
                else
                    rethrow(ME);
                end
            end
        end
        
        function testActivityClassification(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ActivityLogs.mat');
            
            % Load unknown acceleration data
            loadedData = load(dataPath);
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = analysis.ActivityClassifier();
                results = classifier.analyze(fitnessData);
                
                testCase.verifyClass(results, 'struct');
                testCase.verifyTrue(isfield(results, 'predictions'));
                testCase.verifyTrue(isfield(results, 'uniqueActivities'));
                testCase.verifyTrue(isfield(results, 'activityCounts'));
                testCase.verifyTrue(isfield(results, 'activityPercentages'));
                
                % Verify predictions are valid activities
                validActivities = {'sitting', 'walking', 'running'};
                for i = 1:length(results.predictions)
                    testCase.verifyTrue(ismember(results.predictions{i}, validActivities));
                end
            catch ME
                if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
                    testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
                else
                    rethrow(ME);
                end
            end
        end
        
        function testPlotDistribution(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ActivityLogs.mat');
            loadedData = load(dataPath);
            
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = analysis.ActivityClassifier();
                classifier.analyze(fitnessData);
                
                testCase.verifyWarningFree(@() classifier.plotDistribution());
                
                close all;
            catch ME
                if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
                    testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
                else
                    rethrow(ME);
                end
            end
        end
        
        function testPlotTimeline(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ActivityLogs.mat');
            loadedData = load(dataPath);
            
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = analysis.ActivityClassifier();
                classifier.analyze(fitnessData);
                
                testCase.verifyWarningFree(@() classifier.plotTimeline());
                
                close all;
            catch ME
                if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
                    testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
                else
                    rethrow(ME);
                end
            end
        end
        
        function testDisplayResults(testCase)
            dataPath = fullfile(testCase.projectRoot, 'data', 'ActivityLogs.mat');
            loadedData = load(dataPath);
            
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = analysis.ActivityClassifier();
                classifier.analyze(fitnessData);
                
                testCase.verifyWarningFree(@() classifier.displayResults());
            catch ME
                if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
                    testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
                else
                    rethrow(ME);
                end
            end
        end
    end
end
