%% Train Activity Classification Model
% This script trains a machine learning model to classify activities
% (sitting, walking, running) based on acceleration data.
% The trained model is saved for use by the ActivityClassifier class.

%% Load Training Data
clear
load('data/ActivityLogs.mat');

%% Prepare Training Data
% Add activity labels to each dataset
sitLabel = 'sitting';
sitLabel = repmat(sitLabel, size(sitAcceleration, 1), 1);
sitAcceleration.Activity = sitLabel;

walkLabel = 'walking';
walkLabel = repmat(walkLabel, size(walkAcceleration, 1), 1);
walkAcceleration.Activity = walkLabel;

runLabel = 'running';
runLabel = repmat(runLabel, size(runAcceleration, 1), 1);
runAcceleration.Activity = runLabel;

% Combine all data
allAcceleration = [sitAcceleration; walkAcceleration; runAcceleration];

% Remove timestamp (not needed for classification)
allAcceleration = timetable2table(allAcceleration, "ConvertRowTimes", false);

fprintf('Training data prepared:\n');
fprintf('  Total samples: %d\n', height(allAcceleration));
fprintf('  Features: X, Y, Z acceleration\n');
fprintf('  Classes: sitting, walking, running\n\n');

%% Train Model Programmatically
% Using a simple tree-based classifier for speed and interpretability

% Split data into training and validation sets
cv = cvpartition(allAcceleration.Activity, 'HoldOut', 0.2);
trainingData = allAcceleration(training(cv), :);
validationData = allAcceleration(test(cv), :);

% Train a classification tree
trainedModel = fitctree(trainingData, 'Activity', ...
    'PredictorNames', {'X', 'Y', 'Z'}, ...
    'ResponseName', 'Activity', ...
    'ClassNames', {'sitting', 'walking', 'running'});

fprintf('Model trained successfully!\n');

%% Validate Model
validationPredictions = predict(trainedModel, validationData);
validationAccuracy = sum(string(validationPredictions) == string(validationData.Activity)) / height(validationData);

fprintf('Validation Accuracy: %.2f%%\n\n', validationAccuracy * 100);

%% Create Confusion Matrix
figure('Name', 'Training Results');
confusionchart(string(validationData.Activity), string(validationPredictions));
title('Activity Classification - Validation Results');

%% Save Trained Model
% Create a structure with model and metadata
activityModel = struct();
activityModel.model = trainedModel;
activityModel.trainDate = datetime('now');
activityModel.accuracy = validationAccuracy;
activityModel.classes = {'sitting', 'walking', 'running'};
activityModel.features = {'X', 'Y', 'Z'};

% Get absolute path to save model
scriptPath = fileparts(mfilename('fullpath'));
modelPath = fullfile(scriptPath, '+analysis', 'models', 'activityModel.mat');

% Ensure models folder exists
modelsFolder = fullfile(scriptPath, '+analysis', 'models');
if ~isfolder(modelsFolder)
    mkdir(modelsFolder);
end

save(modelPath, 'activityModel');

fprintf('Model saved to %s\n', modelPath);
fprintf('Ready for use with analysis.ActivityClassifier\n');

%% Test with Unknown Data
fprintf('\nTesting with unknown data...\n');
testPredictions = predict(trainedModel, timetable2table(unknownAcceleration, "ConvertRowTimes", false));

% Display distribution
uniqueActivities = unique(testPredictions);
for i = 1:length(uniqueActivities)
    count = sum(strcmp(testPredictions, uniqueActivities{i}));
    percentage = (count / length(testPredictions)) * 100;
    fprintf('  %s: %d samples (%.1f%%)\n', uniqueActivities{i}, count, percentage);
end

%% Visualize Predictions
figure('Name', 'Unknown Data Predictions');
pie(categorical(cellstr(testPredictions)));
title('Predicted Activity Distribution');
legend(uniqueActivities);

fprintf('\nTraining complete! You can now use analysis.ActivityClassifier\n');
