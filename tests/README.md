# Fitness Tracker Tests

## Test Organization

Tests are organized to mirror the product code structure:

```
tests/
├── data/
│   └── LoadFitnessDataTest.m           # Tests for data.loadFitnessData()
├── analysis/
│   ├── AccelerationAnalysisTest.m      # Tests for analysis.AccelerationAnalysis
│   ├── StepCounterTest.m               # Tests for analysis.StepCounter
│   ├── ActivityClassifierTest.m        # Tests for analysis.ActivityClassifier
│   └── GPSDistanceCalculatorTest.m     # Tests for analysis.GPSDistanceCalculator
├── utils/
│   └── TimeElapsedTest.m               # Tests for utils.timeElapsed()
└── README.md                           # This file
```

**Note:** Test folders do NOT use package prefixes (`+`) to avoid namespace conflicts with product code.

## Running Tests

### Run All Tests
```matlab
% Run all tests in the tests folder
results = runtests('tests');
table(results)
```

### Run Tests for Specific Package
```matlab
% Run all data tests
results = runtests('tests/data');

% Run all analysis tests
results = runtests('tests/analysis');

% Run all utils tests
results = runtests('tests/utils');
```

### Run Specific Test File
```matlab
% Run AccelerationAnalysis tests
results = runtests('tests/analysis/AccelerationAnalysisTest.m');

% Run StepCounter tests
results = runtests('tests/analysis/StepCounterTest.m');

% Run data loading tests
results = runtests('tests/data/LoadFitnessDataTest.m');
```

### Run Specific Test Method
```matlab
% Run a specific test method
results = runtests('tests/analysis/AccelerationAnalysisTest.m', ...
    'Name', 'testPlotMagnitude');
```

### Verbose Output
```matlab
% Run with detailed output
results = runtests('tests', 'OutputDetail', 'Verbose');
```

## Test Coverage

### Data Tests (`data/LoadFitnessDataTest.m`)
- ✅ Loading valid data files
- ✅ Handling invalid file paths
- ✅ Handling invalid file types
- ✅ Data validation and structuring

### Analysis Package Tests

#### AccelerationAnalysisTest.m
- ✅ Basic acceleration analysis
- ✅ Results structure validation
- ✅ Plot magnitude method
- ✅ Plot components method
- ✅ Default plot method
- ✅ Display results
- ✅ Get results

#### StepCounterTest.m
- ✅ Basic step counting
- ✅ Property configuration
- ✅ Results structure validation
- ✅ Plot steps method
- ✅ Default plot method
- ✅ Different threshold values

#### ActivityClassifierTest.m
- ✅ Model loading
- ✅ Activity classification
- ✅ Plot distribution
- ✅ Plot timeline
- ✅ Display results

#### GPSDistanceCalculatorTest.m
- ✅ Distance calculation
- ✅ Property configuration
- ✅ Results structure validation
- ✅ Plot route
- ✅ Plot segment distances
- ✅ Different stride lengths
- ✅ Display results

### Utils Tests (`utils/TimeElapsedTest.m`)
- ✅ Basic time elapsed calculation
- ✅ Minute rollover handling
- ✅ Single value handling

## Adding New Tests

When adding a new analysis function or utility, create a corresponding test file:

1. **Create test file in appropriate folder**
   ```
   tests/analysis/MyNewAnalysisTest.m
   ```

2. **Follow the naming convention**
   - Test file name: `[ClassName]Test.m`
   - Test class name: `[ClassName]Test`

3. **Use the test template**
   ```matlab
   classdef MyNewAnalysisTest < matlab.unittest.TestCase
       properties
           projectRoot
       end
       
       methods (TestClassSetup)
           function setupPath(testCase)
               thisFile = mfilename('fullpath');
               testsFolder = fileparts(fileparts(thisFile));
               testCase.projectRoot = fileparts(testsFolder);
               addpath(testCase.projectRoot);
           end
       end
       
       methods (Test)
           function testBasicFunctionality(testCase)
               % Your test code here
           end
       end
   end
   ```

## Test Data

Test data is located in the `data/` folder:
- `data/ExampleData.mat` - Sample fitness data with acceleration, position, orientation
- `data/ActivityLogs.mat` - Activity classification data

## Best Practices

1. **One test file per class/function** - Each product code file should have a corresponding test file
2. **Mirror the structure** - Test folder structure matches product code structure
3. **Descriptive test names** - Use clear, descriptive names for test methods
4. **Clean up after plots** - Always `close all` after creating figures in tests
5. **Use assumeFail for missing data** - If test data doesn't have required fields, use `assumeFail` instead of failing the test
6. **Test edge cases** - Include tests for boundary conditions and error cases

## Continuous Integration

These tests are designed to be run automatically in CI/CD pipelines. All tests should:
- Run independently without manual intervention
- Clean up resources (close figures, etc.)
- Use relative paths from project root
- Handle missing or incomplete test data gracefully
