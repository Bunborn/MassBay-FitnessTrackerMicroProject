# Fitness Tracker - Quick Start Guide for Students

## What's New?
This project has been refactored with a modular architecture that makes it easier to:
- Test individual components
- Add new analysis functions
- Build a complete MATLAB App Designer application

## File Organization

```
📁 Your Project
├── 📁 +data/           ← Data loading functions
├── 📁 +analysis/       ← Analysis implementations
├── 📁 +utils/          ← Utility functions
├── 📁 tests/           ← Test files
├── 📄 runAnalysis.m    ← Main function to run analyses
├── 📄 exampleUsage.m   ← Examples of how to use the new code
└── [original files]    ← Your original project files (unchanged)
```

## Getting Started in 3 Steps

### Step 1: Run the Example
```matlab
% Open and run the example script
open exampleUsage.m
% Press F5 or click "Run" to see how everything works
```

### Step 2: Run the Tests
```matlab
% Run all tests to verify everything works
results = runtests('tests/FitnessTrackerTests.m');
table(results)
```

### Step 3: Try Your Own Analysis
```matlab
% Load some data
data = data.loadFitnessData("ExampleData.mat");

% Create an analyzer
analyzer = analysis.StepCounter();

% Run the analysis
results = analyzer.analyze(data, 'Threshold', 1.5);

% See the results
analyzer.displayResults();
```

## Common Tasks

### Load Fitness Data
```matlab
% Basic loading
fitnessData = data.loadFitnessData("ExampleData.mat");

% Check what data is available
if fitnessData.hasAcceleration
    disp('This file has acceleration data!');
end
```

### Run Different Analyses

#### Acceleration Analysis
```matlab
analyzer = analysis.AccelerationAnalysis();
results = analyzer.analyze(fitnessData, ...
    'ComputeStats', true, ...
    'PlotData', true);
analyzer.displayResults();
```

#### Step Counter
```matlab
stepCounter = analysis.StepCounter();
results = stepCounter.analyze(fitnessData, ...
    'Threshold', 1.2, ...
    'PlotData', true);
stepCounter.displayResults();
```

### Use the Simple Orchestrator
```matlab
% One function does it all!
results = runAnalysis("ExampleData.mat", ...
    analysis.StepCounter(), ...
    'AnalysisOptions', struct('Threshold', 1.5, 'PlotData', true));
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
        function results = analyze(obj, fitnessData, options)
            arguments
                obj
                fitnessData struct
                options.MyOption (1,1) double = 1.0
            end
            
            % Your analysis code here
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            
            % Add your results
            results.myValue = 42;
            
            % Save results
            obj.results = results;
        end
    end
end
```

Save this as `+analysis/MyNewAnalysis.m` and you can use it immediately!

## Testing Your Code

Add a test for your new analysis:

```matlab
% In tests/FitnessTrackerTests.m, add a new test method:
function testMyNewAnalysis(testCase)
    dataPath = fullfile(testCase.projectRoot, 'ExampleData.mat');
    
    analyzer = analysis.MyNewAnalysis();
    results = runAnalysis(dataPath, analyzer);
    
    testCase.verifyClass(results, 'struct');
    testCase.verifyTrue(isfield(results, 'myValue'));
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

- Check `ARCHITECTURE.md` for detailed documentation
- Look at `exampleUsage.m` for working examples
- Run the tests to see if everything is working
- Try modifying the example analyses to learn how they work

## Learning Objectives

By working with this architecture, you'll learn:
- ✅ Object-oriented programming in MATLAB
- ✅ How to write testable code
- ✅ Using MATLAB packages (+folder notation)
- ✅ Interface-based design patterns
- ✅ Unit testing with MATLAB Test framework
- ✅ Building modular, maintainable applications

Happy coding! 🚀
