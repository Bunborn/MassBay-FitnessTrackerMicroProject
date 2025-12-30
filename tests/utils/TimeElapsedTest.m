classdef TimeElapsedTest < matlab.unittest.TestCase
    
    properties
        projectRoot
    end
    
    methods (TestClassSetup)
        function setupPath(testCase)
            thisFile = mfilename('fullpath');
            testsFolder = fileparts(fileparts(thisFile));
            testCase.projectRoot = fileparts(testsFolder);
            addpath(fullfile(testCase.projectRoot, 'tracker'));
        end
    end
    
    methods (Test)
        function testUtilsTimeElapsed(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, [0 5 10 15 20]);
            
            elapsed = utils.timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed(1), 0);
            testCase.verifyEqual(elapsed(2), 5);
            testCase.verifyEqual(elapsed(end), 20);
        end
        
        function testTimeElapsedWithMinuteRollover(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, [55 56 57 58 59 0 1]);
            
            elapsed = utils.timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed(1), 0);
            testCase.verifyGreaterThan(elapsed(end), elapsed(1));
        end
        
        function testTimeElapsedSingleValue(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, 30);
            
            elapsed = utils.timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed, 0);
        end
    end
end
