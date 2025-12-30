<td>
<img src="course_materials/HackathonsBanner.jpg">
</td>

# Fitness Tracker with MATLAB

A modular fitness tracker application built with MATLAB, featuring acceleration analysis, step counting, GPS distance calculation, and ML-based activity classification.

## Quick Start

See **[QUICKSTART.md](QUICKSTART.md)** for a complete getting started guide.

```matlab
% Add product code to path
addpath('tracker');

% Load data and run analysis
fitnessData = data.loadFitnessData('tracker/data/ExampleData.mat');
stepCounter = analysis.StepCounter();
results = stepCounter.analyze(fitnessData);
stepCounter.displayResults();
```

## Project Structure

```
├── tracker/                 # Product code
│   ├── +analysis/           # Analysis functions (AccelerationAnalysis, StepCounter, etc.)
│   ├── +data/               # Data loading utilities
│   ├── +utils/              # Helper utilities
│   ├── data/                # Sample data files
│   ├── docs/                # Technical documentation
│   └── exampleUsage.m       # Usage examples
├── tests/                   # Unit tests
├── course_materials/        # Original hackathon materials
│   ├── ExampleModel.mlx     # Original live script example
│   ├── Instructions.pdf     # Hackathon instructions
│   └── GradingRubric.pdf    # Grading rubric
├── QUICKSTART.md            # Quick start guide
└── README.md                # This file
```

## Features

- **Acceleration Analysis**: Compute magnitude and statistics from accelerometer data
- **Step Counter**: Detect steps using peak detection algorithms
- **GPS Distance Calculator**: Calculate distance traveled from GPS coordinates
- **Activity Classifier**: ML-based activity classification (walking, running, sitting)

## Running Tests

```matlab
results = runtests('tests');
table(results)
```

## Original Course Materials

The `course_materials/` folder contains the original hackathon materials:
- **Instructions.pdf** - Detailed guide for using MATLAB Mobile and MATLAB Online
- **GradingRubric.pdf** - Grading rubric for the challenge
- **ExampleModel.mlx** - Original MATLAB Live Script example
