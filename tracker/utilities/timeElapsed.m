function newArray = timeElapsed(datetime_array)
    % This function converts an array of elements in datetime format
    % into the total elapsed time in seconds since the first data point was
    % acquired
    %
    % To find out more about datetime formats and arrays try the command:
    %
    %   >> doc datetime
    %
    % Copyright 2018 The MathWorks, Inc
    
    newArray = second(datetime_array);
    arraySize = numel(newArray);
    first = newArray(1);
    
    % Handle minute rollovers by detecting decreases and adding 60 seconds
    % to all subsequent values
    for i = 2:arraySize
        if newArray(i) < newArray(i-1)
            newArray(i:end) = newArray(i:end) + 60;
        end
    end
    
    % Subtract the first value to start the array at 0
    newArray = newArray - first;  
end
