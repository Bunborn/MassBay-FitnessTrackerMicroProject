<td>
<img src="course_materials/HackathonsBanner.jpg">
</td>

# Fitness Tracker with MATLAB

A modular fitness tracker for analyzing accelerometer and GPS data from MATLAB Mobile.

## Quick Start

```matlab
% Add tracker to path
addpath('tracker');

% Load fitness data
fitnessData = data.loadFitnessData('data/ExampleData.mat');

% Analyze acceleration and count steps
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.2;
results = stepCounter.analyze(fitnessData);
stepCounter.plotSteps();

% Calculate distance from GPS
gpsCalc = analysis.GPSDistanceCalculator();
gpsCalc.analyze(fitnessData);
gpsCalc.plotRoute();
```

See `docs/exampleUsage.m` for a complete walkthrough with visualizations.

## Project Structure

```
├── tracker/                 # Product code
│   ├── +analysis/           # Analysis classes
│   ├── +data/               # Data loading
│   ├── +train/              # ML model training
│   ├── +utils/              # Utilities
│   └── ARCHITECTURE.md      # Technical documentation
├── data/                    # Sample data files
├── docs/                    # Examples and API docs
│   └── exampleUsage.m       # Interactive example script
├── tests/                   # Unit tests
└── course_materials/        # Background & prototyping resources
```

## Analysis Classes

| Class | Description |
|-------|-------------|
| `analysis.AccelerationAnalysis` | Magnitude and statistics from X,Y,Z accelerometer |
| `analysis.StepCounter` | Peak detection step counting |
| `analysis.GPSDistanceCalculator` | Distance from GPS coordinates |
| `analysis.ActivityClassifier` | ML classification (walking, running, sitting) |

## Course Materials

The `course_materials/` folder contains resources for background and prototyping:

- **ExampleModel.mlx** — Live Script demonstrating data exploration and analysis concepts
- **Instructions.pdf** — Guide for collecting data with MATLAB Mobile
- **GradingRubric.pdf** — Project requirements and grading criteria

These materials provide context for the project goals and can be used as a starting point for experimentation before working with the modular tracker code.

## Running Tests

```matlab
results = runtests('tests');
table(results)
```
