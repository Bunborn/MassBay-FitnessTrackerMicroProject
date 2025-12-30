classdef GPSDistanceCalculator < analysis.AnalysisFunction
    
    properties (Constant)
        Name = "GPS Distance Calculator"
        Description = "Calculates distance traveled and estimates steps from GPS position data"
    end
    
    properties
        StrideLength = 2.5  % Average stride length in feet
        EarthCircumference = 24901  % Earth's circumference in miles
    end
    
    methods
        function results = analyze(obj, fitnessData)
            if ~fitnessData.hasPosition
                error('analysis:GPSDistanceCalculator:NoData', ...
                    'Fitness data does not contain position information');
            end
            
            position = fitnessData.Position;
            
            % Extract latitude and longitude
            if istimetable(position)
                lat = position.latitude;
                lon = position.longitude;
                timeData = position.Properties.RowTimes;
            elseif isstruct(position)
                lat = position.latitude;
                lon = position.longitude;
                if isfield(position, 'Timestamp')
                    timeData = position.Timestamp;
                else
                    timeData = [];
                end
            else
                error('analysis:GPSDistanceCalculator:InvalidFormat', ...
                    'Unexpected position data format');
            end
            
            % Calculate distance between consecutive GPS points
            totalDistance = 0;  % in miles
            distances = zeros(length(lat)-1, 1);
            
            for i = 1:(length(lat)-1)
                lat1 = lat(i);
                lat2 = lat(i+1);
                lon1 = lon(i);
                lon2 = lon(i+1);
                
                % Calculate angular distance in degrees
                degDistance = distance(lat1, lon1, lat2, lon2);
                
                % Convert to linear distance in miles
                segmentDistance = (degDistance / 360) * obj.EarthCircumference;
                distances(i) = segmentDistance;
                totalDistance = totalDistance + segmentDistance;
            end
            
            % Convert to feet and calculate steps
            totalDistanceFeet = totalDistance * 5280;
            estimatedSteps = totalDistanceFeet / obj.StrideLength;
            
            % Store results
            results = struct();
            results.timestamp = datetime('now');
            results.analysisType = obj.Name;
            results.totalDistanceMiles = totalDistance;
            results.totalDistanceFeet = totalDistanceFeet;
            results.estimatedSteps = round(estimatedSteps);
            results.strideLength = obj.StrideLength;
            results.segmentDistances = distances;
            results.latitude = lat;
            results.longitude = lon;
            results.timeData = timeData;
            results.numSegments = length(distances);
            
            obj.results = results;
        end
        
        function plotRoute(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:GPSDistanceCalculator:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'GPS Route');
                ax = axes(f);
            else
                ax = target;
            end
            
            plot(ax, obj.results.longitude, obj.results.latitude, 'b-o', 'LineWidth', 2);
            xlabel(ax, 'Longitude');
            ylabel(ax, 'Latitude');
            title(ax, sprintf('GPS Route (%.2f miles)', obj.results.totalDistanceMiles));
            grid(ax, 'on');
            
            % Mark start and end points
            hold(ax, 'on');
            plot(ax, obj.results.longitude(1), obj.results.latitude(1), ...
                'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
            plot(ax, obj.results.longitude(end), obj.results.latitude(end), ...
                'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            legend(ax, 'Route', 'Start', 'End');
            hold(ax, 'off');
        end
        
        function plotSegmentDistances(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:GPSDistanceCalculator:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            if isempty(target)
                f = figure('Name', 'Segment Distances');
                ax = axes(f);
            else
                ax = target;
            end
            
            % Convert to feet for better readability
            segmentDistancesFeet = obj.results.segmentDistances * 5280;
            
            bar(ax, segmentDistancesFeet);
            xlabel(ax, 'Segment');
            ylabel(ax, 'Distance (feet)');
            title(ax, 'Distance Between GPS Points');
            grid(ax, 'on');
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            fprintf('\n=== %s ===\n', obj.Name);
            fprintf('Analysis timestamp: %s\n', obj.results.timestamp);
            fprintf('GPS segments analyzed: %d\n', obj.results.numSegments);
            fprintf('\nDistance Traveled:\n');
            fprintf('  %.4f miles\n', obj.results.totalDistanceMiles);
            fprintf('  %.2f feet\n', obj.results.totalDistanceFeet);
            fprintf('\nStep Estimation:\n');
            fprintf('  Stride length: %.2f feet\n', obj.results.strideLength);
            fprintf('  Estimated steps: %d\n', obj.results.estimatedSteps);
        end
        
        function plotImpl(obj, target)
            obj.plotRoute(target);
        end
    end
end
