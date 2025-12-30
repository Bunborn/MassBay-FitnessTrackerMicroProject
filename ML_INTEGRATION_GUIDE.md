# Machine Learning Integration Guide

## Overview
This guide explains how machine learning is integrated into the Fitness Tracker architecture, including model training, usage, and testing.

## Architecture Design

### **Pre-trained Model Approach**
We use a **pre-trained model** approach where:
1. Model is trained once and saved to disk
2. Analysis class loads the pre-trained model
3. New data is classified using the loaded model

### **Why Pre-trained Models?**
- ✅ **Consistent results** - Same model, same predictions
- ✅ **Fast analysis** - No training delay
- ✅ **Testable** - Known model behavior
- ✅ **Realistic** - Mirrors production ML systems
- ✅ **Student-friendly** - Separates training from usage

## Components

### 1. Training Script: `trainActivityModel.m`

**Purpose:** Train and save the activity classification model

**What it does:**
- Loads training data (sitting, walking, running activities)
- Prepares labeled dataset
- Trains a classification tree model
- Validates model accuracy
- Saves trained model to `+analysis/models/activityModel.mat`

**Usage:**
```matlab
% Run once to create the model
trainActivityModel
```

**Output:**
- Trained model saved to `+analysis/models/activityModel.mat`
- Validation accuracy displayed
- Confusion matrix plot
- Test predictions on unknown data

### 2. Analysis Class: `analysis.ActivityClassifier`

**Purpose:** Use pre-trained model to classify activities

**Properties:**
- `Name` - "Activity Classifier"
- `Description` - What the analysis does
- `trainedModel` (private) - Loaded ML model

**Methods:**
- `analyze(fitnessData)` - Classify activities in acceleration data
- `plotDistribution(target)` - Pie chart of activity distribution
- `plotTimeline(target)` - Activity over time
- `displayResults()` - Print classification results

**Usage:**
```matlab
% Load data
load('data/ActivityLogs.mat');

% Create classifier (automatically loads model)
classifier = analysis.ActivityClassifier();

% Classify activities
classifier.analyze(unknownAcceleration);

% View results
classifier.displayResults();
classifier.plotDistribution();
```

### 3. Model Storage

**Location:** `+analysis/models/activityModel.mat`

**Structure:**
```matlab
activityModel = struct(
    'model',        % Trained classification model
    'trainDate',    % When model was trained
    'accuracy',     % Validation accuracy
    'classes',      % {'sitting', 'walking', 'running'}
    'features'      % {'X', 'Y', 'Z'}
);
```

## Workflow

### **Training Phase** (Run Once)

```matlab
%% Step 1: Train the Model
trainActivityModel

% This will:
% 1. Load ActivityLogs.mat
% 2. Prepare training data
% 3. Train classification tree
% 4. Validate accuracy
% 5. Save to +analysis/models/activityModel.mat
```

### **Usage Phase** (Repeated)

```matlab
%% Step 2: Use the Trained Model
load('data/ActivityLogs.mat');

classifier = analysis.ActivityClassifier();
classifier.analyze(unknownAcceleration);
classifier.displayResults();
classifier.plotDistribution();
```

## Integration with Architecture

### **Follows Same Pattern as Other Analyses**

```matlab
% All analysis classes work the same way:

% Acceleration analysis
accelAnalyzer = analysis.AccelerationAnalysis();
accelAnalyzer.analyze(Acceleration);
accelAnalyzer.plot();

% Step counting
stepCounter = analysis.StepCounter();
stepCounter.analyze(Acceleration);
stepCounter.plot();

% Activity classification
classifier = analysis.ActivityClassifier();
classifier.analyze(unknownAcceleration);
classifier.plot();

% GPS distance
gpsCalc = analysis.GPSDistanceCalculator();
gpsCalc.analyze(Position);
gpsCalc.plot();
```

### **Works with runAnalysis Orchestrator**

```matlab
% Can use with orchestrator function
classifier = analysis.ActivityClassifier();
results = runAnalysis("data/ActivityLogs.mat", classifier);
```

### **Works in App Designer**

```matlab
% In App Designer callback
function ClassifyButtonPushed(app, event)
    load(app.DataPath);
    
    classifier = analysis.ActivityClassifier();
    classifier.analyze(unknownAcceleration);
    
    % Plot in app axes
    classifier.plotDistribution(app.UIAxes);
    
    % Display results
    results = classifier.getResults();
    app.ResultsText.Value = sprintf('Sitting: %.1f%%\nWalking: %.1f%%\nRunning: %.1f%%', ...
        results.activityPercentages.sitting, ...
        results.activityPercentages.walking, ...
        results.activityPercentages.running);
end
```

## Testing

### **Test Structure**

Tests are in `tests/+analysis/ActivityClassifierTest.m`

**Test Cases:**
1. Model loading
2. Activity classification
3. Plot distribution
4. Plot timeline
5. Display results

### **Running Tests**

```matlab
% Run all activity classifier tests
runtests('tests/+analysis/ActivityClassifierTest.m')

% Run specific test
runtests('tests/+analysis/ActivityClassifierTest.m', ...
    'Name', 'testActivityClassification')
```

### **Handling Missing Model**

Tests gracefully handle missing model:
```matlab
try
    classifier = analysis.ActivityClassifier();
    % ... test code ...
catch ME
    if strcmp(ME.identifier, 'analysis:ActivityClassifier:ModelNotFound')
        testCase.assumeFail('Model not trained. Run trainActivityModel.m first.');
    else
        rethrow(ME);
    end
end
```

## Training Data

### **ActivityLogs.mat Contents**

- `sitAcceleration` - Timetable of acceleration while sitting
- `walkAcceleration` - Timetable of acceleration while walking
- `runAcceleration` - Timetable of acceleration while running
- `unknownAcceleration` - Unlabeled data for testing

### **Data Format**

```matlab
% Each dataset is a timetable with:
% - Timestamp (time)
% - X (acceleration in m/s²)
% - Y (acceleration in m/s²)
% - Z (acceleration in m/s²)
```

## Model Details

### **Algorithm**
Classification Tree (`fitctree`)

**Why Classification Tree?**
- Fast training and prediction
- Interpretable results
- Good for teaching ML concepts
- Handles non-linear relationships
- No feature scaling needed

### **Features**
- X acceleration
- Y acceleration
- Z acceleration

### **Classes**
- sitting
- walking
- running

### **Training/Validation Split**
- 80% training
- 20% validation

## Customization

### **Retraining the Model**

To retrain with different parameters:

```matlab
% Edit trainActivityModel.m
% Change the training algorithm or parameters:

% Example: Use SVM instead of tree
trainedModel = fitcsvm(trainingData, 'Activity', ...
    'PredictorNames', {'X', 'Y', 'Z'}, ...
    'KernelFunction', 'rbf');

% Save as before
save('+analysis/models/activityModel.mat', 'activityModel');
```

### **Adding New Activities**

To add new activity types:

1. Collect labeled data for new activity
2. Add to training data in `trainActivityModel.m`
3. Retrain model
4. Update `ActivityClassifier` if needed

### **Using Different Features**

To use additional features (e.g., magnitude):

```matlab
% In trainActivityModel.m
allAcceleration.Magnitude = sqrt(allAcceleration.X.^2 + ...
                                  allAcceleration.Y.^2 + ...
                                  allAcceleration.Z.^2);

trainedModel = fitctree(trainingData, 'Activity', ...
    'PredictorNames', {'X', 'Y', 'Z', 'Magnitude'});
```

## Error Handling

### **Model Not Found**

```matlab
% Error thrown if model file doesn't exist
Error using analysis.ActivityClassifier
Pre-trained model not found. Please run trainActivityModel.m first.
Expected location: +analysis/models/activityModel.mat
```

**Solution:** Run `trainActivityModel.m` to create the model

### **No Acceleration Data**

```matlab
% Error thrown if data doesn't have acceleration
Error using analysis.ActivityClassifier/analyze
Fitness data does not contain acceleration information
```

**Solution:** Ensure data has `Acceleration` field

## Best Practices

### **For Students**

1. **Understand training first** - Run `trainActivityModel.m` and examine the code
2. **Check model accuracy** - Look at validation results
3. **Experiment with parameters** - Try different thresholds, algorithms
4. **Visualize results** - Use plot methods to understand predictions
5. **Compare methods** - See how ML predictions differ from rule-based methods

### **For Instructors**

1. **Pre-train models** - Have models ready before class
2. **Show training process** - Walk through `trainActivityModel.m`
3. **Discuss accuracy** - Explain validation metrics
4. **Encourage experimentation** - Let students retrain with different parameters
5. **Connect to theory** - Link to ML concepts (overfitting, validation, etc.)

### **For Development**

1. **Version control models** - Track model files in git (if small) or document versions
2. **Document accuracy** - Keep record of model performance
3. **Test with edge cases** - Verify behavior with unusual data
4. **Handle missing models gracefully** - Provide clear error messages
5. **Keep training separate** - Don't mix training and inference code

## Comparison: ML vs Rule-Based

### **Activity Classification**

**Machine Learning Approach:**
- Learns patterns from labeled data
- Adapts to different movement styles
- Can handle complex patterns
- Requires training data
- Black box (less interpretable)

**Rule-Based Approach (like StepCounter):**
- Uses explicit rules (peak detection)
- Deterministic and predictable
- Easy to understand and debug
- No training needed
- May miss edge cases

### **When to Use Each**

**Use ML when:**
- Pattern is complex or unknown
- Have labeled training data
- Need to adapt to different users
- Accuracy is critical

**Use rules when:**
- Pattern is well-understood
- No training data available
- Interpretability is important
- Simplicity is valued

## Summary

The ML integration provides:
- ✅ **Professional workflow** - Training → Saving → Loading → Inference
- ✅ **Clean architecture** - Follows same pattern as other analyses
- ✅ **Testable** - Comprehensive test coverage
- ✅ **Educational** - Students learn real ML deployment
- ✅ **Extensible** - Easy to add new models or retrain

Students get hands-on experience with:
- Training ML models
- Saving/loading models
- Using pre-trained models
- Evaluating model performance
- Deploying ML in applications
