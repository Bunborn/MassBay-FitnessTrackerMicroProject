# Fitness Tracker - Quick Start Guide for Students

## What's New?
This project has been refactored with a modular architecture that makes it easier to:
- Test individual components
- Add new analysis functions
- Build a complete MATLAB App Designer application

## File Organization

```
📁 Project Root
├── 📁 tracker/              ← Product code
│   ├── 📁 +analysis/        ← Analysis implementations
│   ├── 📁 +data/            ← Data loading functions
│   ├── 📁 +utils/           ← Utility functions
│   ├── 📁 data/             ← Data files (.mat)
│   ├── 📁 docs/             ← Technical documentation
│   ├── 📄 exampleUsage.m    ← Examples of how to use the code
│   ├── 📄 runAnalysis.m     ← Main function to run analyses
│   └── 📄 trainActivityModel.m
├── 📁 tests/                ← Test files
├── 📁 course_materials/     ← Original mlx, instructions, rubric
├── 📄 QUICKSTART.md         ← This file
└── 📄 README.md
```

## Getting Started in 3 Steps

### Step 1: Add Tracker to Path & Run Example
```matlab
% Add tracker folder to MATLAB path
addpath('tracker');

% Open and run the example script
open tracker/exampleUsage.m
% Press F5 or click "Run" to see how everything works
```

### Step 2: Run the Tests
```matlab
% Run all tests to verify everything works
results = runtests('tests');
table(results)
```

### Step 3: Try Your Own Analysis
```matlab
% Add tracker to path (if not already done)
addpath('tracker');

% Load some data
fitnessData = data.loadFitnessData("data/ExampleData.mat");

% Create an analyzer
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.5;

% Run the analysis
results = stepCounter.analyze(fitnessData);

% See the results
stepCounter.displayResults();
```

## Common Tasks

### Load Fitness Data
```matlab
% Basic loading (from tracker folder)
fitnessData = data.loadFitnessData("data/ExampleData.mat");

% Check what data is available
if fitnessData.hasAcceleration
    disp('This file has acceleration data!');
end
```

### Run Different Analyses

#### Acceleration Analysis
```matlab
analyzer = analysis.AccelerationAnalysis();
results = analyzer.analyze(fitnessData);
analyzer.displayResults();
analyzer.plotMagnitude();
```

#### Step Counter
```matlab
stepCounter = analysis.StepCounter();
stepCounter.Threshold = 1.2;
results = stepCounter.analyze(fitnessData);
stepCounter.displayResults();
stepCounter.plotSteps();
```

### Use the Simple Orchestrator
```matlab
% One function does it all!
results = runAnalysis("data/ExampleData.mat", analysis.StepCounter());
```

## Creating Your Own Analysis Function

Want to add a new type of analysis? Here's a template:

```matlab
classdef MyNewAnalysis < analysis.AnalysisFunction
    
    properties (Constant)
        Name = "My New Analysis"
        Description = "What my analysis does"
    end
    
    methods
        function results = analyze(obj, fitnessData)
            % Your analysis code here
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            
            % Add your results
            results.myValue = 42;
        end
    end
end
```

Save this as `tracker/+analysis/MyNewAnalysis.m` and you can use it immediately!

## Testing Your Code

Add a test for your new analysis in `tests/analysis/`:

```matlab
% Create tests/analysis/MyNewAnalysisTest.m
classdef MyNewAnalysisTest < matlab.unittest.TestCase
    methods (Test)
        function testMyNewAnalysis(testCase)
            addpath('tracker');
            fitnessData = data.loadFitnessData('data/ExampleData.mat');
            
            analyzer = analysis.MyNewAnalysis();
            results = analyzer.analyze(fitnessData);
            
            testCase.verifyClass(results, 'struct');
            testCase.verifyTrue(isfield(results, 'myValue'));
        end
    end
end
```

## Tips for Success

1. **Start Simple**: Run `exampleUsage.m` first to see how everything works
2. **Read the Tests**: The test file shows many usage examples
3. **Use the Interface**: All analysis functions follow the same pattern
4. **Check the Data**: Use `fitnessData.hasAcceleration` etc. to see what's available
5. **Add Options**: Use MATLAB's `arguments` block for clean option handling

## Next Steps: Building an App

Once you're comfortable with the code, you can build a MATLAB App Designer app that:

1. **Loads data** using `data.loadFitnessData()`
2. **Lets users pick** which analysis to run
3. **Shows results** in a nice GUI
4. **Plots data** interactively

The architecture is designed to make this easy - all the hard work is done in the analysis functions!

## Need Help?

- Check `tracker/docs/ARCHITECTURE.md` for detailed documentation
- Look at `tracker/exampleUsage.m` for working examples
- Run the tests to see if everything is working
- Try modifying the example analyses to learn how they work
- Review original course materials in `course_materials/`

## Learning Objectives

By working with this architecture, you'll learn:
- ✅ Object-oriented programming in MATLAB
- ✅ How to write testable code
- ✅ Using MATLAB packages (+folder notation)
- ✅ Interface-based design patterns
- ✅ Unit testing with MATLAB Test framework
- ✅ Building modular, maintainable applications

Happy coding! 🚀
