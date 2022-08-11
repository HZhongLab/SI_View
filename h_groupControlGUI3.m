function varargout = h_groupControlGUI3(varargin)
% H_GROUPCONTROLGUI3 M-file for h_groupControlGUI3.fig
%      H_GROUPCONTROLGUI3, by itself, creates a new H_GROUPCONTROLGUI3 or raises the existing
%      singleton*.
%
%      H = H_GROUPCONTROLGUI3 returns the handle to a new H_GROUPCONTROLGUI3 or the handle to
%      the existing singleton*.
%
%      H_GROUPCONTROLGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_GROUPCONTROLGUI3.M with the given input arguments.
%
%      H_GROUPCONTROLGUI3('Property','Value',...) creates a new H_GROUPCONTROLGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_groupControlGUI2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_groupControlGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_groupControlGUI3

% Last Modified by GUIDE v2.5 16-Mar-2018 17:28:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_groupControlGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_groupControlGUI3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before h_groupControlGUI3 is made visible.
function h_groupControlGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_groupControlGUI3 (see VARARGIN)

% Choose default command line output for h_groupControlGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_groupControlGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = h_groupControlGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in newGroup.
function newGroup_Callback(hObject, eventdata, handles)
% hObject    handle to newGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_newGroup3(handles);


% --- Executes on button press in addToCurrentGroup.
function addToCurrentGroup_Callback(hObject, eventdata, handles)
% hObject    handle to addToCurrentGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentFilename = get(handles.currentFileName,'String');
if isempty(strfind(currentFilename,'currentFileName'))
    h_addToCurrentGroup3(handles, currentFilename);
    h_updateInfo3(handles);
end

% --- Executes on button press in removeFromCurrentGroup.
function removeFromCurrentGroup_Callback(hObject, eventdata, handles)
% hObject    handle to removeFromCurrentGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

currentFilename = get(handles.currentFileName,'String');
h_removeFromCurrentGroup3(handles,currentFilename);
h_updateInfo3(handles);



% --- Executes on button press in mergeWith.
function mergeWith_Callback(hObject, eventdata, handles)
% hObject    handle to mergeWith (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guihandles(hObject);
h_mergeTwoGroups(handles);



% --- Executes on button press in openGroup.
function openGroup_Callback(hObject, eventdata, handles)
% hObject    handle to openGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

d = dir('*.grp');
if isempty(d) && exist(fullfile(pwd, 'Analysis'), 'dir')
    cd Analysis;
    [fname,pname] = uigetfile('*.grp','Select an group file to open');
    cd ..;
else
    [fname,pname] = uigetfile('*.grp','Select an group file to open');
end

h_openGroup3(handles, fullfile(pname, fname));


% --- Executes on button press in loadCurrentImgGroup.
function loadCurrentImgGroup_Callback(hObject, eventdata, handles)
% hObject    handle to loadCurrentImgGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h_img

handles = guihandles(hObject);
h_openGroup(h_img.imgGroupInfo.groupName, h_img.imgGroupInfo.groupPath, handles);


% --- Executes on button press in batchAddToGroup.
function batchAddToGroup_Callback(hObject, eventdata, handles)
% hObject    handle to batchAddToGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % this part is same as the other batch add
% [fname, pname] = uigetfile({'*.tif'}, 'MultiSelect', 'on');
% fname = cellstr(fname);
% 
% if pname~=0 %not cancel
%     for i = 1:length(fname)
%         h_addToCurrentGroup3(handles, fullfile(pname, fname{i}));
%     end
%     h_updateInfo3(handles);
% end

% use an alternative way to add.
[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

h = h_searchForGroupGUI3;
UData.instanceInd = currentInd;
set(h, 'UserData', UData); % to pass the h_imtack3 index to the GUI.

pos = get(handles.h_imstack3, 'Position');
pos2 = get(h,'Position');
pos2(1) = pos(1) + 20;
pos2(2) = pos(2) + pos(4)/2;
set(h,'Position', pos2);

h_handles = guihandles(h);

currentFilename = get(handles.currentFileName,'String');
[pname,fname,fExt] = fileparts(currentFilename);
if isempty(strfind(currentFilename,'currentFileName'))
    set(h_handles.pathName,'String',pname);
    if ~strcmp(fname(end-2:end),'max')
        set(h_handles.fileBasename,'String',fname(1:end-3));
        set(h_handles.maxOpt,'Value',0);
    else
        set(h_handles.fileBasename,'String',fname(1:end-7));
        set(h_handles.maxOpt,'Value',1);
    end
end

% --- Executes on button press in changeGroupPath.
function changeGroupPath_Callback(hObject, eventdata, handles)
% hObject    handle to changeGroupPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h_img

handles = guihandles(hObject);
h = h_changeGroupDatapathGUI;
pos = get(handles.h_imstack, 'Position');
pos2 = get(h,'Position');
pos2(1) = pos(1) + 20;
pos2(2) = pos(2) + pos(4)/2;
set(h,'Position', pos2);

h_handles = guihandles(h);

currentFilename = get(handles.currentFileName,'String');
[pname,fname,fExt] = fileparts(currentFilename);
if isempty(strfind(currentFilename,'currentFileName'))
    set(h_handles.currentPath,'String',pname);
end
if isfield(h_img,'activeGroup')&~isempty(h_img.activeGroup.groupFiles)
    [pname,fname,fExt] = fileparts(h_img.activeGroup.groupFiles(1).name);
    set(h_handles.formerPath,'String',pname);
end


% --- Executes on button press in autoGroup.
function autoGroup_Callback(hObject, eventdata, handles)
% hObject    handle to autoGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_autoGroupByPosition(guihandles(hObject));


% % --- Executes on button press in closeGroup.
% function closeGroup_Callback(hObject, eventdata, handles)
% % hObject    handle to closeGroup (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% global h_img
% 
% h_img.activeGroup.groupName = [];
% h_img.activeGroup.groupPath = [];
% h_img.activeGroup.groupFiles = [];
% h_updateInfo(h_img.currentHandles);




% --- Executes on button press in newGrpPlot.
function newGrpPlot_Callback(hObject, eventdata, handles)
% hObject    handle to newGrpPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fig = figure('Tag','h_imstack3Plot','ButtonDownFcn','h_selectCurrentPlot3');
h_selectCurrentPlot3;


% --- Executes on button press in grpPlot.
function grpPlot_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_plotGroupFcn3(handles);


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in bleedthroughCorrectionOpt.
function bleedthroughCorrectionOpt_Callback(hObject, eventdata, handles)
% hObject    handle to bleedthroughCorrectionOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bleedthroughCorrectionOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bleedthroughCorrectionOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function bleedthroughCorrectionOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bleedthroughCorrectionOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function baselinePos_Callback(hObject, eventdata, handles)
% hObject    handle to baselinePos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselinePos as text
%        str2double(get(hObject,'String')) returns contents of baselinePos as a double

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function baselinePos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselinePos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in grpPlotDataOpt.
function grpPlotDataOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlotDataOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grpPlotDataOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grpPlotDataOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function grpPlotDataOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpPlotDataOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function grpPlotROIOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlotROIOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grpPlotROIOpt as text
%        str2double(get(hObject,'String')) returns contents of grpPlotROIOpt as a double

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function grpPlotROIOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpPlotROIOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in holdGrpPlot.
function holdGrpPlot_Callback(hObject, eventdata, handles)
% hObject    handle to holdGrpPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of holdGrpPlot

h_genericSettingCallback3(hObject, handles);


% --- Executes on selection change in grpPlotAvgOpt.
function grpPlotAvgOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlotAvgOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grpPlotAvgOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grpPlotAvgOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function grpPlotAvgOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpPlotAvgOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function xLimSetting_Callback(hObject, eventdata, handles)
% hObject    handle to xLimSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLimSetting as text
%        str2double(get(hObject,'String')) returns contents of xLimSetting as a double

h_genericSettingCallback3(hObject, handles);
h_resetXYLimit3(handles)


% --- Executes during object creation, after setting all properties.
function xLimSetting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLimSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yLimSetting_Callback(hObject, eventdata, handles)
% hObject    handle to yLimSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLimSetting as text
%        str2double(get(hObject,'String')) returns contents of yLimSetting as a double

h_genericSettingCallback3(hObject, handles);
h_resetXYLimit3(handles)


% --- Executes during object creation, after setting all properties.
function yLimSetting_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLimSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in grpCalc.
function grpCalc_Callback(hObject, eventdata, handles)
% hObject    handle to grpCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_executeGroupCalcRoi3(handles);


% --- Executes on button press in autoPosWhenGrpCalc.
function autoPosWhenGrpCalc_Callback(hObject, eventdata, handles)
% hObject    handle to autoPosWhenGrpCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoPosWhenGrpCalc

h_genericSettingCallback3(hObject, handles);


% --- Executes on selection change in grpCalcOpt.
function grpCalcOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpCalcOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grpCalcOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grpCalcOpt

h_genericSettingCallback3(hObject, handles)


% --- Executes during object creation, after setting all properties.
function grpCalcOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpCalcOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% h_genericSettingCallback3(hObject, handles);



% --- Executes on button press in pauseGroupCalc.
function pauseGroupCalc_Callback(hObject, eventdata, handles)
% hObject    handle to pauseGroupCalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pauseGroupCalc

h_genericSettingCallback3(hObject, handles);
currentValue = get(hObject,'Value');
if currentValue
    uiwait;
else
    uiresume;
end


% --- Executes on selection change in grpPlotColorOpt.
function grpPlotColorOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlotColorOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grpPlotColorOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grpPlotColorOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function grpPlotColorOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpPlotColorOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% h_genericSettingCallback3(hObject, handles);


% --- Executes on selection change in grpPlotStyleOpt.
function grpPlotStyleOpt_Callback(hObject, eventdata, handles)
% hObject    handle to grpPlotStyleOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns grpPlotStyleOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from grpPlotStyleOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function grpPlotStyleOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpPlotStyleOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% h_genericSettingCallback3(hObject, handles);
