function jbm_synapseAnalysisEngine(handles)
global jbm;
global h_img3;

PRESENT = 1;
NOT_PRESENT = 0;
SPINE_PRESENT = 2;
LOW_CONFIDENCE = 3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
selectedInstance = currentInd;
instances = fieldnames(h_img3);

iscommon = find(strcmp(instances,'common'));
if exist(iscommon)
    instances(iscommon) = [];
else
end

if ~isfield(jbm,'synapseAnalysis')
    jbm.synapseAnalysis = [];
end

if ~isfield(jbm.synapseAnalysis,'visNumber')
    jbm.synapseAnalysis.visNumber = 1;
end


synapse_data = [];
synapse_data.data = zeros(1,length(instances));
synapse_data.xcoordinates = zeros(1,length(instances));
synapse_data.ycoordinates = zeros(1,length(instances));
synapse_data.vis_handles = zeros(1,length(instances));
synapse_data.text = zeros(1,length(instances));

synapse_coordinates = zeros(length(instances),2);


for i = selectedInstance:length(instances)

    currentInstance = instances{i};
    caxes = h_img3.(currentInstance).gh.currentHandles.imageAxes;
    cfigure = h_img3.(currentInstance).gh.currentHandles.h_imstack3;
    figure(cfigure);
    h_updateInfo3(handles);
    set(cfigure,'CurrentCharacter','0');
    set(cfigure,'Color','b');
    waitfor_nohotkeys(cfigure);   
    pressed = get(cfigure,'CurrentCharacter');
    if strcmp(pressed,'4')
        
        synapse_data.data(i) = NOT_PRESENT;
        
    elseif strcmp(pressed,'1')
        
        
        synapse_coordinates(i,:) = ginput_ax(caxes);
        
        synapse_data.vis_handles(i) = viscircles(caxes,synapse_coordinates(i,:),2,'EdgeColor','b');        
        synapse_data.xcoordinates(i) = synapse_coordinates(i,1);
        synapse_data.ycoordinates(i) = synapse_coordinates(i,2);
        synapse_data.text(i) = text(synapse_data.xcoordinates(i),synapse_data.ycoordinates(i),['\leftarrow ' num2str(jbm.synapseAnalysis.visNumber)],'Color','c','Fontsize',15,...
            'FontWeight','Bold','Parent',caxes);
        synapse_data.data(i) = PRESENT;
      
    elseif strcmp(pressed,'2')
        
        synapse_coordinates(i,:) = ginput_ax(caxes);
        
        synapse_data.vis_handles(i) = viscircles(caxes,synapse_coordinates(i,:),2,'EdgeColor','c');
        synapse_data.xcoordinates(i) = synapse_coordinates(i,1);
        synapse_data.ycoordinates(i) = synapse_coordinates(i,2);
        synapse_data.text(i) = text(synapse_data.xcoordinates(i),synapse_data.ycoordinates(i),['\leftarrow ' num2str(jbm.synapseAnalysis.visNumber)],'Color','c','Fontsize',15,...
            'FontWeight','Bold','Parent',caxes);
        synapse_data.data(i) = SPINE_PRESENT;
    elseif strcmp(pressed,'3')
        synapse_coordinates(i,:) = ginput_ax(caxes);
        
        synapse_data.vis_handles(i) = viscircles(caxes,synapse_coordinates(i,:),2,'EdgeColor','r');
        synapse_data.xcoordinates(i) = synapse_coordinates(i,1);
        synapse_data.ycoordinates(i) = synapse_coordinates(i,2);
        synapse_data.text(i) = text(synapse_data.xcoordinates(i),synapse_data.ycoordinates(i),['\leftarrow ' num2str(jbm.synapseAnalysis.visNumber)],'Color','c','Fontsize',15,...
            'FontWeight','Bold','Parent',caxes);
        synapse_data.data(i) = LOW_CONFIDENCE;
        
end

    set(cfigure,'Color',[.941 .941 .941]);

end

synapseAnalysisDataCleanup(synapse_data);
jbm.synapseAnalysis.visNumber = jbm.synapseAnalysis.visNumber + 1;

end

function waitfor_nohotkeys(cfigure)
waitfor(cfigure,'CurrentCharacter');
pressed = double(get(cfigure,'CurrentCharacter'));
acceptable_keypresses = [52 49 50 51];
if ~isempty(find(acceptable_keypresses == pressed))
else  
    waitfor_nohotkeys(cfigure);
end
end

function synapseAnalysisDataCleanup(synapse_data)
global jbm
if ~isfield(jbm.synapseAnalysis,'synapseAnalysisData')
    jbm.synapseAnalysis.synapseAnalysisData.dataMatrix(1,:) = synapse_data.data;
else
    size_data = size(jbm.synapseAnalysis.synapseAnalysisData.dataMatrix);
    length_data = size_data(1);
    jbm.synapseAnalysis.synapseAnalysisData.dataMatrix(length_data+1,:) = synapse_data.data;
    jbm.synapseAnalysis.synapseAnalysisData.xCoordinates(length_data+1,:) = synapse_data.xcoordinates;
    jbm.synapseAnalysis.synapseAnalysisData.yCoordinates(length_data+1,:) = synapse_data.ycoordinates;
    jbm.synapseAnalysis.synapseAnalysisData.roiHandles(length_data+1,:) = synapse_data.vis_handles;
    jbm.synapseAnalysis.synapseAnalysisData.text(length_data+1,:) = synapse_data.text;
end
  disp(jbm.synapseAnalysis.synapseAnalysisData.dataMatrix);
end




        