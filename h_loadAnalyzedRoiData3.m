function h_loadAnalyzedRoiData3(handles, flag)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);


currentFilename = get(handles.currentFileName,'String');
[pname, fname, fExt] = fileparts(currentFilename);
analysisNumber = h_img3.(currentStructName).state.analysisNumber.value;

switch lower(flag)
    case 'v3'
        roiFilename = fullfile(pname,'Analysis',[fname,'_V3roi_A',num2str(analysisNumber),'.mat']);
%         load(roiFilename);
    case 'v2'
        roiFilename = fullfile(pname,'Analysis',[fname,'_roi',num2str(analysisNumber),'.mat']);
%         load(roiFilename);
    case 'v1'
        if analysisNumber==1
            analysisNumber = [];
        end
        roiFilename = fullfile(pname,'Analysis',[fname,'_zroi',num2str(analysisNumber),'.mat']);
    otherwise
end

if exist(roiFilename, 'file')
    load(roiFilename);
    h_img3.(currentStructName).lastAnalysis.calcROI = Aout;
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
            set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'ROI3', 'Color','red');
            hold off;
            
            x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
            y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
            UserData.texthandle = text(x,y,num2str(Aout.roiNumber(i)),'HorizontalAlignment',...
                'Center','VerticalAlignment','Middle', 'Color','red', 'ButtonDownFcn', 'h_dragRoiText3');
            UserData.number = Aout.roiNumber(i);
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

if isfield(currentStruct.state, 'loadAnnotatedROIOpt') && currentStruct.state.loadAnnotatedROIOpt.value...
        && exist('Bout', 'var')
    h_img3.(currentStructName).lastAnalysis.calcAnnotationROI = Bout;
    objs = findobj(handles.imageAxes,'Tag','annotationROI3');
    for i = 1:length(objs)
        UserData = get(objs(i),'UserData');
        delete(objs(i));
        delete(UserData.texthandle);
    end
    axes(handles.imageAxes);
    if isfield(Bout,'roi')
        for i = 1:length(Bout.roi)
            UserData = Bout.annotationROIUserData(i);
            
            hold on;
            h = plot(UserData.roi.xi,UserData.roi.yi,'m:', 'linewidth', 1);
            set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'annotationROI3', 'Color','black', 'EraseMode','xor');
            hold off;
            
            x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
            y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
            if UserData.synapseAnalysis.synapseNumber > 0
                textStr = ['S',num2str(UserData.synapseAnalysis.synapseNumber)];
            else
                textStr = num2str(UserData.number);
            end
            UserData.texthandle = text(x,y,textStr,'HorizontalAlignment', 'Center','VerticalAlignment','Middle', ...
                'Color','black', 'ButtonDownFcn', 'h_dragRoiText3','FontSize', 14, 'FontWeight', 'Bold');
            UserData.ROIhandle = h;
            UserData.timeLastClick = clock;
            set(h,'UserData',UserData);
            set(UserData.texthandle,'UserData',UserData);
        end
    end
end

if currentStruct.state.loadDisplayOpt.value && isfield(Aout, 'currentSettings')% if also loading settings. This is like loading default but only for selected fields.
%     exclusionList = getExclusionList;
    inclusionList = getInclusionList; %better this way as teh there may be more and more fields for state in the future.
    state = currentStruct.state;
    fieldNames = fieldnames(Aout.currentSettings.state);
%     fieldNames = fieldNames(~ismember(fieldNames, exclusionList));
    fieldNames = fieldNames(ismember(fieldNames, inclusionList));
    for i = 1:length(fieldNames)
        state.(fieldNames{i}) = Aout.currentSettings.state.(fieldNames{i});
    end
    h_img3.(currentStructName).state = state;
    

    
%     if state ~= previousState % struct cannot be compare this way... just bypass for now.
        h_setParaAccordingToState3(handles);
        
        % additional: z are not recorded in state:
        set(handles.zStackStrLow, 'String', num2str(Aout.currentSettings.zLimit(1)));
        set(handles.zStackStrHigh, 'String', num2str(Aout.currentSettings.zLimit(2)));
        
        h_zStackQuality3(handles);% this is needed to set sliders.
        h_replot3(handles, 'slow');%Note: put getCurrentImg into replot
%     end
end



function list = getInclusionList
list = {
    'redLimitStrLow'
    'redLimitStrHigh'
    'greenLimitStrLow'
    'greenLimitStrHigh'
    'blueLimitStrLow'
    'blueLimitStrHigh'
    'viewingAxisControl'
    'maxProjectionOpt'
    'smoothImage'
    'ratioBetweenAxes'
    'colorMapOpt'
    };

    