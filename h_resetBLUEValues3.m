function h_resetBLUEValues3(handles)

global h_img3

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
    
imageModeValue = get(handles.imageMode, 'value');
if isfield(currentStruct.internal, 'imageModeValue')
    previousImgMode = currentStruct.internal.imageModeValue;
else
    previousImgMode = 0;
end
if imageModeValue~=previousImgMode %if not the same, reset.
    if imageModeValue==8
        climitg(1) = str2num(get(handles.greenLimitStrLow,'String'));
        climitg(2) = str2num(get(handles.greenLimitStrHigh,'String'));
        if climitg(2)==climitg(1)
            climitg(2) = climitg(1)+0.001;%otherwise it will cause error below
        end
        climitr(1) = str2num(get(handles.redLimitStrLow,'String'));
        climitr(2) = str2num(get(handles.redLimitStrHigh,'String'));
        if climitr(2)==climitr(1)
            climitr(2) = climitr(1)+0.001;%otherwise it will cause error below
        end
        ratioImg = (double(currentStruct.image.display.green)-climitg(1))./(double(currentStruct.image.display.red)-climitr(1));
        ratioImg(currentStruct.image.display.red<3*climitr(1)) = nan;
    elseif imageModeValue==9
        climitg(1) = str2num(get(handles.greenLimitStrLow,'String'));
        climitg(2) = str2num(get(handles.greenLimitStrHigh,'String'));
        if climitg(2)==climitg(1)
            climitg(2) = climitg(1)+0.001;%otherwise it will cause error below
        end
        climitr(1) = str2num(get(handles.redLimitStrLow,'String'));
        climitr(2) = str2num(get(handles.redLimitStrHigh,'String'));
        if climitr(2)==climitr(1)
            climitr(2) = climitr(1)+0.001;%otherwise it will cause error below
        end
        ratioImg = (double(currentStruct.image.display.red)-climitr(1))./(double(currentStruct.image.display.green)-climitg(1));
        ratioImg(currentStruct.image.display.red<3*climitr(1)) = nan;
    else
        ratioImg = currentStruct.image.display.blue;
    end
    climit = h_climit(ratioImg, 0.1, 0.9);
    set(handles.blueLimitStrLow, 'String', num2str(climit(1)));
    set(handles.blueLimitStrHigh, 'String', num2str(climit(2)));
    h_cLimitQuality3(handles);
end
h_img3.(currentStructName).internal.imageModeValue = imageModeValue;