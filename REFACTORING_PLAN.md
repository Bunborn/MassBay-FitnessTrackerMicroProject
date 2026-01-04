# Fitness Tracker Refactoring Plan

**Background:** I am working with a colleague to create a microproject for community college CS students based in MATLAB. I want to review and clean up the code so it i ssimple for students to understand and work with, but also reflect best coding practices. Let's review and make a plan of what changes we should make. Please remember that we should commit locally and push to the fork. Do not interact with the master branch.

**Goal:** Simplify the codebase for community college CS students while maintaining best practices per [MATLAB Coding Guidelines](MATLAB-coding-guidelines.md).

**Git Workflow:** Commit locally and push to fork. Do NOT interact with master branch.

---

## Phase 1: Remove Package Structure

### Current State
```
tracker/
├── +analysis/      # Package folder
├── +data/          # Package folder
├── +train/         # Package folder
└── +utils/         # Package folder
```

### Target State (lowercase folders, no packages)
```
tracker/
├── analysis/       # StepCounter, GPSDistanceCalculator, etc.
├── dataloading/    # loadFitnessData
├── modeltraining/  # trainActivityModel
└── utilities/      # timeElapsed
```

### Actions
- [ ] Rename `+analysis` → `analysis`
- [ ] Rename `+data` → `dataloading`
- [ ] Rename `+train` → `modeltraining`
- [ ] Rename `+utils` → `utilities`
- [ ] Move `+analysis/models/` → `analysis/models/`

---

## Phase 2: Update setupPaths.m

### Current
```matlab
addpath(fullfile(projectRoot, 'tracker'));
addpath(fullfile(projectRoot, 'tests'));
```

### Target
```matlab
addpath(fullfile(projectRoot, 'tracker'));
addpath(fullfile(projectRoot, 'tracker', 'analysis'));
addpath(fullfile(projectRoot, 'tracker', 'dataloading'));
addpath(fullfile(projectRoot, 'tracker', 'modeltraining'));
addpath(fullfile(projectRoot, 'tracker', 'utilities'));
addpath(fullfile(projectRoot, 'tests'));
```

---

## Phase 3: Remove Namespace Prefixes

### Files to Update

| File | Change |
|------|--------|
| `fitnessTrackerDemo.m` | `data.loadFitnessData` → `loadFitnessData`, `analysis.StepCounter` → `StepCounter`, etc. |
| `README.md` | Update all code examples |
| `ARCHITECTURE.md` | Update folder structure and examples |
| All test files | Remove `analysis.`, `data.`, `utils.` prefixes |

### Class Inheritance Updates

| File | Change |
|------|--------|
| `StepCounter.m` | `< analysis.AnalysisFunction` → `< AnalysisFunction` |
| `GPSDistanceCalculator.m` | `< analysis.AnalysisFunction` → `< AnalysisFunction` |
| `AccelerationAnalysis.m` | `< analysis.AnalysisFunction` → `< AnalysisFunction` |
| `ActivityClassifier.m` | `< analysis.AnalysisFunction` → `< AnalysisFunction` |

### Model Path Update
- `ActivityClassifier.m` line 148: Update model path logic after folder restructure

---

## Phase 4: Code Review vs MATLAB Coding Guidelines

### ✅ Compliant
- **Function names**: `loadFitnessData`, `timeElapsed` — lowerCamelCase ✓
- **Class names**: `StepCounter`, `GPSDistanceCalculator` — UpperCamelCase ✓
- **Properties**: `Threshold`, `MinPeakDistance`, `StrideLength` — UpperCamelCase ✓
- **Method names**: `analyze`, `plotSteps`, `plotRoute` — lowerCamelCase ✓
- **Error identifiers**: Proper format like `'analysis:StepCounter:NoData'` ✓

### ⚠️ Issues to Fix

| File | Issue | Guideline | Fix |
|------|-------|-----------|-----|
| `ActivityClassifierTest.m:37` | Typo: `activityPercentage` | Correctness | Change to `activityPercentages` |
| `timeElapsed.m` | Non-idiomatic while loop with manual index reset | Maintainability | Simplify using vectorized operations |
| `trainActivityModel.m:73` | Model path uses `+analysis` | Portability | Update after folder restructure |

### `timeElapsed.m` Improvement
**Current** (confusing for students):
```matlab
while i < arraySize
    if newArray(i) > newArray(i+1)
        newArray(i+1) = newArray(i+1) + 60;
        i = 1;  % Reset to beginning - non-standard pattern
    end
    i = i + 1;
end
```

**Proposed** (clearer):
```matlab
% Handle minute rollovers by detecting decreases and adding 60s
for i = 2:arraySize
    if newArray(i) < newArray(i-1)
        newArray(i:end) = newArray(i:end) + 60;
    end
end
```

---

## Phase 5: Consolidate Tests (Reduce Overtesting)

### Current Test Count
| Test File | Tests | Assessment |
|-----------|-------|------------|
| `AccelerationAnalysisTest.m` | 7 | Overlapping tests, redundant plot tests |
| `StepCounterTest.m` | 6 | `testDefaultPlot` duplicates `testPlotSteps` |
| `GPSDistanceCalculatorTest.m` | 7 | `testGPSDistanceResults` overlaps with basic test |
| `ActivityClassifierTest.m` | 5 | Reasonable |

### Target: 2-3 Tests Per Class

#### AccelerationAnalysisTest.m (7 → 3)
- **Keep**: `testAccelerationAnalysis` (merge result field checks)
- **Keep**: `testVisualization` (combine all plot tests)
- **Remove**: `testAccelerationAnalysisResults` (merge into basic test)
- **Remove**: `testPlotMagnitude`, `testPlotComponents`, `testDefaultPlot` (consolidate)
- **Remove**: `testDisplayResults`, `testGetResults` (low value for students)

#### StepCounterTest.m (6 → 3)
- **Keep**: `testStepCounter` (merge result checks)
- **Keep**: `testStepCounterProperties`
- **Keep**: `testDifferentThresholds` (demonstrates behavior verification)
- **Remove**: `testStepCounterResults` (merge into basic)
- **Remove**: `testPlotSteps`, `testDefaultPlot` (consolidate into one)

#### GPSDistanceCalculatorTest.m (7 → 3)
- **Keep**: `testGPSDistanceCalculation` (merge result checks)
- **Keep**: `testDifferentStrideLengths` (demonstrates behavior verification)
- **Keep**: `testVisualization` (combine plot tests)
- **Remove**: `testGPSDistanceProperties`, `testGPSDistanceResults`, individual plot tests

#### ActivityClassifierTest.m (5 → 3)
- **Keep**: `testModelLoading`
- **Keep**: `testActivityClassification`
- **Keep**: `testVisualization` (combine plot tests)
- **Remove**: `testDisplayResults`

### Test Design Principles for Students
1. **One basic functionality test** — Verify the class works and returns expected structure
2. **One property/configuration test** — Show how to customize behavior
3. **One behavior verification test** — Demonstrate testing logic, not hard-coded values

---

## Phase 6: Update Documentation

### README.md
- [ ] Update Quick Start examples (remove namespace prefixes)
- [ ] Update Project Structure diagram
- [ ] Update Analysis Classes table

### ARCHITECTURE.md
- [ ] Update folder structure diagram
- [ ] Update all code examples
- [ ] Remove package notation from component descriptions

### docs/ HTML Files
- [ ] `functions.html` — Remove `+package` notation, organize by area
- [ ] `tracker.html` — Update overview
- [ ] Individual class docs — Update syntax examples

### Documentation Reorganization
Organize by **functional area** (not folder paths) to teach modular design:

| Area | Purpose | Components |
|------|---------|------------|
| **Data Loading** | Load and validate sensor data from files | `loadFitnessData` |
| **Analysis** | Process fitness data to extract insights | `AccelerationAnalysis`, `StepCounter`, `GPSDistanceCalculator`, `ActivityClassifier` |
| **Model Training** | Train ML models for activity classification | `trainActivityModel` |
| **Utilities** | Shared helper functions | `timeElapsed` |

---

## Phase 7: Verification

- [ ] Run all tests: `results = runtests('tests'); table(results)`
- [ ] Run demo: `fitnessTrackerDemo`
- [ ] Verify MATLAB Online badge works

---

## Phase 8: Git Workflow

```bash
# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "Simplify project structure for students

- Remove package notation (+folders) for easier student access
- Consolidate tests to reduce complexity
- Update documentation to organize by functional area
- Fix ActivityClassifierTest typo (activityPercentage -> activityPercentages)
- Simplify timeElapsed.m for clarity"

# Push to fork (NOT master)
git push origin main
```

---

## Summary Checklist

### Structure
- [ ] Rename package folders to lowercase
- [ ] Update setupPaths.m
- [ ] Update all namespace references

### Code Quality
- [ ] Fix `ActivityClassifierTest.m` typo
- [ ] Simplify `timeElapsed.m`
- [ ] Update model path in `ActivityClassifier.m`

### Tests
- [ ] Consolidate `AccelerationAnalysisTest.m` (7 → 3)
- [ ] Consolidate `StepCounterTest.m` (6 → 3)
- [ ] Consolidate `GPSDistanceCalculatorTest.m` (7 → 3)
- [ ] Consolidate `ActivityClassifierTest.m` (5 → 3)

### Documentation
- [ ] Update README.md
- [ ] Update ARCHITECTURE.md
- [ ] Update docs/*.html files

### Verification
- [ ] All tests pass
- [ ] Demo runs successfully
- [ ] Committed and pushed to fork
