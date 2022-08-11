function [filteredData] = jbm_datafilter(varargin)
% jbm_dataFilter(dataMatrix,filterType)
% filterTypes: 
%'Identify Corrections' will correct and corrected absences
% will become a 5 and corrected presences will become a 4. 
%
% 'Execute Correction' will replace all 5s with 0s and replace all 4s with 1s,
% returning a corrected dataMatrix. 
%
% To generate the corrected dataMatrix, % run the following code:
% correctedMatrix = jbm_datafilter(jbm_datafilter(dataMatrix,'Identify Corrections'),'Execute Corrections')
% which will identify the corrections then pass that data to
% the filter that will execute correction.


ABSENT = 0;
PRESENT = 1;
SPINE_PRESENT = 2;
UNSURE = 3;
CORRECTED_PRESENT = 4;
CORRECTED_ABSENT = 5;

dataMatrix = varargin{1};
filterType = varargin{2};
dataDimensions = size(dataMatrix);
numSynapses = dataDimensions(1);
numImagingDays = dataDimensions(2);

switch filterType
    case 'Identify Corrections'
        
        for iSynapse = 1:numSynapses
            num3s(iSynapse) = sum(dataMatrix(iSynapse,:) == 3);
        end
        
        toRemove = find(num3s > 1);
        dataMatrix(toRemove,:) = [];
        
        
        
        
        [absent.synapses absent.imagingDays] = find((dataMatrix == ABSENT));
        [unsure.synapses unsure.imagingDays] = find((dataMatrix == UNSURE));
        for i = 1:length(absent.synapses)
            cSyn = absent.synapses(i);
            cDay = absent.imagingDays(i);

            if cDay == 1
                ;
            elseif cDay == numImagingDays
                ;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [1 1]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [1 2]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [2 1]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [2 2]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            end

        end

        for i = 1:length(unsure.synapses)
            cSyn = unsure.synapses(i);
            cDay = unsure.imagingDays(i);

            if cDay == 1 & dataMatrix(cSyn,cDay+1) == 0
                dataMatrix(cSyn,cDay) = CORRECTED_ABSENT;
            elseif cDay == 1 & ((dataMatrix(cSyn,cDay+1) == 1) || (dataMatrix(cSyn,cDay+1) == 2))
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif cDay == numImagingDays & dataMatrix(cSyn,cDay-1) == 0
                dataMatrix(cSyn,cDay) = CORRECTED_ABSENT;
            elseif cDay == numImagingDays & ((dataMatrix(cSyn,cDay-1) == 1) || (dataMatrix(cSyn,cDay-1) == 2))
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [1 1]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [1 2]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [2 1]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [2 2]
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif dataMatrix(cSyn,[cDay-1 cDay+1]) == [0 0]
                dataMatrix(cSyn,cDay) = CORRECTED_ABSENT;
            elseif (dataMatrix(cSyn, [cDay-1 cDay+1]) == [0 1])
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif (dataMatrix(cSyn, [cDay-1 cDay+1]) == [0 2])
                dataMatrix(cSyn,cDay) = CORRECTED_PRESENT;
            elseif (dataMatrix(cSyn, [cDay-1 cDay+1]) == [1 0])
                dataMatrix(cSyn,cDay) = CORRECTED_ABSENT;
            elseif (dataMatrix(cSyn, [cDay-1 cDay+1]) == [2 0])
                 dataMatrix(cSyn,cDay) = CORRECTED_ABSENT;
            end
        end
    case 'Execute Corrections'
        dataMatrix(dataMatrix == 4) = 1;
        dataMatrix(dataMatrix == 5) = 0;
        
end

filteredData = dataMatrix;
end




