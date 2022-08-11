function [Aout] = esoin_processSAD(synapseAnalysisData,filter)

sad = synapseAnalysisData;
presence = sad.presenceMatrix;
questionable_incidents = sad.lowSynapseConfidence;
spine_presence = sad.isSpineMatrix;
synapseIDs = sad.synapseNumber;
fns = sad.analysisFileName;
notes = sad.synapseNotes;

%~~~ Shitty Code Below, but It Works ~~~
dynamics = diff(presence,1,2);
temp = dynamics; 
temp2 = dynamics;
dynamics(dynamics == -1) = 0;
additions = dynamics;
temp2(temp2 == 1) = 0;
eliminations = temp2;
eliminations = double(logical(eliminations));
eliminations = sum(eliminations);
additions = sum(additions);
dynamics = temp;
dynamics = double(logical(dynamics));
dynamics = sum(dynamics);
numsyn = sum(presence);
%~~~ Shitty Code Ends, and It Works ~~~~~

for i = 1:length(dynamics)
    TOR(i) = (dynamics(i))/(2*(numsyn(i)+ additions(i)));
end


normelim = eliminations ./ numsyn(1:length(eliminations));
normadd = additions ./ numsyn(2:(1 + length(additions)));


Aout.total_number_synapses = length(synapseIDs);
Aout.total_density = sum(presence);
Aout.total_normalized_density = Aout.total_density/Aout.total_density(1);
Aout.total_presence = presence;
Aout.total_d0sf = esoin_calcSurvivalFraction(presence,1);
Aout.total_eliminations = eliminations;
Aout.total_additions = additions;
Aout.total_dynamics = dynamics;
Aout.total_TOR = TOR;
Aout.total_normalized_eliminations = normelim;
Aout.total_normalized_additions = normadd;













