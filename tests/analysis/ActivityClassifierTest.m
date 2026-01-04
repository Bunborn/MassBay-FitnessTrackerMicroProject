classdef ActivityClassifierTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testModelLoading(testCase)
            % Test that model loads successfully
            try
                classifier = ActivityClassifier();
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
            fitnessData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            if ~isfield(fitnessData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = fitnessData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = ActivityClassifier();
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
            fitnessData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            
            if ~isfield(fitnessData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = fitnessData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = ActivityClassifier();
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
            fitnessData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            
            if ~isfield(fitnessData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = fitnessData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = ActivityClassifier();
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
            fitnessData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            
            if ~isfield(fitnessData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = fitnessData.unknownAcceleration;
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            try
                classifier = ActivityClassifier();
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
