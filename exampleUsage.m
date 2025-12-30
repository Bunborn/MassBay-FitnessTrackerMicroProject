%% Fitness Tracker - Example Usage
% This script demonstrates how to analyze fitness data
% Similar to the workflow in ExampleModel.mlx

%% 1. Load the Data
clear
fitnessData = data.loadFitnessData('data/ExampleData.mat');

% Display what data we have
fprintf('Data loaded successfully!\n');
fprintf('Has Acceleration: %d\n', fitnessData.hasAcceleration);
fprintf('Has Position: %d\n', fitnessData.hasPosition);
fprintf('Has Orientation: %d\n', fitnessData.hasOrientation);

%% 2. Analyze Acceleration Data
% Create an acceleration analyzer
accelAnalyzer = analysis.AccelerationAnalysis();

% Run the analysis (pass fitnessData struct)
accelAnalyzer.analyze(fitnessData);

% Display the results
accelAnalyzer.displayResults();

%% 3. Plot Acceleration Magnitude
accelAnalyzer.plotMagnitude();

%% 4. Plot Acceleration Components (X, Y, Z)
accelAnalyzer.plotComponents();

%% 5. Count Steps
% Create a step counter
stepCounter = analysis.StepCounter();

% You can adjust the threshold and minimum peak distance
stepCounter.Threshold = 1.2;
stepCounter.MinPeakDistance = 0.5;

% Run the analysis (pass fitnessData struct)
stepCounter.analyze(fitnessData);

% Display results
stepCounter.displayResults();

%% 6. Plot Step Detection
stepCounter.plotSteps();

%% 7. Try Different Threshold Values
% Create a new step counter with different settings
stepCounter2 = analysis.StepCounter();
stepCounter2.Threshold = 1.5;  % Higher threshold = fewer steps detected
stepCounter2.MinPeakDistance = 0.3;

stepCounter2.analyze(fitnessData);
stepCounter2.displayResults();
stepCounter2.plotSteps();

%% 8. Using the runAnalysis Function
% You can also use the convenience function
analyzer = analysis.AccelerationAnalysis();
results = runAnalysis("data/ExampleData.mat", analyzer);

fprintf('Analysis completed: %s\n', results.analysisType);
fprintf('Mean acceleration magnitude: %.4f\n', results.stats.mean);

%% 9. Calculate Distance from GPS Data
% Load data with position information
clear
fitnessData = data.loadFitnessData('data/ExampleData.mat');

% Create GPS distance calculator
gpsCalc = analysis.GPSDistanceCalculator();

% You can adjust stride length if needed
gpsCalc.StrideLength = 2.5;  % feet

% Run the analysis (pass fitnessData struct)
gpsCalc.analyze(fitnessData);

% Display results
gpsCalc.displayResults();

%% 10. Plot GPS Route
gpsCalc.plotRoute();

%% 11. Plot Segment Distances
gpsCalc.plotSegmentDistances();

%% 12. Classify Activities with Machine Learning
% Note: You must run trainActivityModel.m first to create the model
% Load data with unknown activities
clear
fitnessData = data.loadFitnessData('data/ActivityLogs.mat');

% Create activity classifier
classifier = analysis.ActivityClassifier();

% Run classification (pass fitnessData struct)
classifier.analyze(fitnessData);

% Display results
classifier.displayResults();

%% 13. Plot Activity Distribution
classifier.plotDistribution();

%% 14. Plot Activity Timeline
classifier.plotTimeline();

%% 15. Compare All Analysis Methods
% Load data
clear
fitnessData = data.loadFitnessData('data/ExampleData.mat');

fprintf('\n=== Comparing Analysis Methods ===\n\n');

% Method 1: Acceleration-based step counting
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.2;
stepResults = stepCounter.analyze(fitnessData);
fprintf('Acceleration-based steps: %d\n', stepResults.stepCount);

% Method 2: GPS-based step counting
gpsCalc = analysis.GPSDistanceCalculator();
gpsResults = gpsCalc.analyze(fitnessData);
fprintf('GPS-based steps: %d\n', gpsResults.estimatedSteps);

fprintf('\nNote: Different methods may give different results!\n');
fprintf('Acceleration method counts actual steps taken.\n');
fprintf('GPS method estimates steps from distance traveled.\n');
