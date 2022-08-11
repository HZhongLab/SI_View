function varargout = h_utilityGUI3(varargin)
% H_UTILITYGUI3 MATLAB code for h_utilityGUI3.fig
%      H_UTILITYGUI3, by itself, creates a new H_UTILITYGUI3 or raises the existing
%      singleton*.
%
%      H = H_UTILITYGUI3 returns the handle to a new H_UTILITYGUI3 or the handle to
%      the existing singleton*.
%
%      H_UTILITYGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_UTILITYGUI3.M with the given input arguments.
%
%      H_UTILITYGUI3('Property','Value',...) creates a new H_UTILITYGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_utilityGUI3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_utilityGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_utilityGUI3

% Last Modified by GUIDE v2.5 13-Jan-2021 15:10:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_utilityGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_utilityGUI3_OutputFcn, ...
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


% --- Executes just before h_utilityGUI3 is made visible.
function h_utilityGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_utilityGUI3 (see VARARGIN)

% Choose default command line output for h_utilityGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_utilityGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = h_utilityGUI3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in runImprofile.
function runImprofile_Callback(hObject, eventdata, handles)
% hObject    handle to runImprofile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;  
[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
improfileOpts = h_getImprofileOpts(handles);
[out.Aout, out.avg_C, out.img] = h_improfile2(improfileOpts.lineWidth);
h_img3.(currentStructName).lastAnalysis.lineProfile = out;
assignin('base','lineProfile',out);

%plot line on image
if ~isempty(improfileOpts.plotOpt)
    axes(handles.imageAxes);
    hold on;
    if ~improfileOpts.holdOnOpt
        delete(findobj(handles.imageAxes, 'Tag', 'lineROI3'));
    end
    xdata = mean(cat(2,out.Aout.x),2);
    ydata = mean(cat(2,out.Aout.y),2);
    plot(xdata, ydata, improfileOpts.plotOpt, 'linewidth', 2, 'Tag', 'lineROI3');
    hold off
end

% --- Executes on selection change in lineWidthOpt.
function lineWidthOpt_Callback(hObject, eventdata, handles)
% hObject    handle to lineWidthOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lineWidthOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lineWidthOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lineWidthOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineWidthOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MEIAnalysis.
function MEIAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to MEIAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;  
[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
h_img3.(currentStructName).lastAnalysis.MEIAnalysis = h_MEIAnalysis3(handles);



% --- Executes on selection change in improfilePlotOpt.
function improfilePlotOpt_Callback(hObject, eventdata, handles)
% hObject    handle to improfilePlotOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns improfilePlotOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from improfilePlotOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function improfilePlotOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to improfilePlotOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in improfileHoldOpt.
function improfileHoldOpt_Callback(hObject, eventdata, handles)
% hObject    handle to improfileHoldOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of improfileHoldOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes on button press in MEIAnalysisLoad.
function MEIAnalysisLoad_Callback(hObject, eventdata, handles)
% hObject    handle to MEIAnalysisLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_loadMEIAnalysis3(handles);
