function err = h_loadDefault3(handles, flag)

global h_img3;

% flag =    1 (default), 2 or 3

if ~exist('flag', 'var') || isempty(flag)
    flag = 1;
end

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

pname = h_findFilePath('h_imstack3.m');
fileName = fullfile(pname, 'h_imstack3Default.mat');

if exist(fileName, 'file')
    temp = load(fileName); %this should load a variable called "settings".
    settings = temp.settings; % this is required for newer MATLAB versions. Haining 2019-12-03
    err = 0;
else
    disp(['cannot find setting file: ', fileName]);
    err = 1;
    return
end

% previousState = currentStruct.state;

h_img3.(currentStructName).state = settings(flag).state;
h_setParaAccordingToState3(handles);
if isfield(currentStruct.image,'data')
    [xlim,ylim,zlim] = h_getLimits3(handles);
    set(handles.zStackStrLow,'String', num2str(zlim(1)));
    set(handles.zStackStrHigh,'String', num2str(zlim(2)));
    h_zStackQuality3(handles);
    set(handles.imageAxes,'XLim',xlim,'YLim',ylim);
    h_replot3(handles);
    h_roiQuality3(handles);
    h_updateInfo3(handles);
end

% if ~isempty(fieldnames(previousState))% this can happen when FLIMview just start.
%     if ~strcmp(settings(flag).state.t0Setting.string, previousState.t0Setting.string) ||...
%             ~strcmp(settings(flag).state.spcRangeLow.string, previousState.spcRangeLow.string)  ||...
%             ~strcmp(settings(flag).state.spcRangeHigh.string, previousState.spcRangeHigh.string)
%         FV_calcMPETMap(handles); % recalc MPET map, but leave replot outside of loadsettings.
%     end
% end

% 
% try
% %     if exist('C:\MATLAB6p5\work\haining\h_imstack2\h_imstack2Default.mat')==2
%         load('h_imstack3Default.mat');
% %     elseif exist('C:\MATLAB6p5p2\work\haining\h_imstack2\h_imstack2Default.mat')==2
% %         load('C:\MATLAB6p5p2\work\haining\h_imstack2\h_imstack2Default.mat');
% %     end
%     
% %     ss_setPara(handles.h_imstack3,Default);
%     %try this
%     state = Default.state;
%     stateFieldNames = fieldnames(rmfield(Default,'state'));
%     for i = 1:length(stateFieldNames)
%         state.(stateFieldNames{i}) = Default.(stateFieldNames{i});
%     end
%     
% %     currentStruct.state = Default.state;
%     h_img3.(currentStructName).state = state;
%     h_setParaAccordingToState3(handles);
% catch
%     currentStruct.state.lockROI.value = 0; %get(handles.lockROI, 'Value');
%     currentStruct.state.roiShapeOpt.value = 1; %get(handles.roiShapeOpt,'Value');
%     currentStruct.state.analysisNumber.value = 1; %get(handles.analysisNumber,'Value');
%     currentStruct.state.channelForZ.value = 1; %get(handles.channelForZ,'Value');
%     h_img3.(['I', num2str(currentInd)]) = currentStruct;
% end
% 
% try
    if isfield(currentStruct.image,'data')
        [xlim,ylim,zlim] = h_getLimits3(handles);
        set(handles.zStackStrLow,'String', num2str(zlim(1)));
        set(handles.zStackStrHigh,'String', num2str(zlim(2)));
        h_zStackQuality3(handles);
        h_cLimitQuality3(handles);
        set(handles.imageAxes,'XLim',xlim,'YLim',ylim);
        h_replot3(handles);
        h_roiQuality3(handles);
        h_updateInfo3(handles);
    end
% end