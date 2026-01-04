classdef FitnessTrackerDashboard < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        LeftPanel                   matlab.ui.container.Panel
        LoadDataButton              matlab.ui.control.Button
        DataFileDropDown            matlab.ui.control.DropDown
        RefreshButton               matlab.ui.control.Button
        
        % Step Counter Panel
        StepCounterPanel            matlab.ui.container.Panel
        StepCountLabel              matlab.ui.control.Label
        StepCountValueLabel         matlab.ui.control.Label
        SensitivityLabel            matlab.ui.control.Label
        ThresholdSlider             matlab.ui.control.Slider
        StepPlotAxes                matlab.ui.control.UIAxes
        
        % Activity Classification Panel
        ActivityPanel               matlab.ui.container.Panel
        ActivityPieAxes             matlab.ui.control.UIAxes
        ActivityTimelineAxes        matlab.ui.control.UIAxes
        
        % GPS Route Panel
        GPSPanel                    matlab.ui.container.Panel
        GPSRouteAxes                matlab.ui.control.UIAxes
        DistanceLabel               matlab.ui.control.Label
        DistanceValueLabel          matlab.ui.control.Label
        
        % Acceleration Analysis Panel
        AccelPanel                  matlab.ui.container.Panel
        AccelAxes                   matlab.ui.control.UIAxes
        MeanAccelLabel              matlab.ui.control.Label
        MeanAccelValueLabel         matlab.ui.control.Label
    end

    properties (Access = private)
        CurrentData                 % Currently loaded fitness data
        StepCounterObj              % StepCounter instance
        ActivityClassifierObj       % ActivityClassifier instance
        GPSCalculatorObj            % GPSDistanceCalculator instance
        AccelAnalyzerObj            % AccelerationAnalysis instance
        ProjectRoot                 % Project root directory
    end

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Get project root (dashboard is in subfolder)
            dashboardPath = fileparts(mfilename('fullpath'));
            app.ProjectRoot = fileparts(dashboardPath);
            
            % Initialize analysis objects
            app.StepCounterObj = StepCounter();
            app.GPSCalculatorObj = GPSDistanceCalculator();
            app.AccelAnalyzerObj = AccelerationAnalysis();
            
            % Check if activity model exists
            modelPath = fullfile(app.ProjectRoot, 'tracker', 'analysis', 'models', 'activityModel.mat');
            if isfile(modelPath)
                app.ActivityClassifierObj = ActivityClassifier();
            end
            
            % Populate data file dropdown
            refreshDataFiles(app);
        end

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
            selectedFile = app.DataFileDropDown.Value;
            if strcmp(selectedFile, 'Select a file...')
                uialert(app.UIFigure, 'Please select a data file', 'No File Selected');
                return;
            end
            
            % Load data
            dataPath = fullfile(app.ProjectRoot, 'data', selectedFile);
            try
                app.CurrentData = loadFitnessData(dataPath);
                
                % Update all analyses
                updateAllAnalyses(app);
                
            catch ME
                uialert(app.UIFigure, ME.message, 'Error Loading Data');
            end
        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            refreshDataFiles(app);
        end

        % Value changed function: ThresholdSlider
        function ThresholdSliderValueChanged(app, event)
            if ~isempty(app.CurrentData) && app.CurrentData.hasAcceleration
                app.StepCounterObj.Threshold = app.ThresholdSlider.Value;
                updateStepCounter(app);
            end
        end

        function refreshDataFiles(app)
            dataFolder = fullfile(app.ProjectRoot, 'data');
            if isfolder(dataFolder)
                files = dir(fullfile(dataFolder, '*.mat'));
                fileNames = {files.name};
                app.DataFileDropDown.Items = ['Select a file...', fileNames];
                app.DataFileDropDown.Value = 'Select a file...';
            end
        end

        function updateAllAnalyses(app)
            % Update all analysis panels with current data
            if app.CurrentData.hasAcceleration
                updateStepCounter(app);
                updateAccelerationAnalysis(app);
                
                if ~isempty(app.ActivityClassifierObj)
                    updateActivityClassification(app);
                end
            end
            
            if app.CurrentData.hasPosition
                updateGPSRoute(app);
            end
        end

        function updateStepCounter(app)
            if ~app.CurrentData.hasAcceleration
                return;
            end
            
            % Analyze
            results = app.StepCounterObj.analyze(app.CurrentData);
            
            % Update step count display
            app.StepCountValueLabel.Text = sprintf('%d steps', results.stepCount);
            
            % Use built-in plot method
            cla(app.StepPlotAxes);
            app.StepCounterObj.plotSteps(app.StepPlotAxes);
        end

        function updateActivityClassification(app)
            if ~app.CurrentData.hasAcceleration || isempty(app.ActivityClassifierObj)
                return;
            end
            
            try
                % Analyze
                app.ActivityClassifierObj.analyze(app.CurrentData);
                
                % Use built-in plot methods
                cla(app.ActivityPieAxes);
                app.ActivityClassifierObj.plotDistribution(app.ActivityPieAxes);
                
                cla(app.ActivityTimelineAxes);
                app.ActivityClassifierObj.plotTimeline(app.ActivityTimelineAxes);
            catch ME
                % Model might not be trained
                cla(app.ActivityPieAxes);
                text(app.ActivityPieAxes, 0.5, 0.5, 'Model not trained', ...
                    'HorizontalAlignment', 'center');
            end
        end

        function updateGPSRoute(app)
            if ~app.CurrentData.hasPosition
                % Show message when no GPS data available
                cla(app.GPSRouteAxes);
                text(app.GPSRouteAxes, 0.5, 0.5, 'No GPS data available', ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
                app.DistanceValueLabel.Text = 'N/A';
                return;
            end
            
            % Analyze
            results = app.GPSCalculatorObj.analyze(app.CurrentData);
            
            % Update distance display
            app.DistanceValueLabel.Text = sprintf('%.2f mi', results.totalDistanceMiles);
            
            % Use built-in plot method
            cla(app.GPSRouteAxes);
            app.GPSCalculatorObj.plotRoute(app.GPSRouteAxes);
        end

        function updateAccelerationAnalysis(app)
            if ~app.CurrentData.hasAcceleration
                return;
            end
            
            % Analyze
            results = app.AccelAnalyzerObj.analyze(app.CurrentData);
            
            % Update mean display
            app.MeanAccelValueLabel.Text = sprintf('%.2f g', results.stats.mean);
            
            % Use built-in plot method
            cla(app.AccelAxes);
            app.AccelAnalyzerObj.plotComponents(app.AccelAxes);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1200 800];
            app.UIFigure.Name = 'Fitness Tracker Dashboard';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {200, '1x', '1x'};
            app.GridLayout.RowHeight = {'1x', '1x'};

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Title = 'Data Control';
            app.LeftPanel.Layout.Row = [1 2];
            app.LeftPanel.Layout.Column = 1;

            % Create DataFileDropDown
            app.DataFileDropDown = uidropdown(app.LeftPanel);
            app.DataFileDropDown.Items = {'Select a file...'};
            app.DataFileDropDown.Position = [10 730 180 22];
            app.DataFileDropDown.Value = 'Select a file...';

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.LeftPanel, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.Position = [10 700 180 30];
            app.LoadDataButton.Text = 'Load Data';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.LeftPanel, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.Position = [10 665 180 30];
            app.RefreshButton.Text = 'Refresh File List';

            % Create StepCounterPanel
            app.StepCounterPanel = uipanel(app.GridLayout);
            app.StepCounterPanel.Title = 'Step Counter';
            app.StepCounterPanel.Layout.Row = 1;
            app.StepCounterPanel.Layout.Column = 2;

            % Create StepCountLabel
            app.StepCountLabel = uilabel(app.StepCounterPanel);
            app.StepCountLabel.FontSize = 14;
            app.StepCountLabel.FontWeight = 'bold';
            app.StepCountLabel.Position = [10 340 100 22];
            app.StepCountLabel.Text = 'Steps:';

            % Create StepCountValueLabel
            app.StepCountValueLabel = uilabel(app.StepCounterPanel);
            app.StepCountValueLabel.FontSize = 24;
            app.StepCountValueLabel.FontWeight = 'bold';
            app.StepCountValueLabel.Position = [10 310 200 30];
            app.StepCountValueLabel.Text = '0 steps';

            % Create SensitivityLabel
            app.SensitivityLabel = uilabel(app.StepCounterPanel);
            app.SensitivityLabel.Position = [10 280 100 22];
            app.SensitivityLabel.Text = 'Sensitivity:';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.StepCounterPanel);
            app.ThresholdSlider.Limits = [5 40];
            app.ThresholdSlider.ValueChangedFcn = createCallbackFcn(app, @ThresholdSliderValueChanged, true);
            app.ThresholdSlider.Position = [10 260 300 3];
            app.ThresholdSlider.Value = 15;

            % Create StepPlotAxes
            app.StepPlotAxes = uiaxes(app.StepCounterPanel);
            app.StepPlotAxes.Position = [10 10 450 230];

            % Create ActivityPanel
            app.ActivityPanel = uipanel(app.GridLayout);
            app.ActivityPanel.Title = 'Activity Classification';
            app.ActivityPanel.Layout.Row = 1;
            app.ActivityPanel.Layout.Column = 3;

            % Create ActivityPieAxes
            app.ActivityPieAxes = uiaxes(app.ActivityPanel);
            app.ActivityPieAxes.Position = [10 200 450 170];

            % Create ActivityTimelineAxes
            app.ActivityTimelineAxes = uiaxes(app.ActivityPanel);
            app.ActivityTimelineAxes.Position = [10 10 450 180];

            % Create GPSPanel
            app.GPSPanel = uipanel(app.GridLayout);
            app.GPSPanel.Title = 'GPS Route';
            app.GPSPanel.Layout.Row = 2;
            app.GPSPanel.Layout.Column = 2;

            % Create DistanceLabel
            app.DistanceLabel = uilabel(app.GPSPanel);
            app.DistanceLabel.FontSize = 14;
            app.DistanceLabel.FontWeight = 'bold';
            app.DistanceLabel.Position = [10 340 100 22];
            app.DistanceLabel.Text = 'Distance:';

            % Create DistanceValueLabel
            app.DistanceValueLabel = uilabel(app.GPSPanel);
            app.DistanceValueLabel.FontSize = 24;
            app.DistanceValueLabel.FontWeight = 'bold';
            app.DistanceValueLabel.Position = [10 310 200 30];
            app.DistanceValueLabel.Text = '0.00 mi';

            % Create GPSRouteAxes
            app.GPSRouteAxes = uiaxes(app.GPSPanel);
            app.GPSRouteAxes.Position = [10 10 450 290];

            % Create AccelPanel
            app.AccelPanel = uipanel(app.GridLayout);
            app.AccelPanel.Title = 'Acceleration Analysis';
            app.AccelPanel.Layout.Row = 2;
            app.AccelPanel.Layout.Column = 3;

            % Create MeanAccelLabel
            app.MeanAccelLabel = uilabel(app.AccelPanel);
            app.MeanAccelLabel.FontSize = 14;
            app.MeanAccelLabel.FontWeight = 'bold';
            app.MeanAccelLabel.Position = [10 340 150 22];
            app.MeanAccelLabel.Text = 'Mean Magnitude:';

            % Create MeanAccelValueLabel
            app.MeanAccelValueLabel = uilabel(app.AccelPanel);
            app.MeanAccelValueLabel.FontSize = 24;
            app.MeanAccelValueLabel.FontWeight = 'bold';
            app.MeanAccelValueLabel.Position = [10 310 200 30];
            app.MeanAccelValueLabel.Text = '0.00 g';

            % Create AccelAxes
            app.AccelAxes = uiaxes(app.AccelPanel);
            app.AccelAxes.Position = [10 10 450 290];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FitnessTrackerDashboard

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
