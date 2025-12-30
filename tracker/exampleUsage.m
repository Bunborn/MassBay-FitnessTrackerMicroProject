%% Fitness Tracker - Example Usage
% Demonstrates the fitness tracker analysis classes

%% 1. Load Fitness Data
clear; close all;
fitnessData = data.loadFitnessData('../data/ExampleData.mat');

%% 2. Acceleration Analysis
accelAnalyzer = analysis.AccelerationAnalysis();
accelAnalyzer.analyze(fitnessData);

% Plot acceleration magnitude over time
figure('Name', 'Acceleration Analysis', 'Position', [100 100 1000 400]);
subplot(1,2,1);
accelAnalyzer.plotMagnitude(gca);
subplot(1,2,2);
accelAnalyzer.plotComponents(gca);

%% 3. Step Counter - Acceleration Based
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.2;
stepCounter.MinPeakDistance = 0.5;
stepResults = stepCounter.analyze(fitnessData);

figure('Name', 'Step Detection', 'Position', [100 100 800 400]);
stepCounter.plotSteps(gca);

%% 4. GPS Distance Calculator
gpsCalc = analysis.GPSDistanceCalculator();
gpsCalc.StrideLength = 2.5;  % feet
gpsResults = gpsCalc.analyze(fitnessData);

figure('Name', 'GPS Analysis', 'Position', [100 100 1000 400]);
subplot(1,2,1);
gpsCalc.plotRoute(gca);
subplot(1,2,2);
gpsCalc.plotSegmentDistances(gca);

%% 5. Compare Step Counting Methods
figure('Name', 'Step Count Comparison', 'Position', [100 100 600 400]);
stepMethods = categorical({'Acceleration', 'GPS'});
stepCounts = [stepResults.stepCount, gpsResults.estimatedSteps];
bar(stepMethods, stepCounts);
ylabel('Step Count');
title('Step Counting: Acceleration vs GPS Methods');
grid on;

%% 6. Activity Classification (requires trained model)
% Load activity data
activityData = data.loadFitnessData('../data/ActivityLogs.mat');

try
    classifier = analysis.ActivityClassifier();
    classifier.analyze(activityData);
    
    figure('Name', 'Activity Classification', 'Position', [100 100 1000 400]);
    subplot(1,2,1);
    classifier.plotDistribution(gca);
    subplot(1,2,2);
    classifier.plotTimeline(gca);
catch ME
    if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
        warning('Run train.trainActivityModel first to use ActivityClassifier');
    else
        rethrow(ME);
    end
end

%% 7. Summary Dashboard
figure('Name', 'Fitness Summary', 'Position', [100 100 1200 600]);

% Acceleration magnitude
subplot(2,3,1);
accelAnalyzer.plotMagnitude(gca);

% Step detection
subplot(2,3,2);
stepCounter.plotSteps(gca);

% GPS route
subplot(2,3,3);
gpsCalc.plotRoute(gca);

% Statistics bar chart
subplot(2,3,4);
stats = accelAnalyzer.getResults().stats;
statNames = categorical({'Mean', 'Std', 'Max', 'Min'});
statValues = [stats.mean, stats.std, stats.max, stats.min];
bar(statNames, statValues);
ylabel('Acceleration (m/s²)');
title('Acceleration Statistics');
grid on;

% Step comparison
subplot(2,3,5);
bar(stepMethods, stepCounts);
ylabel('Steps');
title('Step Count Comparison');
grid on;

% Distance summary
subplot(2,3,6);
distData = [gpsResults.totalDistanceFeet/5280, gpsResults.totalDistanceFeet];
bar(categorical({'Miles', 'Feet'}), distData);
ylabel('Distance');
title(sprintf('Total Distance: %.2f miles', gpsResults.totalDistanceMiles));
grid on;

sgtitle('Fitness Tracker Dashboard');
