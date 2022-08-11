function syndex(synapseIDNumber)
global jbm;
synapseIDNumber = num2str(synapseIDNumber);
[syndex] = find(strcmp([jbm.scoringData.synapseID],synapseIDNumber));


end

