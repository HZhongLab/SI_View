dataMatrix = synapseAnalysisData.dataMatrix;
xCoordinates = synapseAnalysisData.xCoordinates;
yCoordinates = synapseAnalysisData.yCoordinates;
dataDim = size(dataMatrix);
numSynapses = dataDim(1);
numImagingDays = dataDim(2);

global h_img3

for i = 1:numImagingDays
    
    iterInstance = ['I' num2str(i)];
    caxes = h_img3.(iterInstance).gh.currentHandles.imageAxes
    
    for j = 1:numSynapses
        synCo = [xCoordinates(j,i) yCoordinates(j,i)];
        viscircles(caxes,synCo,2,'EdgeColor','b');
        text(synCo(1),synCo(2),['\leftarrow ' num2str(j)],'Color','c','Fontsize',15,...
            'FontWeight','Bold','Parent',caxes)
    end
end
        
    
    

    