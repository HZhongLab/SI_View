function synDex(synapseIDNumber)
global jbm;
synapseIDNumber = num2str(synapseIDNumber);
[synapseIndex] = find(strcmp([jbm.scoringData.synapseID],synapseIDNumber));

singleSynapseMatrix = jbm.scoringData.synapseMatrix(synapseIndex,:);
disp(['Synapse Matrix for Synapse Number ' synapseIDNumber]);
disp(singleSynapseMatrix);

end

