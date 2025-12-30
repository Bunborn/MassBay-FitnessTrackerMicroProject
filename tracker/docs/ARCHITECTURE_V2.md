# Fitness Tracker Architecture V2 - Simplified Design

## Overview
This document describes the simplified, student-friendly architecture for the Fitness Tracker project. The design follows patterns from the ExampleModel.mlx file to make it intuitive for community college CS students.

## Key Design Principles

### 1. No Options on analyze()
Analysis functions have a **fixed behavior** with no optional parameters. This makes them:
- Easier to understand
- Simpler to test
- More predictable

Configuration is done through **properties** that can be set before calling `analyze()`.

### 2. Multiple Plot Methods
Each analysis function can have multiple `plot*` methods:
- `plotMagnitude()`, `plotComponents()`, `plotSteps()`, etc.
- Each plot method accepts an optional `target` parameter (axes or figure)
- Default `plot()` method delegates to the most common visualization
- Enables easy integration with App Designer

### 3. Simple, Direct Usage
Usage patterns mirror the ExampleModel.mlx workflow:
```matlab
% Load data
load('ExampleData.mat');

% Create analyzer
analyzer = analysis.AccelerationAnalysis();

% Run analysis
analyzer.analyze(Acceleration);

% Display results
analyzer.displayResults();

% Plot results
analyzer.plotMagnitude();
```

## Architecture Components

### Base Class: `analysis.AnalysisFunction`

```matlab
classdef (Abstract) AnalysisFunction < handle
    properties (Abstract, Constant)
        Name
        Description
    end
    
    properties (Access = protected)
        results
    end
    
    methods (Abstract)
        results = analyze(obj, fitnessData)
    end
    
    methods
        function displayResults(obj)
        function r = getResults(obj)
        function plot(obj, target)  % Default plot method
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
        function plotImpl(obj, target)  % Override for custom default plot
    end
end
```

### Key Features:
- **No options on `analyze()`** - Clean, simple interface
- **`plot(target)` method** - Optional axes parameter for App Designer
- **Protected `plotImpl()`** - Subclasses override for default visualization

## Concrete Analysis Functions

### 1. AccelerationAnalysis

**Purpose:** Analyzes acceleration data to compute magnitude and statistics

**Usage:**
```matlab
analyzer = analysis.AccelerationAnalysis();
analyzer.analyze(Acceleration);
analyzer.displayResults();
```

**Plot Methods:**
- `plotMagnitude(target)` - Plots acceleration magnitude over time
- `plotComponents(target)` - Plots X, Y, Z components on same axes
- `plot(target)` - Default, delegates to `plotMagnitude()`

**Results Structure:**
```matlab
results.timestamp       % When analysis was run
results.analysisType    % Name of analysis
results.X, Y, Z         % Individual components
results.magnitude       % Computed magnitude
results.timeData        % Time information if available
results.stats.mean      % Mean magnitude
results.stats.std       % Standard deviation
results.stats.max       % Maximum magnitude
results.stats.min       % Minimum magnitude
results.stats.median    % Median magnitude
```

### 2. StepCounter

**Purpose:** Estimates step count from acceleration data using peak detection

**Properties (Configurable):**
```matlab
stepCounter.Threshold = 1.2;        % Minimum peak height
stepCounter.MinPeakDistance = 0.5;  % Minimum distance between peaks
```

**Usage:**
```matlab
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.5;  % Adjust threshold
stepCounter.analyze(Acceleration);
stepCounter.displayResults();
```

**Plot Methods:**
- `plotSteps(target)` - Plots magnitude with detected peaks highlighted
- `plot(target)` - Default, delegates to `plotSteps()`

**Results Structure:**
```matlab
results.timestamp          % When analysis was run
results.analysisType       % Name of analysis
results.stepCount          % Number of steps detected
results.peakLocations      % Indices of detected peaks
results.peakValues         % Values at detected peaks
results.magnitude          % Acceleration magnitude
results.timeData           % Time information if available
results.threshold          % Threshold used
results.minPeakDistance    % Min peak distance used
```

## Usage Patterns

### Pattern 1: Basic Analysis
```matlab
% Load data
load('ExampleData.mat');

% Analyze
analyzer = analysis.AccelerationAnalysis();
analyzer.analyze(Acceleration);

% View results
analyzer.displayResults();
analyzer.plotMagnitude();
```

### Pattern 2: Configurable Analysis
```matlab
% Load data
load('ExampleData.mat');

% Configure and analyze
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.5;
stepCounter.MinPeakDistance = 0.3;
stepCounter.analyze(Acceleration);

% View results
stepCounter.displayResults();
stepCounter.plotSteps();
```

### Pattern 3: Using Orchestrator
```matlab
% One-line analysis
analyzer = analysis.AccelerationAnalysis();
results = runAnalysis("ExampleData.mat", analyzer);

fprintf('Mean: %.4f\n', results.stats.mean);
```

### Pattern 4: Multiple Visualizations
```matlab
analyzer = analysis.AccelerationAnalysis();
analyzer.analyze(Acceleration);

% Create multiple plots
analyzer.plotMagnitude();
analyzer.plotComponents();
```

### Pattern 5: App Designer Integration
```matlab
% In App Designer callback
function AnalyzeButtonPushed(app, event)
    % Get data
    load(app.DataPath);
    
    % Analyze
    analyzer = analysis.AccelerationAnalysis();
    analyzer.analyze(Acceleration);
    
    % Plot in app axes
    analyzer.plotMagnitude(app.UIAxes);
    
    % Display results in text area
    app.ResultsTextArea.Value = sprintf('Mean: %.4f', ...
        analyzer.results.stats.mean);
end
```

## Testing Strategy

### Test Structure
Tests verify:
1. Analysis functions produce correct results
2. Plot methods work without errors
3. Properties can be configured
4. Interface compliance

### Example Tests
```matlab
function testAccelerationAnalysis(testCase)
    fitnessData = data.loadFitnessData('ExampleData.mat');
    
    analyzer = analysis.AccelerationAnalysis();
    results = analyzer.analyze(fitnessData);
    
    testCase.verifyClass(results, 'struct');
    testCase.verifyTrue(isfield(results, 'magnitude'));
    testCase.verifyGreaterThan(results.stats.mean, 0);
end

function testStepCounterProperties(testCase)
    stepCounter = analysis.StepCounter();
    
    % Test default values
    testCase.verifyEqual(stepCounter.Threshold, 1.2);
    
    % Test property modification
    stepCounter.Threshold = 1.5;
    testCase.verifyEqual(stepCounter.Threshold, 1.5);
end

function testPlotMethods(testCase)
    fitnessData = data.loadFitnessData('ExampleData.mat');
    analyzer = analysis.AccelerationAnalysis();
    analyzer.analyze(fitnessData);
    
    testCase.verifyWarningFree(@() analyzer.plotMagnitude());
    testCase.verifyWarningFree(@() analyzer.plotComponents());
    
    close all;
end
```

## App Designer Integration

### Simplified Integration Pattern

**1. Data Loading Panel**
```matlab
function LoadButtonPushed(app, event)
    [file, path] = uigetfile('*.mat');
    if file
        app.DataPath = fullfile(path, file);
        load(app.DataPath);
        app.StatusLabel.Text = 'Data loaded!';
    end
end
```

**2. Analysis Selection**
```matlab
function AnalysisDropDownValueChanged(app, event)
    switch app.AnalysisDropDown.Value
        case 'Acceleration Analysis'
            app.CurrentAnalyzer = analysis.AccelerationAnalysis();
        case 'Step Counter'
            app.CurrentAnalyzer = analysis.StepCounter();
    end
end
```

**3. Configuration Panel** (for StepCounter)
```matlab
function ThresholdSpinnerValueChanged(app, event)
    if isa(app.CurrentAnalyzer, 'analysis.StepCounter')
        app.CurrentAnalyzer.Threshold = app.ThresholdSpinner.Value;
    end
end
```

**4. Run Analysis**
```matlab
function RunButtonPushed(app, event)
    load(app.DataPath);
    
    % Run analysis
    app.CurrentAnalyzer.analyze(Acceleration);
    
    % Plot in app
    app.CurrentAnalyzer.plot(app.UIAxes);
    
    % Display results
    results = app.CurrentAnalyzer.getResults();
    app.ResultsTextArea.Value = formatResults(results);
end
```

## Benefits of This Architecture

### For Students
- ✅ **Simple to understand** - Mirrors mlx file patterns
- ✅ **Easy to test** - No complex option handling
- ✅ **Clear configuration** - Properties are explicit
- ✅ **Flexible plotting** - Multiple visualization options

### For Instructors
- ✅ **Teaches good practices** - Separation of concerns
- ✅ **Testable design** - Easy to write unit tests
- ✅ **Extensible** - Easy to add new analyses
- ✅ **App-ready** - Direct integration with App Designer

### For Development
- ✅ **Less complexity** - No option parsing
- ✅ **Better encapsulation** - Properties vs parameters
- ✅ **Reusable plots** - Same plot code for scripts and apps
- ✅ **Maintainable** - Clear, simple interfaces

## Adding New Analysis Functions

### Template
```matlab
classdef MyAnalysis < analysis.AnalysisFunction
    
    properties (Constant)
        Name = "My Analysis"
        Description = "What this analysis does"
    end
    
    properties
        % Configurable properties here
        MyParameter = 1.0
    end
    
    methods
        function results = analyze(obj, fitnessData)
            % Validate data
            if ~fitnessData.hasAcceleration
                error('analysis:MyAnalysis:NoData', ...
                    'Required data not available');
            end
            
            % Perform analysis
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            % Add your results
            
            obj.results = results;
        end
        
        function plotMyVisualization(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:MyAnalysis:NoResults', ...
                    'Run analyze() first');
            end
            
            if isempty(target)
                figure('Name', 'My Visualization');
                ax = gca;
            else
                ax = target;
            end
            
            % Create your plot using ax
            plot(ax, obj.results.data);
            xlabel(ax, 'X Label');
            ylabel(ax, 'Y Label');
            title(ax, 'My Title');
            grid(ax, 'on');
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            fprintf('\n=== %s ===\n', obj.Name);
            % Display your results
        end
        
        function plotImpl(obj, target)
            obj.plotMyVisualization(target);
        end
    end
end
```

## Migration from V1

### What Changed
1. **Removed:** Options parameter from `analyze()`
2. **Added:** Configurable properties on analysis classes
3. **Added:** Multiple plot methods with optional axes parameter
4. **Simplified:** Usage patterns to match mlx file

### Migration Guide
**Old (V1):**
```matlab
analyzer = analysis.StepCounter();
results = analyzer.analyze(fitnessData, ...
    'Threshold', 1.5, ...
    'PlotData', true);
```

**New (V2):**
```matlab
analyzer = analysis.StepCounter();
analyzer.Threshold = 1.5;
results = analyzer.analyze(fitnessData);
analyzer.plotSteps();
```

## Summary

This architecture provides:
- **Simple, intuitive interface** modeled after ExampleModel.mlx
- **Flexible plotting** with optional axes for App Designer
- **Easy configuration** through properties
- **Clean testing** without complex option handling
- **Student-friendly** design that's easy to learn and extend

The design prioritizes clarity and usability while maintaining the flexibility needed for both script-based analysis and App Designer integration.
