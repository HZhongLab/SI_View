function h_genericSettingCallback3(hObject, handles)

% this function try to setting the state variable for various fields so
% that coding is simplified.
% At some places, FV_settingQuality or FV_updateStateVar is used instead for enhanced
% functionalities.

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

objName = get(hObject, 'Tag');
objType = get(hObject, 'Style');

switch objType
    case {'popupmenu', 'radiobutton', 'checkbox'}
        currentValue = get(hObject,'Value');
        h_img3.(currentStructName).state.(objName).value = currentValue;

    case 'togglebutton'
        currentValue = get(hObject,'Value');
        if currentValue % toggle button color need to be changed.
            set(handles.(objName),'Value',currentValue,'BackgroundColor',[0.8 0.8 0.8]);
        else
            set(handles.(objName),'Value',currentValue,'BackgroundColor',[ 0.9255    0.9137    0.8471]);
        end
        
        h_img3.(currentStructName).state.(objName).value = currentValue;
        h_img3.(currentStructName).state.(objName).BackgroundColor = get(hObject,'BackgroundColor');%this is necessary for all toggle bottons.

    case 'edit'
        h_img3.(currentStructName).state.(objName).string = get(hObject, 'String');
    otherwise
end

if numel(handles.(objName))>1 % if there are multiple fields with same name
    h_setParaAccordingToState3(handles);%this need to be add if there are multiple fields.
end
% h_updateInfo3(handles);