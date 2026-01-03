classdef ActivityClassifierTest < AbstractFitnessTrackerTest
    
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
            % Load unknown acceleration data
            loadedData = load(testCase.getDataPath('ActivityLogs.mat'));
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
            loadedData = load(testCase.getDataPath('ActivityLogs.mat'));
            
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
            loadedData = load(testCase.getDataPath('ActivityLogs.mat'));
            
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
            loadedData = load(testCase.getDataPath('ActivityLogs.mat'));
            
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
