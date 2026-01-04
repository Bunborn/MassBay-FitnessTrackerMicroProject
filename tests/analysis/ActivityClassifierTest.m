classdef ActivityClassifierTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testModelLoading(testCase)
            % Test that model loads successfully
            % Check if model file exists before attempting to load
            modelPath = fullfile(testCase.ProjectRoot, 'tracker', 'analysis', 'models', 'activityModel.mat');
            if ~isfile(modelPath)
                testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
            end
            
            classifier = ActivityClassifier();
            testCase.verifyNotEmpty(classifier);
        end
        
        function testActivityClassification(testCase)
            % Test classification functionality and result structure
            % Check if model exists
            modelPath = fullfile(testCase.ProjectRoot, 'tracker', 'analysis', 'models', 'activityModel.mat');
            if ~isfile(modelPath)
                testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
            end
            
            loadedData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            classifier = ActivityClassifier();
            results = classifier.analyze(fitnessData);
            
            % Verify result structure
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
        end
        
        function testVisualization(testCase)
            % Test all plotting methods work without errors
            % Check if model exists
            modelPath = fullfile(testCase.ProjectRoot, 'tracker', 'analysis', 'models', 'activityModel.mat');
            if ~isfile(modelPath)
                testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
            end
            
            loadedData = loadFitnessData(testCase.getDataPath('ActivityLogs.mat'));
            if ~isfield(loadedData, 'unknownAcceleration')
                testCase.assumeFail('Test data does not contain unknownAcceleration');
            end
            
            fitnessData = struct();
            fitnessData.Acceleration = loadedData.unknownAcceleration;
            fitnessData.hasAcceleration = true;
            
            classifier = ActivityClassifier();
            classifier.analyze(fitnessData);
            
            % Get current figure handles for cleanup
            figHandlesBefore = findall(0, 'Type', 'figure');
            
            % Test all plot methods
            testCase.verifyWarningFree(@() classifier.plotDistribution());
            testCase.verifyWarningFree(@() classifier.plotTimeline());
            
            % Clean up only figures created by this test
            figHandlesAfter = findall(0, 'Type', 'figure');
            newFigs = setdiff(figHandlesAfter, figHandlesBefore);
            testCase.addTeardown(@() close(newFigs));
        end
    end
end
