# Fitness Tracker Architecture

## Overview
A modular MATLAB fitness tracker featuring acceleration analysis, step counting, GPS distance calculation, and ML-based activity classification.

## Design Principles
1. **Separation of Concerns**: Data, analysis, training, and utilities in distinct modules
2. **Interface-Based Design**: Analysis functions implement a common interface
3. **Testability**: All components independently testable with MATLAB Test
4. **Extensibility**: Add new analysis functions without modifying existing code

## Folder Structure

```
MassBay-FitnessTrackerMicroProject/
├── tracker/                    # Product code
│   ├── analysis/               # Analysis implementations
│   │   ├── AnalysisFunction.m  # Abstract base class
│   │   ├── AccelerationAnalysis.m
│   │   ├── StepCounter.m
│   │   ├── GPSDistanceCalculator.m
│   │   └── ActivityClassifier.m
│   ├── dataloading/            # Data loading
│   │   └── loadFitnessData.m
│   ├── modeltraining/          # Model training
│   │   └── trainActivityModel.m
│   └── utilities/              # Utilities
│       └── timeElapsed.m
├── data/                       # Data files
│   ├── ExampleData.mat
│   └── ActivityLogs.mat
├── tests/                      # Unit tests
├── docs/                       # API documentation
├── course_materials/           # Learning resources
├── ARCHITECTURE.md             # This file
├── QUICKSTART.md               # Getting started guide
└── README.md
```

## Core Components

### 1. Data Loading

#### `loadFitnessData(dataPath, options)`
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
fitnessData = loadFitnessData("data/ExampleData.mat");
```

### 2. Analysis Interface

#### `AnalysisFunction` (Abstract Base Class)
Defines the contract that all analysis functions must implement.

**Properties:**
- `Name`: Display name of the analysis
- `Description`: Brief description of what the analysis does

**Methods:**
- `analyze(obj, fitnessData)`: Performs the analysis, returns results struct
- `displayResults()`: Displays analysis results to console
- `plot()`: Generates default visualization
- `getResults()`: Returns the results structure

### 3. Built-in Analysis Functions

#### `AccelerationAnalysis`
Computes acceleration magnitude and statistics.

**Results:** `magnitude`, `X`, `Y`, `Z`, `timeData`, `stats` (mean, std, max, min, median)

**Plot Methods:** `plotMagnitude()`, `plotComponents()`

#### `StepCounter`
Estimates step count using peak detection on acceleration magnitude.

**Properties:** `Threshold` (default: 1.2), `MinPeakDistance` (default: 0.5)

**Results:** `stepCount`, `peakLocations`, `peakValues`, `magnitude`

**Plot Methods:** `plotSteps()`

#### `GPSDistanceCalculator`
Calculates distance traveled from GPS coordinates.

**Properties:** `StrideLength` (default: 2.5 ft)

**Results:** `totalDistanceMiles`, `totalDistanceFeet`, `estimatedSteps`, `segmentDistances`

**Plot Methods:** `plotRoute()`, `plotSegmentDistances()`

#### `ActivityClassifier`
ML-based activity classification (walking, running, sitting).

**Results:** `predictions`, `uniqueActivities`, `activityCounts`, `activityPercentages`

**Plot Methods:** `plotDistribution()`, `plotTimeline()`

### 4. Orchestrator Function

#### `runAnalysis(dataPath, analysisFunction)`
Coordinates data loading and analysis execution.

```matlab
results = runAnalysis("data/ExampleData.mat", StepCounter());
```

## Usage Examples

```matlab
% Setup paths
setupPaths();

% Load data
fitnessData = loadFitnessData("data/ExampleData.mat");

% Acceleration analysis
accel = AccelerationAnalysis();
accel.analyze(fitnessData);
accel.plotMagnitude();

% Step counting
steps = StepCounter();
steps.Threshold = 1.2;
results = steps.analyze(fitnessData);
steps.plotSteps();

% GPS distance
gps = GPSDistanceCalculator();
gps.analyze(fitnessData);
gps.plotRoute();

% Activity classification (requires trained model)
classifier = ActivityClassifier();
classifier.analyze(fitnessData);
classifier.plotDistribution();
```

## Testing

```matlab
results = runtests('tests');
table(results)
```

## Adding New Analysis Functions

1. Create class in `tracker/analysis/` inheriting from `AnalysisFunction`
2. Define `Name` and `Description` constant properties
3. Implement `analyze(obj, fitnessData)` method
4. Add plot methods as needed
5. Add tests in `tests/analysis/`
