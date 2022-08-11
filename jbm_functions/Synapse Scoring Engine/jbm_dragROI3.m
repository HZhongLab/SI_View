function jbm_dragROI3()
global jbm;
global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3;

currentObj = gco;
state = currentStruct.state;
% data = currentStruct.image.data;

% point1 = get(gca,'CurrentPoint'); % button down detected
% point1 = point1(1,1:2);              % extract x and y

UData = get(currentObj,'UserData');

scoringROIObj = findobj(handles.imageAxes,'Tag','scoringROI3');
set(scoringROIObj, 'Selected','off', 'MarkerSize', UData.roiSize);% this set all to the marker size of clicked mark. May cause problems...

set(gco,'Selected','on','SelectionHighlight','off', 'MarkerSize', 2*UData.roiSize);

t0 = clock; 
% disp(etime(t0,UserData.timeLastClick))

if isfield(UData,'timeLastClick') && etime(t0,UData.timeLastClick) < 0.4
    if strcmpi(get(currentObj, 'tag'), 'scoringROI3') || strcmpi(get(currentObj, 'tag'), 'BGROI3')
        UData = get(currentObj,'UserData');
        synIDToDelete = num2str(UData.synapseID);
        deletionIndex = ismember(jbm.scoringData.synapseID,synIDToDelete);%Haining note: use a logical index is faster 
%         deletionIndex = double(deletionIndex);%unnecessary
        jbm.scoringData.synapseMatrix(deletionIndex,:) = [];
        jbm.scoringData.roiCoordinates(:,:,deletionIndex) = [];
        jbm.scoringData.synapseID(deletionIndex) = [];
        jbm.scoringData.synapseNotes(deletionIndex,:) = [];
        jbm.scoringData.synapseZ(deletionIndex,:) = [];
        
        
        knobsToDelete = jbm.knobs(deletionIndex,:);
        knobsToDelete = knobsToDelete(knobsToDelete~=0);
        delete(knobsToDelete);
        jbm.knobs(deletionIndex,:) = [];
        
        textKnobsToDelete = jbm.textKnobs(deletionIndex,:);
        textKnobsToDelete = textKnobsToDelete(textKnobsToDelete~=0);
        delete(textKnobsToDelete);
        jbm.textKnobs(deletionIndex,:) = [];
        jbm_synapsescoringengine('return data',handles);
        return;
   end
else
    UData.timeLastClick = t0;
    set(currentObj,'UserData',UData);
end

lockROI = state.lockROI.value;
if lockROI
    h = findobj(handles.imageAxes,'Tag','scoringROI3');
else
    h = gco;
end

currentGcaUnit = get(handles.imageAxes,'Unit');
set(handles.imageAxes,'Unit','normalized');
rectFigure = get(handles.h_imstack3, 'Position');
rectAxes = get(handles.imageAxes, 'Position');
set(handles.imageAxes,'Unit',currentGcaUnit);

Xlimit = get(handles.imageAxes, 'XLim');
Ylimit = get(handles.imageAxes, 'Ylim');
Ylim = Ylimit(2)-Ylimit(1);
Xlim = Xlimit(2)-Xlimit(1);
xmag = (rectFigure(3)*rectAxes(3))/Xlim;  %pixel/screenpixel
xoffset =rectAxes(1)*rectFigure(3);
ymag = (rectFigure(4)*rectAxes(4))/Ylim;
yoffset = rectAxes(2)*rectFigure(4);

for i = 1:length(h)
    UData(i) = get(h(i),'UserData');
    RoiRect(i,:) = [UData(i).xCo-2,UData(i).yCo-2, 4, 4];
    rect1w = RoiRect(i,3)*xmag;
    rect1h = RoiRect(i,4)*ymag;
    rect1x = (RoiRect(i,1)-Xlimit(1))*xmag+xoffset;
    rect1y = (Ylimit(2) - RoiRect(i,2))*ymag + yoffset - rect1h;
    rects(i,:) = [rect1x, rect1y, rect1w, rect1h];
end

finalRect = dragrect(rects);

for i = 1:length(h)
    newRoiw = finalRect(i,3)/xmag;
    newRoih = finalRect(i,4)/ymag;
    newRoix = (finalRect(i,1) - xoffset)/xmag +Xlimit(1);
    newRoiy = Ylimit(2) - (finalRect(i,2) - yoffset + finalRect(i,4))/ymag;
    UData(i).xCo = newRoix+newRoiw/2;
    UData(i).yCo = newRoiy+newRoih/2;
          
    set(h(i),'XData',UData(i).xCo,'YData',UData(i).yCo,'UserData',UData(i));
    set(UData(i).texthandle, 'Position', [newRoix+newRoiw/2,newRoiy+newRoih/2],'UserData',UData(i));
end

% Haining note: this is to deal with other instance... not sure how JBM
% want to handle this.
for i = 1:length(jbm.instancesOpen)
    imageAxes = h_img3.(jbm.instancesOpen{i}).gh.currentHandles.imageAxes;
    selectedROI = findobj(imageAxes,'Selected','on');
    if isempty(selectedROI)
        ;
    else
        
    [tempX,tempY] = find(jbm.knobs == selectedROI);
     if isempty(jbm.scoringData.synapseNotes{tempX,tempY})
        set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.synapseNoteField,'String','NO NOTE')
     else
        
   set(h_img3.(jbm.instancesOpen{i}).gh.currentHandles.synapseNoteField,'String',jbm.scoringData.synapseNotes{tempX,tempY});
    end
    end
    
    jbm_synapsescoringengine('updateinfo',handles);
end

