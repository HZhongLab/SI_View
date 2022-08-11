function [filteredSynapseAnalysisData] = esoin_dataFilter(varargin)
% filtered = esoin_dataFilter(synapseAnalysisData,x,y)
% x = 1: Melander Filter,2: Remove Quesitons, 3: only look at persistents,
% 4: trim, 5: remove 'rv's



synapseAnalysisData = varargin{1};
filter = varargin{2};




%Test SAD
switch filter
    case 1 %Melander Filter
        [synapse, imging_day] = find(synapseAnalysisData.lowSynapseConfidence == 1);
        num_days = size(synapseAnalysisData.presenceMatrix,2);
        
        for i = 1:length(synapse)
            if (imging_day(i) ~= 1) && (imging_day(i) ~= num_days)
                if synapseAnalysisData.presenceMatrix(synapse(i),[imging_day(i)-1 imging_day(i)+1]) == [0 0];
                    synapseAnalysisData.presenceMatrix(synapse(i),imging_day(i)) = 0;
                    synapseAnalysisData.isSpineMatrix(synapse(i),imging_day(i)) = 0;
                    
                end
                
            elseif (imging_day(i) == 1)
                if synapseAnalysisData.presenceMatrix(synapse(i),[1 2]) == [1 0]
                    synapseAnalysisData.presenceMatrix(synapse(i),imging_day(i)) = 0;
                    synapseeAnalysisData.isSpineMatrix(synapse(i),imging_day(i)) = 0;
                end
                
            elseif (imging_day(i) == num_days)
                if synapseAnalysisData.presenceMatrix(synapse(i),[num_days-1 num_days]) == [0 1]
                    synapseAnalysisData.presenceMatrix(synapse(i),imging_day(i)) = 0;
                    synapseAnalysisData.isSpineMatrix(synapse(i),imging_day(i)) = 0;
                end
                
            end
        end
        
        numQuestions = sum(synapseAnalysisData.lowSynapseConfidence,2);
        [synapsesToRemove,y] = find(numQuestions>1);
        
        
        
        synapseAnalysisData.presenceMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.isSpineMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.synapseNumber(synapsesToRemove) = [];
        synapseAnalysisData.synapseNotes(synapsesToRemove,:) = [];
        
       
    case 2 %Remove all questions
        [synapses,imging_day] = find(synapseAnalysisData.lowSynapseConfidence == 1);
        synapsesToRemove = unique(synapses);
        synapseAnalysisData.presenceMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.isSpineMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.synapseNumber(synapsesToRemove) = [];
        synapseAnalysisData.synapseNotes(synapsesToRemove,:) = [];
    case 3 %Only look at persistents 
        [synapses] = find(sum(synapseAnalysisData.presenceMatrix,2) < 2);
        synapsesToRemove = unique(synapses);
         synapseAnalysisData.presenceMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.isSpineMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.synapseNumber(synapsesToRemove) = [];
        synapseAnalysisData.synapseNotes(synapsesToRemove,:) = [];
    case 4 %Trim Data -> Different Number of Days PROBLEMATIC NEEDS TO GET RID OF SYNAPSE NUMBERS AND ROWS THAT WERE NOT PRESENT ON DAY ONE
        new_num_days = varargin{3};
        synapseAnalysisData.presenceMatrix = synapseAnalysisData.presenceMatrix(:,1:new_num_days);
        synapseAnalysisData.isSpineMatrix = synapseAnalysisData.isSpineMatrix(:,1:new_num_days);
        synapseAnalysisData.synapseNotes = synapseAnalysisData.synapseNotes(:,1:new_num_days);
        synapseAnalysisData.lowSynapseConfidence = synapseAnalysisData.lowSynapseConfidence(:,1:new_num_days);
        synapseAnalysisData.analysisFileName = synapseAnalysisData.analysisFileName(1:3);
        synapseAnalysisData.synapseMovedMatrix = synapseAnalysisData.synapseMovedMatrix(:,1:new_num_days);
        synapseAnalysisData.isNewMatrix = synapseAnalysisData.isNewMatrix(:,1:new_num_days);
        synapseAnalysisData.isLastMatrix = synapseAnalysisData.isLastMatrix(:,1:new_num_days);
        
    case 5 % Remove rv synapses
        [synapses,imging_day] = find(strcmp(synapseAnalysisData.synapseNotes,'rv'));
        synapsesToRemove = unique(synapses);
         synapseAnalysisData.presenceMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.isSpineMatrix(synapsesToRemove,:) = [];
        synapseAnalysisData.synapseNumber(synapsesToRemove) = [];
        synapseAnalysisData.synapseNotes(synapsesToRemove,:) = [];
        
        
      
  
end

filteredSynapseAnalysisData = synapseAnalysisData;