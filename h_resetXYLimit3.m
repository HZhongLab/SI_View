function h_resetXYLimit3(handles)

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

fig = findobj('Tag','h_imstack3Plot','Selected','on');
axesobj = findobj(fig,'type','Axes');

xlimStr = get(handles.xLimSetting,'String');
if strcmpi(xlimStr,'auto')
    set(axesobj,'XLimMode','auto');
else
    xlim = eval(['[',xlimStr,']']);
    if length(xlim) == 2
        set(axesobj,'XLim',xlim);
    elseif length(xlim)>2
        set(axesobj,'XTick',xlim)
    end
end

ylimStr = get(handles.yLimSetting,'String');
if strcmpi(ylimStr,'auto')
    set(axesobj,'YLimMode','auto');
else
    ylim = eval(['[',ylimStr,']']);
    if length(ylim) == 2
        set(axesobj,'YLim',ylim);
    elseif length(ylim)>2
        set(axesobj,'YTick',ylim)
    end
end