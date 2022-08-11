function jbm_synapsescoringengine(tag,handles)
    global jbm;
    global h_img3;
    global synScore;
    
    jbm.scoringData.versionInfo.version = '2.0';
    jbm.scoringData.versionInfo.conventions = ['\n\n0 = absent \n1 = shaft (blue) \n2 = spine (purple) \n3 = unsure (cyan) \n4 = spine no psd (yellow) \n\n'];

    synScore.SHAFT_COLOR = [0 0 1]; % Blue
    synScore.SPINE_COLOR = [1 0 1]; % Purple
    synScore.UNSURE_COLOR = [0 1 1]; % Cyan
    synScore.SPO_COLOR = [1 1 0]; % Yellow

    [selectedInstance,handles,currentStruct,currentStructName] = h_getCurrendInd3(handles);
    allInstances = fieldnames(h_img3);
    
    isCommonField = find(strcmp(allInstances,'common'));
    if exist(isCommonField)
        allInstances(isCommonField) = [];
    else
    end
    
    jbm.instancesOpen = allInstances;
    
    switch tag
        case 'print conventions'
            printconventions()
        case 'exit skeleton trace mode'
            exittracemode(handles);
        case 'return data'
            returndata();
        case 'edit note'
            editnote(handles);
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
        case 'updateinfo'
            updateinfo(handles);
        case 'global sync'
            globalsync(handles);
        case 'enter skeleton trace mode'
            skeletontrace(handles);
    end
    
end

function printconventions()
global jbm;
fprintf(jbm.versionInfo.conventions);
end

function editnote(handles)
global h_img3;
global jbm;

currentInstance = h_getCurrendInd3(handles);
currentInstance = jbm.instancesOpen{currentInstance};
noteConfirm = h_img3.(currentInstance).gh.currentHandles.synapseNoteConfirm;
noteField = h_img3.(currentInstance).gh.currentHandles.synapseNoteField; 
noteEdit = h_img3.(currentInstance).gh.currentHandles.noteEdit

set(noteField,'Enable','on','BackgroundColor','g');
set(noteConfirm,'Enable','on','BackgroundColor','g');
set(noteEdit,'Enable','off');
obj = findobj(h_img3.(currentInstance).gh.currentHandles.imageAxes,'Selected','on');
if isempty(obj)
    return
else
end
[tempX, tempY] = find(jbm.knobs == obj);



waitfor(noteConfirm,'Value',1);
userInputNote = get(noteField,'String');



jbm.scoringData.synapseNotes{tempX,tempY} = userInputNote;






set(h_img3.(currentInstance).gh.currentHandles.synapseNoteField,'Enable','off','BackgroundColor',[.941 .941 .941],'Value',0);
set(h_img3.(currentInstance).gh.currentHandles.synapseNoteConfirm,'Enable','off','BackgroundColor',[.941 .941 .941],'Value',0);

updateinfo(handles);

end

function returndata(~)
global jbm;

assignin('base','currentScoringData',jbm.scoringData);
assignin('base','currentSynapseMatrix',jbm.scoringData.synapseMatrix);
% assignin('base','currentSynapseNotes',jbm.scoringData.synapseNotes);
assignin('base','currentSynapseIDs',jbm.scoringData.synapseID);
disp('SCORING METADATA (currentScoringData):')
disp(jbm.scoringData)
disp('SYNAPSE MATRIX (Synapse ID // currentSynapseMatrix):');
[numSyn,numTP] = size(jbm.scoringData.synapseMatrix);


displayMatrix = zeros(numSyn,numTP+1);
for i = 1:numSyn
    displayMatrix(i,1) = str2num(jbm.scoringData.synapseID{i});
end

displayMatrix(:,2:end) = jbm.scoringData.synapseMatrix;

disp(displayMatrix)


end

function saveScoringData(handles)
global jbm;
updateROIcoordinates(handles);
scoringData = jbm.scoringData;
numInst = length(jbm.instancesOpen);
if numInst == sum(scoringData.synapseVerification)
   
    uisave('scoringData',char(jbm.scoringData.datasetName));
else
    warndlg('NOT ALL TIMEPOINTS VERIFIED!')
   
    uisave('scoringData',['UNVERIFIED_' char(jbm.scoringData.datasetName)]);
    
end


end

function loadScoringData(handles)

global jbm;
global h_img3;
[fn pn] = uigetfile();
if fn~=0
filePath = [pn fn];
temp = load(filePath,'-mat');

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
        
        jbm.knobs(iSyn,jTP) = drawscoringroi(ax,xCo,yCo,synID,[0 0 0]);
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

function globalsync(handles)
global h_img3;
global jbm;

selectedInstance = h_getCurrendInd3(handles);
[currentInd, handlez, currentStruct, currentStructName] = h_getCurrendInd3(handles);


globalsync = get(h_img3.(jbm.instancesOpen{selectedInstance}).gh.currentHandles.togglebutton3,'Value');

for i = 1:length(jbm.instancesOpen)
    
    set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.togglebutton3,'Value',globalsync);
    
    if globalsync == 1
     set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.togglebutton3,'ForegroundColor','g')
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncMovement,'Value',0);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncZMovement,'Value',0);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncZoomOpt,'Value',0);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncANumber,'Value',0);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncGrp,'Value',0);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncDispOpt,'Value',0);
    else 
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.togglebutton3,'ForegroundColor','r')
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncMovement,'Value',1);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncZMovement,'Value',1);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncZoomOpt,'Value',1);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncANumber,'Value',1);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncGrp,'Value',1);
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.syncDispOpt,'Value',1);
    end
end

end 

function updateinfo(handles)
global h_img3;
global jbm;
try 
    updateskeletoninfo(handles);
catch
    %
end
selectedInstance = h_getCurrendInd3(handles);
[currentInd, handlez, currentStruct, currentStructName] = h_getCurrendInd3(handles);

for i = 1:length(jbm.instancesOpen)
    
    set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.jbm_dataset_display,'String',jbm.scoringData.datasetName);
    colorscheme = get(h_img3.(jbm.instancesOpen{selectedInstance}).gh.currentHandles.scoringColorScheme,'Value');
    currentAx = h_img3.(jbm.instancesOpen{i}).gh.currentHandles.imageAxes;
    obj = findobj(currentAx,'Selected','on');
    
    plotOptValue = get(h_img3.(currentStructName).gh.currentHandles.scoringGUIPlotOpt,'Value');
    set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.scoringGUIPlotOpt,'Value',plotOptValue);

    if isempty(obj)
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.noteEdit,'Enable','off')
    else
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.noteEdit,'Enable','on')
    end
    
    
        
    
    if isfield(jbm,'scoringData')
        if isfield(jbm.scoringData,'synapseMatrix')
            if ~isempty(jbm.scoringData.synapseMatrix)
                set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.data,'Enable','on');
            else
                set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.data,'Enable','off');;
            end
        else
            set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.data,'Enable','off');
        end
    else
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.data,'Enable','off');
    end
    
        
    
    
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

function updatecolorscheme(tag,handles)
global jbm;
global h_img3;
global synScore;

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
LOST = [1 0 0];%red
GAINED = [0 1 0];%green
TRANSIENT = [1 1 0];%yellow



        binaryPresence = logical(jbm.scoringData.synapseMatrix);
        differenceMatrix = diff(binaryPresence,1,2);
        additionMatrix = false(size(jbm.scoringData.synapseMatrix));
        eliminationMatrix = false(size(jbm.scoringData.synapseMatrix));
        additionMatrix(:, 2:end) = differenceMatrix == 1;
        eliminationMatrix(:, 1:end-1) = differenceMatrix == -1;
        transientMatrix = additionMatrix & eliminationMatrix;
        
        tempKnobs = jbm.knobs; % Necessary: removes 0 from absent knobs (root obj)
        tempTextKnobs = jbm.textKnobs;
        tempKnobs(tempKnobs == 0) = [];
        tempTextKnobs(tempTextKnobs ==0) = [];
        
        
        knobs = jbm.knobs;
        textKnobs = jbm.textKnobs;
        
        switch tag
            case 'default'
                set(knobs(jbm.scoringData.synapseMatrix == 1), 'Color', synScore.SHAFT_COLOR);% do it this sequence so gain/lost has priority.
                set(knobs(jbm.scoringData.synapseMatrix == 2), 'Color', synScore.SPINE_COLOR);
                set(knobs(jbm.scoringData.synapseMatrix == 3), 'Color', synScore.UNSURE_COLOR);
                set(knobs(jbm.scoringData.synapseMatrix == 4), 'Color', synScore.SPO_COLOR);
                set(textKnobs(jbm.scoringData.synapseMatrix == 1), 'Color', synScore.SHAFT_COLOR);% do it this sequence so gain/lost has priority.
                set(textKnobs(jbm.scoringData.synapseMatrix == 2), 'Color', synScore.SPINE_COLOR);
                set(textKnobs(jbm.scoringData.synapseMatrix == 3), 'Color', synScore.UNSURE_COLOR);
                set(textKnobs(jbm.scoringData.synapseMatrix == 4), 'Color', synScore.SPO_COLOR);
            case '+/-'
                set(knobs(jbm.scoringData.synapseMatrix == 1), 'Color', [0 0 1]);% do it this sequence so gain/lost has priority.
                set(knobs(jbm.scoringData.synapseMatrix == 2), 'Color', [0 0 1]);
                set(knobs(jbm.scoringData.synapseMatrix == 3), 'Color', [0 0 1]);
                set(knobs(jbm.scoringData.synapseMatrix == 4), 'Color', [0 0 1]);
                set(textKnobs(jbm.scoringData.synapseMatrix == 1), 'Color', [0 0 1]);% do it this sequence so gain/lost has priority.
                set(textKnobs(jbm.scoringData.synapseMatrix == 2), 'Color',[0 0 1]);
                set(textKnobs(jbm.scoringData.synapseMatrix == 3), 'Color', [0 0 1]);
                set(textKnobs(jbm.scoringData.synapseMatrix == 4), 'Color', [0 0 1]);
                set(knobs(eliminationMatrix), 'Color', LOST);
                set(knobs(additionMatrix), 'Color', GAINED);
                set(knobs(transientMatrix), 'Color', TRANSIENT);
                set(textKnobs(eliminationMatrix), 'Color', LOST);
                set(textKnobs(additionMatrix), 'Color', GAINED);
                set(textKnobs(transientMatrix), 'Color', TRANSIENT);
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
tempString = char(jbm.scoringData.datasetName);

jbm.scoringData.datasetName = [tempString '.syn']

jbm.scoringData.newSynapseNumber = 1;
jbm.scoringData.synapseVerification = [];
jbm.knobs = [];
jbm.textKnobs = [];
for i = 1:length(jbm.instancesOpen)
    currentInstance = jbm.instancesOpen{i};
    updateinfo(h_img3.(currentInstance).gh.currentHandles);
   
h = findobj(h_img3.(currentInstance).gh.currentHandles.imageAxes, 'tag', 'scoringROI3'); 
delete(h);
h = findobj(h_img3.(currentInstance).gh.currentHandles.imageAxes, 'tag', 'scoringROI3text'); 
delete(h);

end

for instance = 1:length(jbm.instancesOpen)
    set(h_img3.(jbm.instancesOpen{instance}).gh.currentHandles.newsynapse_push,'Enable','on')
end

    
end

function waitfor_nohotkeys(cfigure)
waitfor(cfigure,'CurrentCharacter');
pressed = double(get(cfigure,'CurrentCharacter'));
acceptable_keypresses = [double('1') double('2') double('0') double('3') double('4') double('5') double('6')];
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
global synScore;

UNUSED_HOTKEY = '9';

for instance = 1:length(jbm.instancesOpen)
    set(h_img3.(jbm.instancesOpen{instance}).gh.currentHandles.newsynapse_push,'Enable','off')
end




ABSENT = 0;
SHAFT = 1;
SPINE = 2;
UNSURE = 3;
SPO = 4;

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
    set(currentFigure,'CurrentCharacter',UNUSED_HOTKEY);
    
    waitfor_nohotkeys(currentFigure);   
    pressed = get(currentFigure,'CurrentCharacter');
   
    switch pressed
         case '0'
            scoredSynapse.data(1,iInstance) = ABSENT;
            scoredSynapse.knobs(1,iInstance) = ABSENT;
            scoredSynapse.coordinates(1:2,iInstance) = [ABSENT ABSENT];
            scoredSynapse.roiSize(1,iInstance) = ABSENT;   
            scoredSynapse.textKnobs(1,iInstance) = ABSENT;
            scoredSynapse.notes{1,iInstance}  = NO_NOTE;
            
        case '1'
            axes(currentAxes);
            roiCoordinates = ginput(1);
            
            synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),synID,synScore.SHAFT_COLOR);
            scoredSynapse.notes{1,iInstance}  = NO_NOTE;
            scoredSynapse.data(1,iInstance) = SHAFT;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;

        case '2'
            axes(currentAxes);
            roiCoordinates = ginput(1);
            synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),synID,synScore.SPINE_COLOR);
            scoredSynapse.data(1,iInstance) = SPINE;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.notes{1,iInstance}  = NO_NOTE;
            
       case '3'
            axes(currentAxes);
            roiCoordinates = ginput(1);
            synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),synID,synScore.UNSURE_COLOR);
            scoredSynapse.data(1,iInstance) = UNSURE;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.notes{1,iInstance}  = NO_NOTE; 
       case '4'
            axes(currentAxes);
            roiCoordinates = ginput(1);
            synID = num2str(jbm.scoringData.newSynapseNumber);
            synHandle = drawscoringroi(currentAxes,roiCoordinates(1),roiCoordinates(2),synID,synScore.SPO_COLOR);
            scoredSynapse.data(1,iInstance) = SPO;
            scoredSynapse.knobs(1,iInstance) = synHandle;
            UData = get(synHandle,'UserData');
            scoredSynapse.textKnobs(1,iInstance) = UData.texthandle;
            scoredSynapse.coordinates(1:2,iInstance) = roiCoordinates;
            scoredSynapse.notes{1,iInstance}  = NO_NOTE;    
    end

    zHi = get(h_img3.(currentInstance).gh.currentHandles.zStackStrHigh,'String');
    zLo = get(h_img3.(currentInstance).gh.currentHandles.zStackStrLow,'String');
    
    if zHi ~= zLo
        zHi = str2num(zHi);
        zLo = str2num(zLo);
        scoredSynapse.synapseZ(1,iInstance) = mean(zHi,zLo);
    elseif zHi == zLo
        zHi = str2num(zHi);
        scoredSynapse.synapseZ(1,iInstance) = zHi;
    end
set(currentFigure,'Color',[.941 .941 .941]);
end


updatedataset(scoredSynapse,handles)
jbm.scoringData.newSynapseNumber = jbm.scoringData.newSynapseNumber + 1;
updateinfo(handles);

activePlotter();
for instance = 1:length(jbm.instancesOpen)
    set(h_img3.(jbm.instancesOpen{instance}).gh.currentHandles.newsynapse_push,'Enable','on')
end
end

function roiHandle = drawscoringroi(ax,xCoordinate,yCoordinate,synapseNumber,roiColor)
% global h_img3; %Haining.
% global jbm;

ROIsize = 10;

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
    'Tag', 'scoringROI3text', 'Color',roiColor,'FontWeight','Bold', 'EraseMode', 'normal', 'ButtonDownFcn', 'jbm_dragText3');


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
    jbm.scoringData.synapseZ(numSynapses+1,:) = scoredSynapse.synapseZ;
    jbm.scoringData.synapseNotes(numSynapses+1,:) = scoredSynapse.notes;
else
    jbm.scoringData.synapseMatrix(1,:) = scoredSynapse.data;
    jbm.knobs(1,:) = scoredSynapse.knobs;
    jbm.scoringData.synapseID{1} = num2str(jbm.scoringData.newSynapseNumber);
    jbm.scoringData.roiCoordinates(1:2,:,1) = scoredSynapse.coordinates;
    jbm.textKnobs(1,:) = scoredSynapse.textKnobs;
    jbm.scoringData.synapseVerification = zeros(1,length(scoredSynapse.data));
    jbm.scoringData.synapseZ(1,:) = scoredSynapse.synapseZ;
    jbm.scoringData.synapseNotes(1,:) = scoredSynapse.notes;
    
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

function updateROIcoordinates(handles)

global jbm;
global h_img3;

dataDim = size(jbm.knobs);
numSyn = dataDim(1);
numDays = dataDim(2); 


for ii = 1:numDays
   for jj = 1:numSyn
       if jbm.knobs(jj,ii) ~= 0
        synapse = jbm.knobs(jj,ii);
        UData = get(synapse);
         xCo = UData.XData;
         yCo = UData.YData;
            if vertcat(xCo,yCo) ~= jbm.scoringData.roiCoordinates(:,ii,jj)
                newCoordinates = vertcat(xCo,yCo);
                jbm.scoringData.roiCoordinates(:,ii,jj) = newCoordinates;
            else
            end
       else
       end
       
   end
end

       



end

function activePlotter()


global h_img3;
global jbm;
global activeplotter;

handles=4;
returndata();
% gate = get(h_img3.I1.gh.currentHandles.scoringGUIPlotOpt,'Value');
% if gate == 7
% data = jbm.scoringData;
% data.presenceMatrix = data.synapseMatrix>0;
% Aout = h_routinesForInVivoAnalysis(1:4,data,0);
% 
%  
% 
% f1 = figure(1);
% clf;
% a1 = axes;
% set(f1,'Position',[-929 629 341 268]);
% dates = 0:4:4*(length(Aout.synapseNum)-1);
% plot(dates, Aout.synapseNum, '-o');
% ylim([0, ceil(max(Aout.synapseNum)/10)*10]);
% ylabel('synapse number', 'fontsize', 12);
% xlabel('imaging day', 'fontsize', 12);
% 
% f2 = figure(2);
% clf;
% a2 = axes;
% set(f2,'Position', [-586 629 347 267]);
% dates = 0:4:4*(length(Aout.survivalFcn)-1);
% plot(dates, Aout.survivalFcn, '-o');
% ylim([0, 1.1]);
% ylabel('Survival Fraction', 'fontsize', 12);
% xlabel('imaging day', 'fontsize', 12);
% 
% f3 = figure(3);
% clf;
% a3 = axes;
% set(f3,'Position',[-926 277 339 276] );
% dates = 0:4:4*(length(Aout.elimination)-1);
% plot(dates, Aout.elimination, '-o');
% ylim([0, max(Aout.elimination)+1]);
% ylabel('Elimination Number', 'fontsize', 12);
% xlabel('imaging day', 'fontsize', 12);
% 
% f4 = figure(4);
% clf;
% a4 = axes;
% set(f4,'Position',[-590 279 350 274])
% dates = 0:4:4*(length(Aout.addition)-1);
%  plot(dates, Aout.addition, '-o');
% ylim([0, max(Aout.addition)+1]);
% ylabel('Addition Number', 'fontsize', 12);
% xlabel('imaging day', 'fontsize', 12);
% 
% ll = length(jbm.instancesOpen);
% figure(h_img3.(jbm.instancesOpen{ll}).gh.currentHandles.h_imstack3);
% else 
% end




end

function skeletontrace(handles)
global jbm;
global h_img3;
currentInstance = h_getCurrendInd3(handles);
jbm.scoringData.skeleton.traceMode = zeros(1,length(jbm.instancesOpen));
jbm.scoringData.skeleton.traceMode(currentInstance) = 1;
updateskeletoninfo(handles);

end
    
function exittracemode(handles);
global jbm;
currentInstance = h_getCurrendInd3(handles);    
jbm.scoringData.skeleton.traceMode = zeros(1,length(jbm.instancesOpen));
updateskeletoninfo(handles);

end

function updateskeletoninfo(handles);
global jbm;
global h_img3; 

numTP = length(jbm.instancesOpen);

for i = 1:numTP
    
    
    currentInstance = jbm.instancesOpen{i};
    currentAxes = h_img3.(currentInstance).gh.currentHandles.imageAxes;
    currentFigure = h_img3.(currentInstance).gh.currentHandles.h_imstack3;
    figure(currentFigure);
    axes(currentAxes);
    h_updateInfo3(handles);
    
    if isfield(jbm.scoringData.skeleton,'skeletonLengths')
        data = num2cell(jbm.scoringData.skeleton.skeletonLengths);
    else
    data = cell(1,numTP);
    end
    
    set(h_img3.(currentInstance).gh.currentHandles.dendriteLengthTable,...
        'data',data);
    % Figure Color -> Red if Trace Mode == 1
    if jbm.scoringData.skeleton.traceMode(i) == 1
        set(currentFigure,'Color',[.6 .1 .04]);
        activeFigure = currentFigure;
        set(h_img3.(currentInstance).gh.currentHandles.markSkeleton,'Enable','on')
        set(h_img3.(currentInstance).gh.currentHandles.traceSkeleton,'Enable','on')
        set(h_img3.(currentInstance).gh.currentHandles.finalizeSkeleton,'Enable','on')
    else
        set(currentFigure,'Color','default');
        set(h_img3.(currentInstance).gh.currentHandles.markSkeleton,'Enable','off')
        set(h_img3.(currentInstance).gh.currentHandles.traceSkeleton,'Enable','off')
        set(h_img3.(currentInstance).gh.currentHandles.finalizeSkeleton,'Enable','off')
    end
end

if exist('activeFigure')
figure(activeFigure);
end


end
