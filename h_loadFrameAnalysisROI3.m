function h_loadFrameAnalysisROI3(handles)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
% [xlim,ylim,zlim] = FV_getLimits(handles); % need limits to put text at the same location for combinedROIs...

currentFilename = get(handles.currentFileName,'String');
[pname, fname] = fileparts(currentFilename);
analysisNumber = currentStruct.state.analysisNumber.value;

roiFilename = fullfile(pname,'Analysis',[fname,'_frameAnalysis3_A',num2str(analysisNumber),'.mat']);

if exist(roiFilename, 'file')
    load(roiFilename);
    h_img3.(currentStructName).lastAnalysis.frameAnalysis = Aout;
    objs = [findobj(handles.imageAxes,'Tag','ROI3');findobj(handles.imageAxes,'Tag','BGROI3')];
    for i = 1:length(objs)
        UserData = get(objs(i),'UserData');
        delete(objs(i));
        delete(UserData.texthandle);
    end
    axes(handles.imageAxes);
    if isfield(Aout,'roi')
        for i = 1:length(Aout.roi)
            UserData.roi.xi = Aout.roi(i).xi;
            UserData.roi.yi = Aout.roi(i).yi;
            
            hold on;
            h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
            set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'ROI3', 'Color','red');%, 'EraseMode','xor');
            hold off;
            
            x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
            y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
            UserData.texthandle = text(x,y,num2str(Aout.ROINumber(i)),'HorizontalAlignment',...
                'Center','VerticalAlignment','Middle', 'Color','red', 'ButtonDownFcn', 'h_dragRoiText3');
            UserData.number = Aout.ROINumber(i);
            UserData.ROIhandle = h;
            UserData.timeLastClick = clock;
            set(h,'UserData',UserData);
            set(UserData.texthandle,'UserData',UserData);
        end
    end
    
    if isfield(Aout,'bgroi') && ~isempty(Aout.bgroi)
        UserData.roi.xi = Aout.bgroi.xi;
        UserData.roi.yi = Aout.bgroi.yi;
        
        hold on;
        h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
        set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'BGROI3');
        hold off;
        
        x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
        y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
        UserData.texthandle = text(x,y,'BG','HorizontalAlignment',...
            'Center','VerticalAlignment','Middle', 'Color','red', 'ButtonDownFcn', 'h_dragRoiText3');
        UserData.number = 'BG';
        UserData.ROIhandle = h;
        UserData.timeLastClick = clock;
        set(h,'UserData',UserData);
        set(UserData.texthandle,'UserData',UserData);
    end
end

h_setDendriteTracingVis3(handles);% the function was originally only for dendrite tracing but now expand to ROIs.

if currentStruct.state.frameAnalysisLoadSettingOpt.value && exist('Aout', 'var')% if also loading settings. This is like loading default but only for selected fields.
%     exclusionList = getExclusionList;
    inclusionList = internal_getInclusionList3; %better this way as teh there may be more and more fields for state in the future.
    state = currentStruct.state;
%     previousState = state;
    stateFieldNames = fieldnames(Aout.currentSettings.state);
%     fieldNames = fieldNames(~ismember(fieldNames, exclusionList));
    stateFieldNames = stateFieldNames(ismember(stateFieldNames, inclusionList));
    for i = 1:length(stateFieldNames)
        state.(stateFieldNames{i}) = Aout.currentSettings.state.(stateFieldNames{i});
    end
    h_img3.(currentStructName).state = state;
    
%     if state ~= previousState % struct cannot be compare this way... just bypass for now.
        h_setParaAccordingToState3(handles);
        
        % additional: z are not recorded in state:
        set(handles.zStackStrLow, 'String', num2str(Aout.includedZ(1)));
        set(handles.zStackStrHigh, 'String', num2str(Aout.includedZ(end)));
        h_zStackQuality3(handles);
        
        h_replot3(handles, 'slow');%Note:  getCurrentImg is in replot
%     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list = internal_getInclusionList3
list = {
    'redLimitStrLow'
    'redLimitStrHigh'
    'greenLimitStrLow'
    'greenLimitStrHigh'    
    'blueLimitStrLow'
    'blueLimitStrHigh'
    'maxProjectionOpt'
    'smoothImage'
    'bleedThroughCorrOpt'
    'gamma'
    'imageMode'
    'viewingAxisControl'
    'colorMapOpt'
    'ratioBetweenAxes'
    };
    