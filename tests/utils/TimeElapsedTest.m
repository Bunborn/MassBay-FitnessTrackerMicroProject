classdef TimeElapsedTest < AbstractFitnessTrackerTest
    
    methods (Test)
        function testUtilsTimeElapsed(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, [0 5 10 15 20]);
            
            elapsed = timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed(1), 0);
            testCase.verifyEqual(elapsed(2), 5);
            testCase.verifyEqual(elapsed(end), 20);
        end
        
        function testTimeElapsedWithMinuteRollover(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, [55 56 57 58 59 0 1]);
            
            elapsed = timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed(1), 0);
            testCase.verifyGreaterThan(elapsed(end), elapsed(1));
        end
        
        function testTimeElapsedSingleValue(testCase)
            testTimes = datetime(2024, 1, 1, 12, 0, 30);
            
            elapsed = timeElapsed(testTimes);
            
            testCase.verifyEqual(elapsed, 0);
        end
    end
end
