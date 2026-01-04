# Fitness Tracker Dashboard

An interactive MATLAB App Designer dashboard for visualizing and analyzing fitness data.

## Features

### Data Loading
- **Dropdown menu** to select from available data files in the `data/` folder
- **Automatic refresh** of file list
- **One-click loading** with automatic analysis

### Analysis Panels

#### 1. Step Counter
- Real-time step count display
- Interactive **sensitivity slider** (threshold: 0.8 - 2.0)
- Acceleration magnitude plot with detected peaks
- Automatically updates when threshold changes

#### 2. Activity Classification
- **Pie chart** showing activity distribution (sitting, walking, running)
- **Timeline plot** showing activity changes over time
- Requires trained model (run `trainActivityModel.m` first)

#### 3. GPS Route
- **Route visualization** on latitude/longitude plot
- Total distance display in miles
- Shows complete path with markers

#### 4. Acceleration Analysis
- **Multi-axis plot** (X, Y, Z components)
- Mean acceleration magnitude display
- Color-coded axes for easy identification

## Usage

### Launch the Dashboard

```matlab
% From project root (recommended)
launchDashboard
```

This will automatically setup paths and launch the app.

### Loading Data

1. Select a data file from the dropdown menu
2. Click "Load Data" button
3. All available analyses will automatically run and display

### Adjusting Sensitivity

- Use the sensitivity slider in the Step Counter panel
- Step count updates in real-time as you adjust the threshold

### Refreshing File List

- Click "Refresh File List" to update the dropdown with new data files

## Requirements

- MATLAB R2020b or later (for App Designer support)
- Fitness Tracker codebase with all dependencies
- Data files in `../data/` folder
- (Optional) Trained activity model for classification panel

## Layout

```
┌─────────────┬──────────────────┬──────────────────┐
│             │  Step Counter    │  Activity        │
│  Data       │  - Count         │  Classification  │
│  Control    │  - Sensitivity   │  - Pie Chart     │
│             │  - Plot          │  - Timeline      │
│  - Dropdown ├──────────────────┼──────────────────┤
│  - Load     │  GPS Route       │  Acceleration    │
│  - Refresh  │  - Distance      │  Analysis        │
│             │  - Map           │  - Components    │
└─────────────┴──────────────────┴──────────────────┘
```

## Design Inspiration

The dashboard design is inspired by modern fitness tracking applications with:
- Clean, card-based layout
- Real-time data visualization
- Interactive controls for analysis parameters
- Clear metric displays with large, readable fonts

## Troubleshooting

**Activity Classification shows "Model not trained"**
- Run `tracker/modeltraining/trainActivityModel.m` to train the model first

**No data files in dropdown**
- Ensure `.mat` files exist in the `data/` folder
- Click "Refresh File List" button

**Plots not updating**
- Ensure data file contains required fields (Acceleration, Position, etc.)
- Check MATLAB console for error messages

## Future Enhancements

- Export analysis results to file
- Compare multiple datasets
- Custom date range selection
- Heart rate analysis (if data available)
- Workout log table
