function fitnessData = loadFitnessData(dataPath, options)
    arguments
        dataPath (1,1) string
        options.ValidateData (1,1) logical = true
    end
    
    if ~isfile(dataPath)
        error('data:loadFitnessData:FileNotFound', ...
            'Data file not found: %s', dataPath);
    end
    
    [~, ~, ext] = fileparts(dataPath);
    if ~strcmp(ext, '.mat')
        error('data:loadFitnessData:InvalidFileType', ...
            'Expected .mat file, got: %s', ext);
    end
    
    loadedData = load(dataPath);
    
    if options.ValidateData
        fitnessData = validateAndStructure(loadedData);
    else
        fitnessData = loadedData;
    end
end

function structuredData = validateAndStructure(rawData)
    structuredData = struct();
    
    fieldNames = fieldnames(rawData);
    
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        structuredData.(fieldName) = rawData.(fieldName);
    end
    
    % Check for Acceleration or unknownAcceleration (used by ActivityClassifier)
    if isfield(structuredData, 'Acceleration')
        structuredData.hasAcceleration = true;
    elseif isfield(structuredData, 'unknownAcceleration')
        % Map unknownAcceleration to Acceleration for consistent interface
        structuredData.Acceleration = structuredData.unknownAcceleration;
        structuredData.hasAcceleration = true;
    else
        structuredData.hasAcceleration = false;
    end
    
    if isfield(structuredData, 'Position')
        structuredData.hasPosition = true;
    else
        structuredData.hasPosition = false;
    end
    
    if isfield(structuredData, 'Orientation')
        structuredData.hasOrientation = true;
    else
        structuredData.hasOrientation = false;
    end
end
