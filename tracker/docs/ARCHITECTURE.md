# Fitness Tracker Architecture Documentation

## Overview
This document describes the modular architecture designed for the Fitness Tracker project. The architecture enables testability, maintainability, and future integration with MATLAB App Designer.

## Design Principles
1. **Separation of Concerns**: Data loading, analysis, and utilities are separated into distinct packages
2. **Interface-Based Design**: Analysis functions implement a common interface for easy swapping
3. **Testability**: All components can be tested independently using MATLAB Test
4. **Extensibility**: New analysis functions can be added without modifying existing code

## Folder Structure

```
MassBay-FitnessTrackerMicroProject/
├── +data/                      # Data loading and management
│   └── loadFitnessData.m      # Main data loading function
├── +analysis/                  # Analysis implementations
│   ├── AnalysisFunction.m     # Abstract base class (interface)
│   ├── AccelerationAnalysis.m # Acceleration magnitude analysis
│   └── StepCounter.m          # Step counting via peak detection
├── +utils/                     # Utility functions
│   └── timeElapsed.m          # Time conversion utility
├── tests/                      # MATLAB Test files
│   └── FitnessTrackerTests.m  # Comprehensive test suite
├── runAnalysis.m              # Main orchestrator function
├── exampleUsage.m             # Usage examples
└── [original files remain unchanged]
```

## Core Components

### 1. Data Loading (`+data` package)

#### `data.loadFitnessData(dataPath, options)`
Loads fitness data from .mat files with validation.

**Parameters:**
- `dataPath` (string): Path to the .mat file
- `options.ValidateData` (logical): Whether to validate and structure the data (default: true)

**Returns:**
- `fitnessData` (struct): Structured data with metadata flags
  - `hasAcceleration`: Boolean indicating if acceleration data exists
  - `hasPosition`: Boolean indicating if position data exists
  - `hasOrientation`: Boolean indicating if orientation data exists

**Example:**
```matlab
fitnessData = data.loadFitnessData("ExampleData.mat");
```

### 2. Analysis Interface (`+analysis` package)

#### `analysis.AnalysisFunction` (Abstract Base Class)
Defines the contract that all analysis functions must implement.

**Abstract Properties:**
- `Name`: Display name of the analysis
- `Description`: Brief description of what the analysis does

**Abstract Methods:**
- `analyze(obj, fitnessData, options)`: Performs the analysis

**Concrete Methods:**
- `displayResults()`: Displays analysis results
- `getResults()`: Returns the results structure

#### Implementing New Analysis Functions
To create a new analysis function:

1. Inherit from `analysis.AnalysisFunction`
2. Define `Name` and `Description` as constant properties
3. Implement the `analyze()` method
4. Optionally override `displayResultsImpl()` for custom display

**Example:**
```matlab
classdef MyAnalysis < analysis.AnalysisFunction
    properties (Constant)
        Name = "My Analysis"
        Description = "Description of my analysis"
    end
    
    methods
        function results = analyze(obj, fitnessData, options)
            % Your analysis logic here
            results = struct();
            obj.results = results;
        end
    end
end
```

### 3. Built-in Analysis Functions

#### `analysis.AccelerationAnalysis`
Computes acceleration magnitude and statistics.

**Options:**
- `ComputeStats` (logical): Calculate statistical measures (default: true)
- `PlotData` (logical): Generate plots (default: false)

**Results:**
- `magnitude`: Acceleration magnitude vector
- `stats`: Structure with mean, std, max, min, median
- `timeData`: Time information if available

#### `analysis.StepCounter`
Estimates step count using peak detection on acceleration magnitude.

**Options:**
- `Threshold` (double): Minimum peak height (default: 1.2)
- `MinPeakDistance` (double): Minimum distance between peaks (default: 0.5)
- `PlotData` (logical): Generate plots (default: false)

**Results:**
- `stepCount`: Estimated number of steps
- `peakLocations`: Indices of detected peaks
- `peakValues`: Values at detected peaks

### 4. Orchestrator Function

#### `runAnalysis(dataPath, analysisFunction, options)`
Main function that coordinates data loading and analysis execution.

**Parameters:**
- `dataPath` (string): Path to data file
- `analysisFunction` (analysis.AnalysisFunction): Analysis object to run
- `options.ValidateData` (logical): Validate loaded data (default: true)
- `options.AnalysisOptions` (struct): Options to pass to the analysis function

**Returns:**
- `results` (struct): Analysis results

**Example:**
```matlab
analyzer = analysis.StepCounter();
results = runAnalysis("ExampleData.mat", analyzer, ...
    'AnalysisOptions', struct('Threshold', 1.5));
```

## Usage Examples

### Basic Usage
```matlab
% Load data
fitnessData = data.loadFitnessData("ExampleData.mat");

% Create and run analysis
analyzer = analysis.AccelerationAnalysis();
results = analyzer.analyze(fitnessData, 'ComputeStats', true);

% Display results
analyzer.displayResults();
```

### Using the Orchestrator
```matlab
% One-line analysis
results = runAnalysis("ExampleData.mat", ...
    analysis.StepCounter(), ...
    'AnalysisOptions', struct('Threshold', 1.2));
```

### Swapping Analysis Functions
```matlab
% Create different analyzers
analyzers = [
    analysis.AccelerationAnalysis()
    analysis.StepCounter()
];

% Run all analyses with the same data
for i = 1:length(analyzers)
    results = runAnalysis(dataPath, analyzers(i));
    analyzers(i).displayResults();
end
```

## Testing

Run the test suite:
```matlab
% Run all tests
results = runtests('tests/FitnessTrackerTests.m');

% Run specific test
results = runtests('tests/FitnessTrackerTests.m', 'Name', 'testStepCounter');

% Display test results
table(results)
```

## Future App Designer Integration

This architecture is designed to support a MATLAB App Designer application with:

### Planned App Components
1. **Data Loading Panel**
   - File browser to select data files
   - Uses `data.loadFitnessData()` to load selected file
   - Displays data metadata (hasAcceleration, hasPosition, etc.)

2. **Analysis Selection Panel**
   - Dropdown menu populated with available analysis functions
   - Dynamically discovers all classes inheriting from `analysis.AnalysisFunction`
   - Displays Name and Description of selected analysis

3. **Analysis Options Panel**
   - Dynamic UI elements based on selected analysis function
   - Input fields for analysis-specific options
   - Uses MATLAB's arguments validation

4. **Results Display Panel**
   - Tabular display of results
   - Plotting area for visualizations
   - Export functionality for results

### Integration Pattern
```matlab
% In App Designer callback
function RunAnalysisButtonPushed(app, event)
    % Get selected file path from UI
    dataPath = app.FilePathEditField.Value;
    
    % Get selected analysis function
    selectedAnalysis = app.AnalysisDropDown.Value;
    
    % Get options from UI
    analysisOpts = struct(...
        'Threshold', app.ThresholdSpinner.Value, ...
        'PlotData', true);
    
    % Run analysis
    results = runAnalysis(dataPath, selectedAnalysis, ...
        'AnalysisOptions', analysisOpts);
    
    % Display in app
    app.displayResults(results);
end
```

## Adding New Analysis Functions

To extend the system with new analysis capabilities:

1. Create a new class file in `+analysis/` folder
2. Inherit from `analysis.AnalysisFunction`
3. Implement required properties and methods
4. Add tests in `tests/FitnessTrackerTests.m`
5. The new analysis will automatically be available to the orchestrator

No changes needed to:
- Data loading logic
- Orchestrator function
- Existing analysis functions
- Test infrastructure (except adding new tests)

## Benefits of This Architecture

1. **Modularity**: Each component has a single, well-defined responsibility
2. **Testability**: All functions can be tested independently
3. **Maintainability**: Changes to one component don't affect others
4. **Extensibility**: New analyses can be added without modifying existing code
5. **Reusability**: Components can be used in different contexts (scripts, apps, tests)
6. **Type Safety**: MATLAB's arguments validation ensures correct usage
7. **Documentation**: Self-documenting through class properties and methods

## Migration from Original Code

The original files (`ExampleModel.mlx`, `timeElapsed.m`, data files) remain unchanged. The new architecture provides:

- A structured way to extract and test individual analyses from the Live Script
- A foundation for building an interactive app
- Better code organization for teaching CS students

Students can:
1. Start with the original Live Script to understand the workflow
2. Learn how to refactor code into modular components
3. Practice object-oriented programming with the analysis interface
4. Write tests to verify their implementations
5. Build a complete app using the modular components
