# App Designer Integration Guide

## Overview
This guide shows how to integrate the modular fitness tracker architecture into a MATLAB App Designer application.

## App Layout Design

```
┌─────────────────────────────────────────────────────────────┐
│  Fitness Tracker App                                    [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─── Data Loading Panel ───────────────────────────────┐  │
│  │  File Path: [___________________________] [Browse]   │  │
│  │  Status: ● Loaded                                     │  │
│  │  ☑ Has Acceleration  ☑ Has Position  ☐ Has Orient.  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─── Analysis Selection ────────────────────────────────┐  │
│  │  Analysis Type: [Acceleration Analysis    ▼]         │  │
│  │  Description: Analyzes acceleration data...           │  │
│  │                                                        │  │
│  │  ┌─ Options ─────────────────────────────────────┐   │  │
│  │  │  Threshold:        [1.2    ]                  │   │  │
│  │  │  Min Peak Distance:[0.5    ]                  │   │  │
│  │  │  ☑ Compute Stats   ☑ Plot Data               │   │  │
│  │  └───────────────────────────────────────────────┘   │  │
│  │                                                        │  │
│  │  [Run Analysis]                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─── Results Display ───────────────────────────────────┐  │
│  │  Analysis: Step Counter                               │  │
│  │  Timestamp: 2024-12-30 14:30:00                       │  │
│  │  Step Count: 127                                      │  │
│  │                                                        │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │         [Plot Area]                             │ │  │
│  │  │                                                  │ │  │
│  │  │                                                  │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  │  [Export Results]  [Clear]                            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Steps

### Step 1: Create the App in App Designer
1. Open MATLAB App Designer: `appdesigner`
2. Create a new blank app
3. Add the UI components shown in the layout above

### Step 2: Define App Properties

```matlab
properties (Access = private)
    fitnessData        % Loaded fitness data
    currentAnalyzer    % Current analysis function object
    availableAnalyzers % Cell array of available analysis classes
    analysisResults    % Results from last analysis
end
```

### Step 3: Initialize Available Analyzers

```matlab
% In startupFcn callback
function startupFcn(app)
    % Discover all available analysis functions
    app.availableAnalyzers = {
        analysis.AccelerationAnalysis()
        analysis.StepCounter()
        % Add more as you create them
    };
    
    % Populate dropdown with analyzer names
    analyzerNames = cell(length(app.availableAnalyzers), 1);
    for i = 1:length(app.availableAnalyzers)
        analyzerNames{i} = app.availableAnalyzers{i}.Name;
    end
    app.AnalysisTypeDropDown.Items = analyzerNames;
    
    % Set initial analyzer
    app.currentAnalyzer = app.availableAnalyzers{1};
    updateAnalysisDescription(app);
end
```

### Step 4: Implement File Browse Callback

```matlab
function BrowseButtonPushed(app, event)
    % Open file dialog
    [file, path] = uigetfile('*.mat', 'Select Fitness Data File');
    
    if isequal(file, 0)
        return; % User cancelled
    end
    
    fullPath = fullfile(path, file);
    app.FilePathEditField.Value = fullPath;
    
    % Load the data
    try
        app.fitnessData = data.loadFitnessData(fullPath);
        
        % Update status indicators
        app.StatusLamp.Color = 'green';
        app.HasAccelerationCheckBox.Value = app.fitnessData.hasAcceleration;
        app.HasPositionCheckBox.Value = app.fitnessData.hasPosition;
        app.HasOrientationCheckBox.Value = app.fitnessData.hasOrientation;
        
        uialert(app.UIFigure, 'Data loaded successfully!', 'Success');
    catch ME
        app.StatusLamp.Color = 'red';
        uialert(app.UIFigure, ME.message, 'Error Loading Data');
    end
end
```

### Step 5: Implement Analysis Selection Callback

```matlab
function AnalysisTypeDropDownValueChanged(app, event)
    selectedName = app.AnalysisTypeDropDown.Value;
    
    % Find the corresponding analyzer
    for i = 1:length(app.availableAnalyzers)
        if strcmp(app.availableAnalyzers{i}.Name, selectedName)
            app.currentAnalyzer = app.availableAnalyzers{i};
            break;
        end
    end
    
    % Update description
    updateAnalysisDescription(app);
    
    % Update options panel based on analyzer type
    updateOptionsPanel(app);
end

function updateAnalysisDescription(app)
    app.DescriptionTextArea.Value = app.currentAnalyzer.Description;
end
```

### Step 6: Implement Dynamic Options Panel

```matlab
function updateOptionsPanel(app)
    % Show/hide options based on analyzer type
    
    if isa(app.currentAnalyzer, 'analysis.StepCounter')
        % Show step counter options
        app.ThresholdSpinner.Visible = 'on';
        app.MinPeakDistanceSpinner.Visible = 'on';
        app.ThresholdLabel.Visible = 'on';
        app.MinPeakDistanceLabel.Visible = 'on';
        
    elseif isa(app.currentAnalyzer, 'analysis.AccelerationAnalysis')
        % Hide step counter specific options
        app.ThresholdSpinner.Visible = 'off';
        app.MinPeakDistanceSpinner.Visible = 'off';
        app.ThresholdLabel.Visible = 'off';
        app.MinPeakDistanceLabel.Visible = 'off';
    end
    
    % Common options always visible
    app.ComputeStatsCheckBox.Visible = 'on';
    app.PlotDataCheckBox.Visible = 'on';
end
```

### Step 7: Implement Run Analysis Callback

```matlab
function RunAnalysisButtonPushed(app, event)
    % Validate that data is loaded
    if isempty(app.fitnessData)
        uialert(app.UIFigure, 'Please load data first!', 'No Data');
        return;
    end
    
    % Gather options from UI
    analysisOpts = struct();
    
    % Common options
    analysisOpts.ComputeStats = app.ComputeStatsCheckBox.Value;
    analysisOpts.PlotData = false; % We'll plot in the app instead
    
    % Analyzer-specific options
    if isa(app.currentAnalyzer, 'analysis.StepCounter')
        analysisOpts.Threshold = app.ThresholdSpinner.Value;
        analysisOpts.MinPeakDistance = app.MinPeakDistanceSpinner.Value;
    end
    
    % Run the analysis
    try
        % Convert struct to name-value pairs
        optArgs = namedargs2cell(analysisOpts);
        
        % Run analysis
        app.analysisResults = app.currentAnalyzer.analyze(...
            app.fitnessData, optArgs{:});
        
        % Display results
        displayResults(app);
        
    catch ME
        uialert(app.UIFigure, ME.message, 'Analysis Error');
    end
end
```

### Step 8: Implement Results Display

```matlab
function displayResults(app)
    % Update text display
    resultText = sprintf('Analysis: %s\n', app.analysisResults.analysisType);
    resultText = [resultText sprintf('Timestamp: %s\n', ...
        string(app.analysisResults.timestamp))];
    
    % Add analyzer-specific results
    if isa(app.currentAnalyzer, 'analysis.StepCounter')
        resultText = [resultText sprintf('Step Count: %d\n', ...
            app.analysisResults.stepCount)];
    elseif isa(app.currentAnalyzer, 'analysis.AccelerationAnalysis')
        if isfield(app.analysisResults, 'stats')
            resultText = [resultText sprintf('\nStatistics:\n')];
            resultText = [resultText sprintf('  Mean: %.4f\n', ...
                app.analysisResults.stats.mean)];
            resultText = [resultText sprintf('  Std Dev: %.4f\n', ...
                app.analysisResults.stats.std)];
            resultText = [resultText sprintf('  Max: %.4f\n', ...
                app.analysisResults.stats.max)];
        end
    end
    
    app.ResultsTextArea.Value = resultText;
    
    % Plot results
    plotResults(app);
end
```

### Step 9: Implement Plotting

```matlab
function plotResults(app)
    % Clear previous plot
    cla(app.UIAxes);
    
    % Plot based on analyzer type
    if isa(app.currentAnalyzer, 'analysis.StepCounter')
        % Plot magnitude with detected steps
        plot(app.UIAxes, app.analysisResults.magnitude);
        hold(app.UIAxes, 'on');
        plot(app.UIAxes, ...
            app.analysisResults.peakLocations, ...
            app.analysisResults.peakValues, ...
            'rv', 'MarkerSize', 8);
        yline(app.UIAxes, app.analysisResults.threshold, 'r--');
        hold(app.UIAxes, 'off');
        
        title(app.UIAxes, sprintf('Steps Detected: %d', ...
            app.analysisResults.stepCount));
        xlabel(app.UIAxes, 'Sample');
        ylabel(app.UIAxes, 'Acceleration Magnitude');
        legend(app.UIAxes, {'Magnitude', 'Steps', 'Threshold'});
        
    elseif isa(app.currentAnalyzer, 'analysis.AccelerationAnalysis')
        % Plot acceleration magnitude
        plot(app.UIAxes, app.analysisResults.magnitude);
        title(app.UIAxes, 'Acceleration Magnitude');
        xlabel(app.UIAxes, 'Sample');
        ylabel(app.UIAxes, 'Magnitude');
    end
    
    grid(app.UIAxes, 'on');
end
```

### Step 10: Implement Export Functionality

```matlab
function ExportResultsButtonPushed(app, event)
    if isempty(app.analysisResults)
        uialert(app.UIFigure, 'No results to export!', 'No Results');
        return;
    end
    
    % Ask user for save location
    [file, path] = uiputfile('*.mat', 'Save Results As');
    
    if isequal(file, 0)
        return; % User cancelled
    end
    
    % Save results
    results = app.analysisResults; %#ok<NASGU>
    save(fullfile(path, file), 'results');
    
    uialert(app.UIFigure, 'Results exported successfully!', 'Success');
end
```

## Key Benefits of This Architecture

1. **Separation of Logic and UI**: Analysis logic is separate from UI code
2. **Easy to Test**: Analysis functions can be tested without the UI
3. **Swappable Analyses**: Adding new analyses doesn't require UI changes
4. **Reusable Components**: Same analysis functions work in scripts, apps, and tests
5. **Maintainable**: Each component has a clear responsibility

## Adding New Analysis Functions to the App

When you create a new analysis function:

1. Create the class file in `+analysis/` (inheriting from `AnalysisFunction`)
2. Add it to `availableAnalyzers` in `startupFcn`
3. Optionally add specific UI elements in `updateOptionsPanel`
4. Optionally add specific plotting in `plotResults`

That's it! The rest of the app works automatically.

## Testing the App

Before building the full app, test each analysis function:

```matlab
% Test in command window first
data = data.loadFitnessData("ExampleData.mat");
analyzer = analysis.StepCounter();
results = analyzer.analyze(data, 'Threshold', 1.2);
analyzer.displayResults();
```

Then integrate into the app once you know it works!

## Student Exercise Ideas

1. **Add a new analysis**: Create `analysis.ActivityClassifier` to detect walking vs running
2. **Improve the UI**: Add more visualization options
3. **Add data export**: Export plots as images
4. **Add comparison mode**: Run multiple analyses and compare results
5. **Add real-time mode**: Connect to MATLAB Mobile for live data

## Resources

- MATLAB App Designer Documentation: `doc appdesigner`
- Creating Apps Programmatically: `doc uifigure`
- UI Components: `doc uicomponents`
