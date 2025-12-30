classdef (Abstract) AnalysisFunction < handle
    
    properties (Abstract, Constant)
        Name
        Description
    end
    
    properties (Access = protected)
        results
    end
    
    methods (Abstract)
        results = analyze(obj, fitnessData)
    end
    
    methods
        function displayResults(obj)
            if isempty(obj.results)
                warning('analysis:AnalysisFunction:NoResults', ...
                    'No results available. Run analyze() first.');
                return;
            end
            obj.displayResultsImpl();
        end
        
        function r = getResults(obj)
            r = obj.results;
        end
        
        function plot(obj, target)
            arguments
                obj
                target = []
            end
            
            if isempty(obj.results)
                error('analysis:AnalysisFunction:NoResults', ...
                    'No results available. Run analyze() first.');
            end
            
            obj.plotImpl(target);
        end
    end
    
    methods (Access = protected)
        function displayResultsImpl(obj)
            disp(obj.results);
        end
        
        function plotImpl(obj, target)
            warning('analysis:AnalysisFunction:NoPlot', ...
                'No default plot implementation for %s', obj.Name);
        end
    end
end
