function h_loadSelectedROISettings3(handles)

% load the selected annotation ROI color and z settings when it was
% created.

selectedROIObj = findobj(handles.imageAxes, 'tag', 'annotationROI3', 'Selected', 'on');

if length(selectedROIObj) == 1
    UData = get(selectedROIObj,'UserData');
    settings = UData.currentSettings;

    set(handles.zStackStrLow, 'string', num2str(settings.zLim(1)));
    set(handles.zStackStrHigh, 'string', num2str(settings.zLim(2)));

    set(handles.redLimitStrLow, 'string', num2str(settings.redLim(1)));
    set(handles.redLimitStrHigh, 'string', num2str(settings.redLim(2)));
    
    set(handles.greenLimitStrLow, 'string', num2str(settings.greenLim(1)));
    set(handles.greenLimitStrHigh, 'string', num2str(settings.greenLim(2)));
    
    set(handles.blueLimitStrLow, 'string', num2str(settings.blueLim(1)));
    set(handles.blueLimitStrHigh, 'string', num2str(settings.blueLim(2)));

    h_cLimitQuality3(handles);
    h_zStackQuality3(handles);
    h_replot3(handles);
end

