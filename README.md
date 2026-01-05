<td>
<img src="course_materials/HackathonsBanner.jpg">
</td>

# Fitness Tracker with MATLAB

A modular fitness tracker for analyzing accelerometer and GPS data from MATLAB Mobile.

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=Bunborn/MassBay-FitnessTrackerMicroProject&file=fitnessTrackerDemo.m)

## Quick Start

### Option 1: Interactive Dashboard (Recommended)

Launch the modern UI dashboard:
```matlab
launchDashboard
```

### Option 2: Command Line Demo

Run the comprehensive demo script:
```matlab
fitnessTrackerDemo
```

### Documentation

- **Full Documentation:** Open [`docs/index.html`](docs/index.html) in a web browser
- **Examples:** See [`docs/examples.html`](docs/examples.html) for usage guides

## Project Structure

```
├── setupPaths.m             # Path setup helper
├── fitnessTrackerDemo.m     # Interactive demo script
├── launchDashboard.m        # Dashboard launcher script
├── dashboard/               # Interactive dashboard app
│   ├── FitnessTrackerDashboard.m  # Main app
│   └── README.md            # Dashboard documentation
├── tracker/                 # Product code
│   ├── analysis/            # Analysis classes
│   ├── dataloading/         # Data loading
│   ├── modeltraining/       # ML model training
│   ├── utilities/           # Utilities
│   └── ARCHITECTURE.md      # Technical documentation
├── data/                    # Sample data files
├── docs/                    # Examples and API docs
│   └── index.html           # Documentation home
├── tests/                   # Unit tests
└── course_materials/        # Background & prototyping resources
```

## Analysis Classes

| Class | Description |
|-------|-------------|
| `AccelerationAnalysis` | Magnitude and statistics from X,Y,Z accelerometer |
| `StepCounter` | Peak detection step counting |
| `GPSDistanceCalculator` | Distance from GPS coordinates |
| `ActivityClassifier` | ML classification (walking, running, sitting) |

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


