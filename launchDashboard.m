function launchDashboard()
%LAUNCHDASHBOARD Launch the Fitness Tracker Dashboard
%   Launches the interactive dashboard for fitness data analysis.
%   Automatically sets up paths and opens the app.
%
%   Usage:
%       launchDashboard()
%
%   The dashboard provides:
%   - Data file selection and loading
%   - Step counter with adjustable sensitivity
%   - Activity classification visualization
%   - GPS route mapping
%   - Acceleration analysis
%
%   See also: FitnessTrackerDashboard

% Copyright 2024-2026 The MathWorks, Inc

% Setup paths first (must be done before creating app)
setupPaths();

% Launch the dashboard
fprintf('Launching Fitness Tracker Dashboard...\n');
app = FitnessTrackerDashboard();

% Display usage tips
fprintf('\n=== Dashboard Ready ===\n');
fprintf('1. Select a data file from the dropdown\n');
fprintf('2. Click "Load Data" to analyze\n');
fprintf('3. Adjust sensitivity slider to change step detection\n');
fprintf('4. Click "Refresh File List" to update available files\n\n');

end
