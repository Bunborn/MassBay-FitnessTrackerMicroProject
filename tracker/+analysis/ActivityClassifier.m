classdef ActivityClassifier < analysis.AnalysisFunction
    
    properties (Constant)
        Name = "Activity Classifier"
        Description = "Classifies activities (sitting, walking, running) using machine learning"
    end
    
    properties (Access = private)
        trainedModel
    end
    
    methods
        function obj = ActivityClassifier()
            obj.loadModel();
        end
        
        function results = analyze(obj, fitnessData)
            if ~fitnessData.hasAcceleration
                error('analysis:ActivityClassifier:NoData', ...
                    'Fitness data does not contain acceleration information');
            end
            
            accel = fitnessData.Acceleration;
            
            % Convert to table format for prediction
            if istimetable(accel)
                dataTable = timetable2table(accel, "ConvertRowTimes", false);
            elseif isstruct(accel)
                dataTable = struct2table(accel);
            else
                error('analysis:ActivityClassifier:InvalidFormat', ...
                    'Unexpected acceleration data format');
            end
            
            % Make predictions
            predictions = predict(obj.trainedModel.model, dataTable);
            
            % Compute statistics
            uniqueActivities = unique(predictions);
            activityCounts = struct();
            activityPercentages = struct();
            
            for i = 1:length(uniqueActivities)
                activity = uniqueActivities{i};
                count = sum(strcmp(predictions, activity));
                activityCounts.(activity) = count;
                activityPercentages.(activity) = (count / length(predictions)) * 100;
            end
            
            % Store results
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            results.predictions = predictions;
            results.uniqueActivities = uniqueActivities;
            results.activityCounts = activityCounts;
            results.activityPercentages = activityPercentages;
            results.totalSamples = length(predictions);
            results.modelAccuracy = obj.trainedModel.accuracy;
            
            obj.results = results;
        end
        
        function plotDistribution(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:ActivityClassifier:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Activity Distribution');
                ax = axes(f);
            else
                ax = target;
            end
            
            predictionsCat = categorical(cellstr(obj.results.predictions));
            pie(ax, predictionsCat);
            title(ax, 'Predicted Activity Distribution');
            legend(ax, obj.results.uniqueActivities);
        end
        
        function plotTimeline(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:ActivityClassifier:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Activity Timeline');
                ax = axes(f);
            else
                ax = target;
            end
            
            % Convert predictions to numeric for plotting
            predictionsCat = categorical(obj.results.predictions);
            predictionsNumeric = double(predictionsCat);
            
            plot(ax, predictionsNumeric, 'LineWidth', 1.5);
            xlabel(ax, 'Sample');
            ylabel(ax, 'Activity');
            title(ax, 'Activity Over Time');
            
            % Set y-axis labels to activity names
            yticks(ax, 1:length(obj.results.uniqueActivities));
            yticklabels(ax, obj.results.uniqueActivities);
            grid(ax, 'on');
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            fprintf('\n=== %s ===\n', obj.Name);
            fprintf('Analysis timestamp: %s\n', obj.results.timestamp);
            fprintf('Total samples: %d\n', obj.results.totalSamples);
            fprintf('Model accuracy: %.2f%%\n\n', obj.results.modelAccuracy * 100);
            
            fprintf('Activity Distribution:\n');
            for i = 1:length(obj.results.uniqueActivities)
                activity = obj.results.uniqueActivities{i};
                count = obj.results.activityCounts.(activity);
                percentage = obj.results.activityPercentages.(activity);
                fprintf('  %s: %d samples (%.1f%%)\n', activity, count, percentage);
            end
        end
        
        function plotImpl(obj, target)
            obj.plotDistribution(target);
        end
        
        function loadModel(obj)
            % Get the path to this file (+analysis/ActivityClassifier.m)
            thisFile = mfilename('fullpath');
            packageDir = fileparts(thisFile);
            
            % Construct path to model file in models subfolder
            modelPath = fullfile(packageDir, 'models', 'activityModel.mat');
            
            if ~isfile(modelPath)
                error('analysis:ActivityClassifier:ModelNotFound', ...
                    ['Pre-trained model not found. Please run trainActivityModel.m first.\n' ...
                     'Expected location: %s'], modelPath);
            end
            
            loadedData = load(modelPath);
            obj.trainedModel = loadedData.activityModel;
        end
    end
end
