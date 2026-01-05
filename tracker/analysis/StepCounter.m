classdef StepCounter < AnalysisFunction
    
    properties (Constant)
        Name = "Step Counter"
        Description = "Estimates step count from acceleration data using peak detection"
    end
    
    properties
        Threshold = 15
        MinPeakDistance = 0.5
    end
    
    methods
        function results = analyze(obj, fitnessData)
            if ~fitnessData.hasAcceleration
                error('analysis:StepCounter:NoData', ...
                    'Fitness data does not contain acceleration information');
            end
            
            accel = fitnessData.Acceleration;
            
            if istimetable(accel)
                magnitude = sqrt(accel.X.^2 + accel.Y.^2 + accel.Z.^2);
                timeData = accel.Properties.RowTimes;
            elseif isstruct(accel)
                magnitude = sqrt(accel.X.^2 + accel.Y.^2 + accel.Z.^2);
                if isfield(accel, 'Timestamp')
                    timeData = accel.Timestamp;
                else
                    timeData = [];
                end
            else
                error('analysis:StepCounter:InvalidFormat', ...
                    'Unexpected acceleration data format');
            end
            
            % Suppress warning if threshold is too high
            warnState = warning('off', 'MATLAB:findpeaks:largeMinPeakHeight');
            cleanupObj = onCleanup(@() warning(warnState));
            
            [peaks, locs] = findpeaks(magnitude, ...
                'MinPeakHeight', obj.Threshold, ...
                'MinPeakDistance', obj.MinPeakDistance);
            
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            results.stepCount = length(peaks);
            results.peakLocations = locs;
            results.peakValues = peaks;
            results.magnitude = magnitude;
            results.timeData = timeData;
            results.threshold = obj.Threshold;
            results.minPeakDistance = obj.MinPeakDistance;
            
            obj.results = results;
        end
        
        function plotSteps(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:StepCounter:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Step Counter Analysis');
                ax = axes(f);
            else
                ax = target;
            end
            
            plot(ax, obj.results.magnitude);
            hold(ax, 'on');
            
            % Only plot peaks if any were detected
            if ~isempty(obj.results.peakLocations)
                plot(ax, obj.results.peakLocations, obj.results.peakValues, 'rv', 'MarkerSize', 8);
                yline(ax, obj.results.threshold, 'r--', 'Threshold');
                legend(ax, 'Magnitude', 'Detected Steps', 'Threshold');
            else
                yline(ax, obj.results.threshold, 'r--', 'Threshold');
                legend(ax, 'Magnitude', 'Threshold');
            end
            
            hold(ax, 'off');
            
            xlabel(ax, 'Sample');
            ylabel(ax, 'Acceleration Magnitude (m/s^2)');
            title(ax, sprintf('Step Detection (Count: %d)', obj.results.stepCount));
            grid(ax, 'on');
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            fprintf('\n=== %s ===\n', obj.Name);
            fprintf('Analysis timestamp: %s\n', obj.results.timestamp);
            fprintf('Estimated step count: %d\n', obj.results.stepCount);
            fprintf('Detection threshold: %.2f\n', obj.results.threshold);
            fprintf('Min peak distance: %.2f\n', obj.results.minPeakDistance);
        end
        
        function plotImpl(obj, target)
            obj.plotSteps(target);
        end
    end
end
