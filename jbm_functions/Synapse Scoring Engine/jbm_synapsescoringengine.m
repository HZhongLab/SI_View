
% TO-DO List As of 11/13/15
% 1. Save final positions, not initialized positions!
% 2. Save .tif filenames in order of instance and group name in Scoring
% Data
% 3. Transients Color Scheme
% 4. Readable ROI Color + Appearance (Dots, Larger Font, Clear Colors)
% 5. Improved note functionality
% 6. Retreive synapse matrix function

function jbm_synapsescoringengine(tag,handles)
    global jbm;
    global h_img3;
    
    

    [selectedInstance,handles,currentStruct,currentStructName] = h_getCurrendInd3(handles);
    allInstances = fieldnames(h_img3);
    
    isCommonField = find(strcmp(allInstances,'common'));
    if exist(isCommonField)
        allInstances(isCommonField) = [];
    else
    end
    
    jbm.instancesOpen = allInstances;
    
    switch tag
        case 'create new dataset'
            createnewdataset(handles);
        case 'group load'
            batchgroupload();
        case 'close all instances'
            closeallinstances();
        case 'group zoom alignment'
            groupzoomalignment(GROUP_ZOOM_FACTOR);
        case 'new synapse'
            newsynapse(handles);
        case 'update info'
            updateinfo(handles);
        case 'print notes'
            printnotes();
        case 'update verification'
            updateverification(handles);
        case 'save'
            saveScoringData(handles);
        case 'load'
            loadScoringData(handles)
        
    end
    
end

function saveScoringData(handles)
global jbm;
scoringData = jbm.scoringData;
uisave('scoringData',char(jbm.scoringData.datasetName));


end

function loadScoringData(handles)

global jbm;
global h_img3;
[fn pn] = uigetfile();
filePath = [pn fn];
temp = load(filePath);

if isfield(jbm,'scoringData')
    choice = questdlg('Loading a dataset will delete any unsaved data. Are you sure you wish to proceed?',...
        'Load','Load','Go back','Go back');
    switch choice
        case 'Load'
            knobs = jbm.knobs;
            textKnobs = jbm.textKnobs;
            knobs = knobs(knobs~=0);
            textKnobs = textKnobs(textKnobs~=0);
            for ii = 1:numel(knobs) %Haining: do it one by one to prevent an error preventing deletion of others.
                try delete(knobs(ii));catch,end%sometimes the ROI has been deleted by other methods,and this cause errors.
            end
            for ii = 1:numel(knobs) %Haining: do it one by one to prevent an error preventing deletion of others.
                try delete(textKnobs(ii));catch,end
            end
            
            
            
            jbm.knobs = [];
            jbm.textKnobs = [];
            jbm.scoringData = temp.scoringData;
            
            
        case 'Go back'
            return
    end
else %add by HN so that one don't need to initialize jbm global variable to load.
    jbm.knobs = [];
    jbm.textKnobs = [];
    jbm.scoringData = temp.scoringData;
end
    
dataDimensions = size(jbm.scoringData.synapseMatrix);
numSyn = dataDimensions(1);
numTP = dataDimensions(2);
% tic
% for iSyn = 1:numSyn
%     for jTP = 1:numTP
for jTP = 1:numTP % it is faster without keep changing axes.
    for iSyn = 1:numSyn
        ax = h_img3.(jbm.instancesOpen{jTP}).gh.currentHandles.imageAxes;
        xCo = jbm.scoringData.roiCoordinates(1,jTP,iSyn);
        yCo = jbm.scoringData.roiCoordinates(2,jTP,iSyn);
        synID = jbm.scoringData.synapseID{iSyn};
        
        jbm.knobs(iSyn,jTP) = drawscoringroi(ax,xCo,yCo,7,synID,[0 0 0]);
        UData = get(jbm.knobs(iSyn,jTP),'UserData');
        jbm.textKnobs(iSyn,jTP) = UData.texthandle;
    
    end
end
% toc

colorScheme = get(h_img3.I1.gh.currentHandles.scoringColorScheme,'Value');
if colorScheme == 1
    updatecolorscheme('+/-',handles);
elseif colorScheme == 0
    updatecolorscheme('default',handles);
else
end

updateinfo(handles);


end

function printnotes()
global jbm;
[noteSynapseIDs,noteTimePoints] = find(~cellfun(@isempty,jbm.scoringData.synapseNotes));
numNotes = length(noteSynapseIDs);
for iNote = 1:numNotes
    ID = noteSynapseIDs(iNote);
    TP = noteTimePoints(iNote);
    note = jbm.scoringData.synapseNotes{ID,TP};
    printFormattedNote = ['Synapse ' char(jbm.scoringData.synapseID{ID}) ' on Imaging Day ' num2str(TP) ': '  ...
        char(note)];
    char(printFormattedNote);
    disp(printFormattedNote);
end
end

function updateinfo(handles)
global h_img3;
global jbm;
selectedInstance = h_getCurrendInd3(handles);
for i = 1:length(jbm.instancesOpen)
    set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.jbm_dataset_display,'String',jbm.scoringData.datasetName);
    colorscheme = get(h_img3.(jbm.instancesOpen{selectedInstance}).gh.currentHandles.scoringColorScheme,'Value');
    if colorscheme == 1
            set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.scoringColorScheme,'Value',colorscheme,'String','+/-');
            
    else 
            set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.scoringColorScheme,'Value',colorscheme,'String','Default');
            
    end
    

   
    end


            

if colorscheme == 1
    updatecolorscheme('+/-',handles);
elseif colorscheme == 0
    updatecolorscheme('default',handles)
else
end

updateverification(handles);

end

function updatecolorscheme(tag,handles)
global jbm;
global h_img3;

if isfield(jbm,'scoringData')
    if ~isfield(jbm.scoringData,'synapseMatrix')
        return
    else
        ;
    end
else
    errordlg('No Dataset Loaded');
    return
    
end

%+/-
LOST = [0 1 1];
GAINED = [1 0 1];

%Default
PRESENT = [0 0 0];
UNSURE = [0 0 1];
NOTE = [1 0 0];

switch tag
    case '+/-'
        binaryPresence = logical(jbm.scoringData.synapseMatrix);
        differenceMatrix = diff(binaryPresence,1,2);
        [addIndexSyn addIndexTP] = find(differenceMatrix == 1);
        [elimIndexSyn elimIndexTP] = find(differenceMatrix == -1);
        
        tempKnobs = jbm.knobs;
        tempTextKnobs = jbm.textKnobs;
        tempKnobs(tempKnobs == 0) = [];
        tempTextKnobs(tempTextKnobs ==0) = [];
        set(tempKnobs,'Color','y');
        set(tempTextKnobs,'Color','y');
        
        knobs = jbm.knobs;
        textKnobs = jbm.textKnobs;
        
        for i = 1:length(elimIndexSyn)
            set(knobs(elimIndexSyn(i),elimIndexTP(i)),'Color',LOST);
            set(textKnobs(elimIndexSyn(i),elimIndexTP(i)),'Color',LOST);
        end
        
        for i = 1:length(addIndexSyn)
            set(knobs(addIndexSyn(i),addIndexTP(i)+1),'Color',GAINED);
            set(textKnobs(addIndexSyn(i),addIndexTP(i)+1),'Color',GAINED);
        
        end
        
    case 'default'
        [presentSyn presentTP] = find(jbm.scoringData.synapseMatrix == 1);
        [unsureSyn unsureTP] = find(jbm.scoringData.synapseMatrix == 2);
        [noteSyn noteTP] = find(jbm.scoringData.synapseMatrix == 3);
        knobs = jbm.knobs;
        textKnobs = jbm.textKnobs;
        for i = 1:length(presentSyn)
            set(knobs(presentSyn(i),presentTP(i)),'Color',PRESENT);
            set(textKnobs(presentSyn(i),presentTP(i)),'Color',PRESENT);       
        end
        
        for i = 1:length(unsureSyn)
            set(knobs(unsureSyn(i),unsureTP(i)),'Color',UNSURE);
            set(textKnobs(unsureSyn(i),unsureTP(i)),'Color',UNSURE);
        end
        
        for i = 1:length(noteSyn)
            set(knobs(noteSyn(i),noteTP(i)),'Color',NOTE);
            set(textKnobs(noteSyn(i),noteTP(i)),'Color',NOTE);       
        end
        
    otherwise 
end



end

function createnewdataset(handles)
global jbm;
global h_img3;

if isfield(jbm,'scoringData')
    choice = questdlg('Creating a new dataset will delete any unsaved data. Are you sure you wish to proceed?',...
        'Create new','Create new','Go back','Go back');
    switch choice
        case 'Create new'
            jbm = rmfield(jbm,'scoringData');
            createnewdataset(handles);
            return
        case 'Go back'
            return
    end
    
else
    jbm.scoringData = [];
end 

jbm.scoringData.datasetName = inputdlg('Please name your dataset!','Dataset Name');
jbm.scoringData.newSynapseNumber = 1;
jbm.scoringData.synapseVerification = [];
jbm.knobs = [];
jbm.textKnobs = [];
for i = 1:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{i};
    updateinfo(h_img3.(currentInstance).gh.currentHandles);
    
h = get(h_img3.(currentInstance).gh.currentHandles.imageAxes,'Children');
g = findobj(h,'Type','Image');
h(h==g(1)) = [];
delete(h);
end



    
end

function batchgroupload()
    global jbm;
    global h_img3;

    choice = questdlg('Loading a new image group will close all current instances. Are you sure you want to proceed?',...
        'Load em up!','Load em up!','Go back','Go back');
    switch choice
        case 'Load em up!'
           ;
        case 'Go back'
            return;
    end
    
    allInstances = fieldnames(h_img3);
    isCommonField = find(strcmp(allInstances,'common'));
    if exist(isCommonField)
        allInstances(isCommonField) = [];
    else
    end
    
    jbm.instancesOpen = allInstances;
    
    for i = 1:length(jbm.instancesOpen)
        close(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.h_imstack3);
    end
    
    global h_img3;
 
[fn,pn] = uigetfile('*.grp');
pathToGroupFile = [pn fn];
loadedGroupFile = load(pathToGroupFile,'-mat');
group = loadedGroupFile.groupFiles;
numImagesInGroup = length(group);
loadmultipleinstances(numImagesInGroup);

allCurrentInstances = fieldnames(h_img3);
isCommonField = find(strcmp(allCurrentInstances,'common'));
if exist(isCommonField)
    allCurrentInstances(isCommonField) = [];
else
end

jbm.instancesOpen = allCurrentInstances;

for i = 1:length(group)
    currentInstance = jbm.instancesOpen{i};
    h_openFile3(h_img3.(currentInstance).gh.currentHandles,group(i).name);
end


end

function loadmultipleinstances(numInstances)

overflow_position = [1959 559 655 451];

pos(1,1:4) = [15 567 655 451];
pos(2,1:4) = [700 567 655 451];
pos(3,1:4) = [15 50 655 451];
pos(4,1:4) = [700 50 655 451];

pos(5,1:4) = overflow_position;
pos(6,1:4) = overflow_position;
pos(7,1:4) = overflow_position;
pos(8,1:4) = overflow_position;
pos(9,1:4) = overflow_position;
pos(10,1:4) = overflow_position;
pos(11,1:4) = overflow_position;
pos(12,1:4) = overflow_position;
pos(13,1:4) = overflow_position;
pos(14,1:4) = overflow_position;
pos(15,1:4) = overflow_position;

for i = 1:numInstances
    h(i) = h_imstack3;
    set(h(i),'Position',pos(i,1:4));
end
    
end

function closeallinstances()
global jbm;
global h_img3;

for i = 1:length(jbm.instancesOpen)
instance = jbm.instancesOpen{i};
close(h_img3.(instance).gh.currentHandles.h_imstack3);
end

end

function groupzoomalignment(factor)

global jbm;
global h_img3;

for i = 1:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{i};
    currentAxes = h_img3.(currentInstance).gh.currentHandles.imageAxes;
    currentFigure = h_img3.(currentInstance).gh.currentHandles.h_imstack3;
    figure(currentFigure);
    set(currentFigure,'Color',[0 .33 .33])
    
    middleZoomCoordinates(1,:) = ginput_ax(currentAxes);
    delete(findobj(currentAxes,'Tag','zoomInBox3'));
    xlim = get(currentAxes,'xlim');
    ylim = get(currentAxes,'ylim');
    
    offset(1) = diff(xlim)/factor;
    offset(2) = diff(ylim)/factor;
    
    yCo = middleZoomCoordinates(1,1);
    xCo = middleZoomCoordinates(1,2);
    
    p1(1) = yCo - offset(2)/2;
    p1(2) = xCo - offset(1)/2;

    UserData.roi.xi = [p1(1),p1(1)+offset(1),p1(1)+offset(1),p1(1),p1(1)];
    UserData.roi.yi = [p1(2),p1(2),p1(2)+offset(2),p1(2)+offset(2),p1(2)];
    
    hold on;
    h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
    set(h,'ButtonDownFcn', 'h_dragZoomInBox3', 'Tag', 'zoomInBox3', 'Color','black', 'EraseMode','normal');
    hold off;
    UserData.timeLastClick = clock;
    set(h,'UserData',UserData);
    set(currentFigure,'Color',[.941 .941 .941])
    h_zoomIn3(h_img3.(currentInstance).gh.currentHandles);
    

    
end

set(currentFigure,'Color',[.941 .941 .941]);

end

function waitfor_nohotkeys(cfigure)
waitfor(cfigure,'CurrentCharacter');
pressed = double(get(cfigure,'CurrentCharacter'));
acceptable_keypresses = [double('1') double('2') double('0') double('3')];
if isempty(pressed)
    waitfor_nohotkeys(cfigure)
elseif ~isempty(find(acceptable_keypresses == pressed))
    ;
else  
    waitfor_nohotkeys(cfigure);
end
end

function newsynapse(handles)
global jbm;
global h_img3;
TEMP_SIZE = 10;

PRESENT_COLOR = [0 0 0];
UNSURE_COLOR = [0 0 1];
NOTE_COLOR = [1 0 0];

PRESENT = 1;
ABSENT = 0;
UNSURE = 2;
NOTE = 3;
NO_NOTE = '';


if ~isfield(jbm,'scoringData')
    createnewdataset(handles);
else
end

selectedInstance = h_getCurrendInd3(handles);

for iInstance = selectedInstance:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{iInstance};
    currentAxes = h_img3.(currentInstance).gh.currentHandles.imageAxes;
    currentFigure = h_img3.(currentInstance).gh.currentHandles.h_imstack3;
    figure(currentFigure);
    axes(currentAxes);
    h_updateInfo3(handles);
    
    set(currentFigure,'Color',[0 0.33 0.33]);
    set(currentFigure,'CurrentCharacter','8');
    
    waitfor_nohotkeys(currentFigure);   
    pressed = get(currentFigure,'CurrentCharacter');
   
    switch pressed
        case '1'
            roiCoordinates = ginput_ax(currentAxes);
roiSize = TEMP_SIZE;
synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),roiSize,synID,PRESENT_COLOR);
            
            scoredSynapse.data(1,iInstance) = PRESENT;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.roiSize(1,iInstance) = roiSize;
            scoredSynapse.notes{1,iInstance} = NO_NOTE;
        case '0'
            ;
            scoredSynapse.data(1,iInstance) = ABSENT;
            scoredSynapse.knobs(1,iInstance) = ABSENT;
            scoredSynapse.coordinates(1:2,iInstance) = [ABSENT ABSENT];
            scoredSynapse.roiSize(1,iInstance) = ABSENT;   
            scoredSynapse.textKnobs(1,iInstance) = ABSENT;
            scoredSynapse.notes{1,iInstance}  = NO_NOTE;
            
        case '2'
            roiCoordinates = ginput_ax(currentAxes);
roiSize = TEMP_SIZE;
synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),roiSize,synID,UNSURE_COLOR);
            scoredSynapse.notes{1,iInstance} = NO_NOTE;
            scoredSynapse.data(1,iInstance) = UNSURE;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.roiSize(1,iInstance) = roiSize;
               UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
        
        case '3'
            DEFAULT_STRING = 'Note';
            roiCoordinates = ginput_ax(currentAxes);
roiSize=TEMP_SIZE;
synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),roiSize,synID,NOTE_COLOR);
            noteField = h_img3.(currentInstance).gh.currentHandles.synapseNoteField;
            noteConfirm = h_img3.(currentInstance).gh.currentHandles.synapseNoteConfirm;
            set(noteConfirm,'Enable','on','BackgroundColor','g');
            set(noteField,'Enable','on');
            
            waitfor(noteConfirm,'Value',1);
            userInputNote = get(noteField,'String');
            
            set(noteConfirm,'BackgroundColor',[.941 .941 .941],'Enable','off','Value',0,'Selected','off');
            set(noteField,'Enable','off','String',DEFAULT_STRING);
            
            
            
            
            scoredSynapse.notes{1,iInstance} = userInputNote;
            
            
            scoredSynapse.data(1,iInstance) = NOTE;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.roiSize(1,iInstance) = roiSize;
            
            
            
    end
set(currentFigure,'Color',[.941 .941 .941]);
end


updatedataset(scoredSynapse,handles)
jbm.scoringData.newSynapseNumber = jbm.scoringData.newSynapseNumber + 1;
updateinfo(handles);
end

function roiHandle = drawscoringroi(ax,xCoordinate,yCoordinate,ROIsize,synapseNumber,roiColor)
% global h_img3; %Haining.
% global jbm;

if ax~=gca % only run axes as needed.
    axes(ax);%HN note: axes is a very slow function...
else
end
obj = get(ax,'Children');
set(obj,'Selected','off');
% theta = (0:1/40:1)*2*pi;
% xc = xCoordinate;
% yc = yCoordinate;
% xr = ROIsize;
% yr = ROIsize;
% UserData.roi.xi = sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*cos(theta) + xc;
% UserData.roi.yi = sqrt(xr^2*yr^2./(xr^2*sin(theta).^2 + yr^2*cos(theta).^2)).*sin(theta) + yc;
hold on;
% mark_size = 9;
roiHandle = plot(xCoordinate,yCoordinate,'.','MarkerSize',ROIsize, 'Tag', 'scoringROI3',...
    'Color',roiColor, 'EraseMode','normal', 'ButtonDownFcn', 'jbm_dragROI3');
hold off;

UserData.texthandle = text(xCoordinate,yCoordinate,[' ', num2str(synapseNumber)],'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Middle',...
    'Tag', 'scoringROI3text', 'Color',roiColor, 'EraseMode', 'normal', 'ButtonDownFcn', 'jbm_dragText3');


% roiHandle = plot(UserData.roi.xi,UserData.roi.yi,'k-');
% % roiHandle = plot(ax, UserData.roi.xi,UserData.roi.yi,'k-');%HN note: this
% % is faster but this won't work since text can only write to gca.
% 
% set(roiHandle,'ButtonDownFcn', 'jbm_dragROI3', 'Tag', 'scoringROI3', 'EraseMode','xor','linewidth',2);
% 
% set(roiHandle,'Color',roiColor);
% 
% UserData.texthandle = text(xCoordinate,yCoordinate,synapseNumber,'Tag','scoringROI3text','FontSize',13,'FontWeight','bold','HorizontalAlignment',...
%    'Center','VerticalAlignment','Middle', 'Color',roiColor, 'EraseMode','xor', 'ButtonDownFcn', 'jbm_dragText3');

UserData.synapseID = synapseNumber;
UserData.roiHandle = roiHandle;
UserData.timeLastClick = clock;
UserData.xCo = xCoordinate;
UserData.yCo = yCoordinate;
UserData.roiSize = ROIsize;
UserData.roiExist = 1;

set(UserData.texthandle,'UserData',UserData);
set(roiHandle,'UserData',UserData);
end

function updatedataset(scoredSynapse,handles)
global jbm;
global h_img3;
if isfield(jbm.scoringData,'synapseMatrix')
    synapseMatrixDimensions = size(jbm.scoringData.synapseMatrix);
    numSynapses = synapseMatrixDimensions(1);
    numTimePoints = synapseMatrixDimensions(2);
    jbm.scoringData.synapseMatrix(numSynapses+1,:) = scoredSynapse.data;
    jbm.knobs(numSynapses+1,:) = scoredSynapse.knobs;
    jbm.scoringData.roiCoordinates(1:2,:,numSynapses+1) = scoredSynapse.coordinates;
    jbm.scoringData.synapseID{numSynapses+1} = num2str(jbm.scoringData.newSynapseNumber);
    jbm.textKnobs(numSynapses+1,:) = scoredSynapse.textKnobs;
    jbm.scoringData.synapseNotes(numSynapses+1,:) = scoredSynapse.notes;
else
    jbm.scoringData.synapseMatrix(1,:) = scoredSynapse.data;
    jbm.knobs(1,:) = scoredSynapse.knobs;
    jbm.scoringData.synapseID{1} = num2str(jbm.scoringData.newSynapseNumber);
    jbm.scoringData.roiCoordinates(1:2,:,1) = scoredSynapse.coordinates;
    jbm.textKnobs(1,:) = scoredSynapse.textKnobs;
    jbm.scoringData.synapseNotes(1,:) = scoredSynapse.notes;
    jbm.scoringData.synapseVerification = zeros(1,length(scoredSynapse.data));
    
    for i = 1:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{i};
    end
    updateinfo(handles);
end
    

colorscheme = get(h_img3.I1.gh.currentHandles.scoringColorScheme,'Value');
if colorscheme == 1
    updatecolorscheme('+/-',handles);
elseif colorscheme == 0
    updatecolorscheme('default',handles);
else
end


end

function updateverification(handles)
global jbm;
global h_img3;
for i = 1:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{i};
    
    if isempty(jbm.scoringData.synapseVerification)
        set(h_img3.(currentInstance).gh.currentHandles.verification,'BackgroundColor',[.941 .941 .941],'String','VERIFICATION','Enable','off');
    elseif jbm.scoringData.synapseVerification(i) == 0
        set(h_img3.(currentInstance).gh.currentHandles.verification,'BackgroundColor','r','String','UNVERIFIED','Enable','on');
    elseif jbm.scoringData.synapseVerification(i) == 1
        set(h_img3.(currentInstance).gh.currentHandles.verification,'BackgroundColor','g','String',...
            'VERIFIED','Enable','on');
    end
end



end



