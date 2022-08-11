function sf = esoin_calculateSurvivalFraction(presence,starting_timepoint)

num_synapses = size(presence,1);
num_timepoints = size(presence,2);
if starting_timepoint > num_timepoints
    disp('starting timepoint exceeds number of timepoints');
    return
end

not_present = find(presence(:,starting_timepoint) == 0);
presence(not_present,:) = 0;

for i = 1:(num_timepoints - starting_timepoint + 1)
    sf(i) = sum(presence(:,(starting_timepoint-1+i)));
end

sf = sf / sf(1);