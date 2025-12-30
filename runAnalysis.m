function results = runAnalysis(dataPath, analysisFunction)
    arguments
        dataPath (1,1) string
        analysisFunction analysis.AnalysisFunction
    end
    
    fitnessData = data.loadFitnessData(dataPath);
    results = analysisFunction.analyze(fitnessData);
end
