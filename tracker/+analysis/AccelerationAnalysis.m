classdef AccelerationAnalysis < analysis.AnalysisFunction
    
    properties (Constant)
        Name = "Acceleration Analysis"
        Description = "Analyzes acceleration data to compute magnitude and statistics"
    end
    
    methods
        function results = analyze(obj, fitnessData)
            if ~fitnessData.hasAcceleration
                error('analysis:AccelerationAnalysis:NoData', ...
                    'Fitness data does not contain acceleration information');
            end
            
            accel = fitnessData.Acceleration;
            
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            
            if istimetable(accel)
                results.X = accel.X;
                results.Y = accel.Y;
                results.Z = accel.Z;
                results.magnitude = sqrt(accel.X.^2 + accel.Y.^2 + accel.Z.^2);
                results.timeData = accel.Properties.RowTimes;
            elseif isstruct(accel)
                results.X = accel.X;
                results.Y = accel.Y;
                results.Z = accel.Z;
                results.magnitude = sqrt(accel.X.^2 + accel.Y.^2 + accel.Z.^2);
                if isfield(accel, 'Timestamp')
                    results.timeData = accel.Timestamp;
                end
            else
                error('analysis:AccelerationAnalysis:InvalidFormat', ...
                    'Unexpected acceleration data format');
            end
            
            results.stats.mean = mean(results.magnitude);
            results.stats.std = std(results.magnitude);
            results.stats.max = max(results.magnitude);
            results.stats.min = min(results.magnitude);
            results.stats.median = median(results.magnitude);
            
            obj.results = results;
        end
        
        function plotMagnitude(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:AccelerationAnalysis:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Acceleration Magnitude');
                ax = axes(f);
            else
                ax = target;
            end
            
            plot(ax, obj.results.magnitude);
            xlabel(ax, 'Sample');
            ylabel(ax, 'Acceleration Magnitude (m/s^2)');
            title(ax, 'Acceleration Magnitude Over Time');
            grid(ax, 'on');
        end
        
        function plotComponents(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:AccelerationAnalysis:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Acceleration Components');
                ax = axes(f);
            else
                ax = target;
            end
            
            hold(ax, 'on');
            plot(ax, obj.results.X);
            plot(ax, obj.results.Y);
            plot(ax, obj.results.Z);
            hold(ax, 'off');
            
            legend(ax, 'X Acceleration', 'Y Acceleration', 'Z Acceleration');
            xlabel(ax, 'Sample');
            ylabel(ax, 'Acceleration (m/s^2)');
            title(ax, 'Acceleration Components Over Time');
            grid(ax, 'on');
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            fprintf('\n=== %s ===\n', obj.Name);
            fprintf('Analysis timestamp: %s\n', obj.results.timestamp);
            fprintf('Data points: %d\n', length(obj.results.magnitude));
            
            fprintf('\nStatistics:\n');
            fprintf('  Mean magnitude: %.4f\n', obj.results.stats.mean);
            fprintf('  Std deviation: %.4f\n', obj.results.stats.std);
            fprintf('  Max magnitude: %.4f\n', obj.results.stats.max);
            fprintf('  Min magnitude: %.4f\n', obj.results.stats.min);
            fprintf('  Median: %.4f\n', obj.results.stats.median);
        end
        
        function plotImpl(obj, target)
            obj.plotMagnitude(target);
        end
    end
end
