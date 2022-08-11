function varargout = h_qCamAnalysisGUI3(varargin)
% H_QCAMANALYSISGUI3 M-file for h_qCamAnalysisGUI3.fig
%      H_QCAMANALYSISGUI3, by itself, creates a new H_QCAMANALYSISGUI3 or raises the existing
%      singleton*.
%
%      H = H_QCAMANALYSISGUI3 returns the handle to a new H_QCAMANALYSISGUI3 or the handle to
%      the existing singleton*.
%
%      H_QCAMANALYSISGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_QCAMANALYSISGUI3.M with the given input arguments.
%
%      H_QCAMANALYSISGUI3('Property','Value',...) creates a new H_QCAMANALYSISGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_qCamAnalysisGUI3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_qCamAnalysisGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_qCamAnalysisGUI3

% Last Modified by GUIDE v2.5 14-May-2016 02:17:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_qCamAnalysisGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_qCamAnalysisGUI3_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before h_qCamAnalysisGUI3 is made visible.
function h_qCamAnalysisGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_qCamAnalysisGUI3 (see VARARGIN)

% Choose default command line output for h_qCamAnalysisGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_qCamAnalysisGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = h_qCamAnalysisGUI3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_loadQCamImg3(handles);


% --- Executes on selection change in channelToLoadForQCam.
function channelToLoadForQCam_Callback(hObject, eventdata, handles)
% hObject    handle to channelToLoadForQCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channelToLoadForQCam contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelToLoadForQCam

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

h_img3.(currentStructName).state.channelToLoadForQCam.value = get(hObject,'Value');
% h_setParaAccordingToState3(handles);

% --- Executes during object creation, after setting all properties.
function channelToLoadForQCam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToLoadForQCam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calcQCamAnalysisROI.
function calcQCamAnalysisROI_Callback(hObject, eventdata, handles)
% hObject    handle to calcQCamAnalysisROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3 
[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
h_img3.(currentStructName).lastAnalysis.qCamAnalysis = h_executecalcQCamRoi3(handles);
qCamAnalysis = h_img3.(currentStructName).lastAnalysis.qCamAnalysis
assignin('base','qCamAnalysis',qCamAnalysis);


% --- Executes on button press in plotQCamAnalysis.
function plotQCamAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to plotQCamAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

if isfield(h_img3.(currentStructName), 'lastAnalysis') && isfield(h_img3.(currentStructName).lastAnalysis,'qCamAnalysis')

    Aout = h_img3.(currentStructName).lastAnalysis.qCamAnalysis;
    plotOptStr = get(handles.toBePlotROI, 'string');
    if strcmpi(plotOptStr, 'all')
        ROIs = 1:length(Aout.roi);
    else
        ROIs = eval(['[', plotOptStr, ']']);
    end
    
    cstr = {'red', 'blue', 'green', 'magenta', 'cyan', 'black'};

    figure;
    if currentStruct.state.avgQCamDataPlotOpt.value
        avgDeltaFoverF = mean(Aout.deltaFoverF(:,ROIs),2);
        plot(avgDeltaFoverF);
    else
        hold on
        j = 1;
        for i = ROIs
            h = plot(Aout.deltaFoverF(:,i), 'color', cstr{mod(j, 6)+1});
            UData = Aout.roi(i);
            UData.roiNumber = Aout.roiNumber(i);
            UData.timeLastClick = 0*clock;
            UData.fname = Aout.filename;
            set(h, 'UserData', UData, 'ButtonDownFcn', 'h_doubleClickLoadQCaMImg3');
            j = j + 1;
        end
    end
end



function degreeToBeRotated_Callback(hObject, eventdata, handles)
% hObject    handle to degreeToBeRotated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of degreeToBeRotated as text
%        str2double(get(hObject,'String')) returns contents of degreeToBeRotated as a double


% --- Executes during object creation, after setting all properties.
function degreeToBeRotated_CreateFcn(hObject, eventdata, handles)
% hObject    handle to degreeToBeRotated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in duplicateROI.
function duplicateROI_Callback(hObject, eventdata, handles)
% hObject    handle to duplicateROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

roiObj = findobj(handles.imageAxes,'Tag','ROI3');
selectedRoiObj = findobj(handles.imageAxes,'Tag','ROI3', 'Selected', 'on');
if ~isempty(selectedRoiObj)
    UserData = get(selectedRoiObj,'UserData');
    UserData.roi.xi = UserData.roi.xi + 10;
    UserData.roi.yi = UserData.roi.yi + 10;
    
    hold on;
    h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
    set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'ROI3', 'Color','red', 'EraseMode','xor');
    hold off;
    i = length(findobj(handles.imageAxes,'Tag','ROI3'));
    x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
    y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
    UserData.texthandle = text(x,y,num2str(i),'HorizontalAlignment',...
        'Center','VerticalAlignment','Middle', 'Color','red', 'EraseMode','xor', 'ButtonDownFcn', 'h_dragRoiText3');
    UserData.number = i;
    UserData.ROIhandle = h;
    UserData.timeLastClick = clock;
    set(h,'UserData',UserData);
    set(UserData.texthandle,'UserData',UserData);
else
    disp('No selected ROI');
end


% --- Executes on button press in loadQCamData.
function loadQCamData_Callback(hObject, eventdata, handles)
% hObject    handle to loadQCamData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_loadQCamAnalysis3(handles);


% --- Executes on button press in flipHorizontal.
function flipHorizontal_Callback(hObject, eventdata, handles)
% hObject    handle to flipHorizontal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipHorizontal

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

try
    if length(h_img3.(currentStructName).image.data.size)<4 && h_img3.(currentStructName).image.data.size(3)==1
       
        h_img3.(currentStructName).image.old = h_img3.(currentStructName).image.data;%save the data for undo.
        
        h_img3.(currentStructName).image.data.red = flip(h_img3.(currentStructName).image.data.red,2);
        h_img3.(currentStructName).image.data.green = flip(h_img3.(currentStructName).image.data.green,2);
        h_img3.(currentStructName).image.data.blue = flip(h_img3.(currentStructName).image.data.blue,2);
        
%         [xlim,ylim,zlim] = h_getLimits3(handles);
%         set(handles.imageAxes,'XLim',xlim,'YLim',ylim);
        h_replot3(handles);
    end
catch
    error('error in rotating image!');
end


% --- Executes on button press in copyROIImg.
function copyROIImg_Callback(hObject, eventdata, handles)
% hObject    handle to copyROIImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

selectedRoiObj = findobj(handles.imageAxes,'Tag','ROI3', 'Selected', 'on');
if ~isempty(selectedRoiObj)
    UserData = get(selectedRoiObj,'UserData');
    xInd = round(min(UserData.roi.xi):max(UserData.roi.xi));
    yInd = round(min(UserData.roi.yi):max(UserData.roi.yi));
    [img1, climit] = h_getOldImg3(handles);
    img2 = img1(yInd, xInd, :);
    disp(['Copied ROI size = [',num2str(length(yInd)), ', ', num2str(length(xInd)),']']); 
    h = figure('units', 'pixel', 'position',[100 100 2*length(xInd) 2*length(yInd)]);
    if isempty(climit)
        h_imagesc(img2);%this is an RGB image.
    else
        h_imagesc(img2, climit);
    end
    print('-dbitmap','-noui','-zbuffer',h);%"zbuffer" does not give the partial outline at the edge of images.
    delete(h);
else
    disp('No selected ROI');
end



function qCamFrameNumber_Callback(hObject, eventdata, handles)
% hObject    handle to qCamFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of qCamFrameNumber as text
%        str2double(get(hObject,'String')) returns contents of qCamFrameNumber as a double

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

h_img3.(currentStructName).state.qCamFrameNumber.string = get(hObject,'string');


% --- Executes during object creation, after setting all properties.
function qCamFrameNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qCamFrameNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toBePlotROI_Callback(hObject, eventdata, handles)
% hObject    handle to toBePlotROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toBePlotROI as text
%        str2double(get(hObject,'String')) returns contents of toBePlotROI as a double

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

h_img3.(currentStructName).state.toBePlotROI.string = get(hObject,'string');


% --- Executes during object creation, after setting all properties.
function toBePlotROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toBePlotROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in avgQCamDataPlotOpt.
function avgQCamDataPlotOpt_Callback(hObject, eventdata, handles)
% hObject    handle to avgQCamDataPlotOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avgQCamDataPlotOpt

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

h_img3.(currentStructName).state.avgQCamDataPlotOpt.value = get(hObject,'value');
