function summary_data = esoin_processDir()
matfiles = dir('*.mat');
matfiles = {matfiles.name};
for i = 1:length(matfiles)
    temp = load(matfiles{i});
    SAD_struct(i) = esoin_processSAD(temp.synapseAnalysisData);
end

summary_data.TOR = vertcat(SAD_struct.total_TOR)


end

