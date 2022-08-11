function [Aout] = jbm_processdatamatrix(rawDataMatrix)
Aout.rawData = rawDataMatrix;

identifiedCorrectionsDataMatrix = jbm_datafilter(rawDataMatrix,'Identify Corrections');
Aout.identifiedCorrectionsData = identifiedCorrectionsDataMatrix;

correctedDataMatrix = jbm_datafilter(identifiedCorrectionsDataMatrix,'Execute Corrections');
Aout.correctedData = correctedDataMatrix;

numCorrections = find((identifiedCorrectionsDataMatrix == 4) | (identifiedCorrectionsDataMatrix == 5));
Aout.numCorrections = numCorrections;

Aout.rawDynamics.survivalFraction = calcSF(rawDataMatrix,1);
Aout.rawDynamics.numAdditions = calcAdditions(rawDataMatrix);
Aout.rawDynamics.numEliminations = calcEliminations(rawDataMatrix);
Aout.rawDynamics.numDynamics = calcDynamics(rawDataMatrix);

Aout.correctedDynamics.survivalFraction = calcSF(correctedDataMatrix,1);
Aout.correctedDynamics.numAdditions = calcAdditions(correctedDataMatrix);
Aout.correctedDynamics.numEliminations = calcEliminations(correctedDataMatrix);
Aout.correctedDynamics.numDynamics = calcDynamics(correctedDataMatrix);
Aout.correctedDynamics.numSynapses = sum(logical(Aout.correctedData));
Aout.correctedDynamics.normAdditions = Aout.correctedDynamics.numAdditions ./ Aout.correctedDynamics.numSynapses(2:end);
Aout.correctedDynamics.normEliminations = Aout.correctedDynamics.numEliminations ./ Aout.correctedDynamics.numSynapses(1:end-1);
[Aout.correctedDynamics.rawDensity Aout.correctedDynamics.normDensity] = calcDensity(Aout.correctedData);

[spines shafts] = createSpineMatrix(Aout.correctedData);
Aout.correctedSpineData = spines;
Aout.correctedShaftData = shafts;

Aout.correctedDynamics.spineSurvivalFraction = calcSF(spines,1)
Aout.correctedDynamics.numSpineAdditions = calcAdditions(spines)
Aout.correctedDynamics.numSpineEliminations = calcEliminations(spines)
Aout.correctedDynamics.numSpineDynamics = calcDynamics(spines)
Aout.correctedDynamics.numSpines = sum(spines)
Aout.correctedDynamics.normSpineAdditions = Aout.correctedDynamics.numSpineAdditions ./ Aout.correctedDynamics.numSpines(2:end);
Aout.correctedDynamics.normSpineEliminations = Aout.correctedDynamics.numSpineEliminations ./ Aout.correctedDynamics.numSpines(1:end-1);
[Aout.correctedDynamics.rawSpineDensity Aout.correctedDynamics.normSpineDensity] = calcDensity(spines);

Aout.correctedDynamics.shaftSurvivalFraction = calcSF(shafts,1);
Aout.correctedDynamics.numShaftAdditions = calcAdditions(shafts);
Aout.correctedDynamics.numShaftEliminations = calcEliminations(shafts);
Aout.correctedDynamics.numShaftDynamics = calcDynamics(shafts);
Aout.correctedDynamics.numShafts = sum(shafts);
Aout.correctedDynamics.normShaftAdditions = Aout.correctedDynamics.numShaftAdditions ./ Aout.correctedDynamics.numShafts(2:end);
Aout.correctedDynamics.normShaftEliminations = Aout.correctedDynamics.numShaftEliminations ./ Aout.correctedDynamics.numShafts(1:end-1);
[Aout.correctedDynamics.rawShaftDensity Aout.correctedDynamics.normShaftDensity] = calcDensity(shafts);

end


function [spineDataMatrix shaftDataMatrix] = createSpineMatrix(dataMatrix)
dataDim = size(dataMatrix);
[syn,day] = find(dataMatrix == 2);
syn = unique(syn);
spineDataMatrix = dataMatrix(syn,:);
dataMatrix(syn,:) = [];
shaftDataMatrix = dataMatrix;


end

function [numAdditions] = calcAdditions(dataMatrix)
dataMatrix = logical(dataMatrix);
differences = diff(dataMatrix,1,2);
differences(differences == -1) = 0;
numAdditions = sum(differences);
end

function [numEliminations] = calcEliminations(dataMatrix)
dataMatrix = logical(dataMatrix);
differences = diff(dataMatrix,1,2);
differences(differences == 1) = 0;
numEliminations = sum(logical(differences));
end

function [numDynamics] = calcDynamics(dataMatrix);
dataMatrix = logical(dataMatrix);
differences = diff(dataMatrix,1,2);
numDynamics = sum(logical(differences));
end



function [rawDensity normalizedDensity] = calcDensity(dataMatrix)
dataMatrix = logical(dataMatrix);
rawDensity = sum(dataMatrix);
normalizedDensity = rawDensity / rawDensity(1);
end

function survivalFraction = calcSF(dataMatrix,startImagingDay)
dataMatrix = logical(dataMatrix);
numSynapses = size(dataMatrix,1);
numImagingDays = size(dataMatrix,2);

if startImagingDay > numImagingDays
    disp('starting timepoint exceeds number of timepoints');
    return
end

absent = find(dataMatrix(:,startImagingDay) == 0);
dataMatrix(absent,:) = [];

for i = 1:(numImagingDays - startImagingDay + 1)
    sf(i) = sum(dataMatrix(:,(startImagingDay-1+i)));
end

sf = sf / sf(1);

survivalFraction = sf;
end
