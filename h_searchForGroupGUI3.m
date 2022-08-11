function varargout = h_searchForGroupGUI3(varargin)
% H_SEARCHFORGROUPGUI3 M-file for h_searchForGroupGUI3.fig
%      H_SEARCHFORGROUPGUI3, by itself, creates a new H_SEARCHFORGROUPGUI3 or raises the existing
%      singleton*.
%
%      H = H_SEARCHFORGROUPGUI3 returns the handle to a new H_SEARCHFORGROUPGUI3 or the handle to
%      the existing singleton*.
%
%      H_SEARCHFORGROUPGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_SEARCHFORGROUPGUI3.M with the given input arguments.
%
%      H_SEARCHFORGROUPGUI3('Property','Value',...) creates a new H_SEARCHFORGROUPGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ss_searchForGroupGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_searchForGroupGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_searchForGroupGUI3

% Last Modified by GUIDE v2.5 20-Dec-2018 19:14:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_searchForGroupGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_searchForGroupGUI3_OutputFcn, ...
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


% --- Executes just before h_searchForGroupGUI3 is made visible.
function h_searchForGroupGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_searchForGroupGUI3 (see VARARGIN)

% Choose default command line output for h_searchForGroupGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_searchForGroupGUI3 wait for user response (see UIRESUME)
% uiwait(handles.h_searchForGroupGUI3);


% --- Outputs from this function are returned to the command line.
function varargout = h_searchForGroupGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function pathName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function pathName_Callback(hObject, eventdata, handles)
% hObject    handle to pathName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathName as text
%        str2double(get(hObject,'String')) returns contents of pathName as a double


% --- Executes during object creation, after setting all properties.
function fileBasename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileBasename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fileBasename_Callback(hObject, eventdata, handles)
% hObject    handle to fileBasename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileBasename as text
%        str2double(get(hObject,'String')) returns contents of fileBasename as a double


% --- Executes during object creation, after setting all properties.
function fileNumbers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fileNumbers_Callback(hObject, eventdata, handles)
% hObject    handle to fileNumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNumbers as text
%        str2double(get(hObject,'String')) returns contents of fileNumbers as a double


% --- Executes during object creation, after setting all properties.
function fileExtensionOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileExtensionOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in fileExtensionOpt.
function fileExtensionOpt_Callback(hObject, eventdata, handles)
% hObject    handle to fileExtensionOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fileExtensionOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileExtensionOpt


% --- Executes on button press in searchAndGroup.
function searchAndGroup_Callback(hObject, eventdata, handles)
% hObject    handle to searchAndGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_searchAndAddToGroup3(handles);


% --- Executes on button press in searchSubdirOpt.
function searchSubdirOpt_Callback(hObject, eventdata, handles)
% hObject    handle to searchSubdirOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of searchSubdirOpt


% --- Executes on button press in uiBrowseDirectory.
function uiBrowseDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to uiBrowseDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

directoryname = uigetdir;
if ~(directoryname == 0)
    set(handles.pathName,'String',directoryname);
end


% --- Executes on button press in cancelSearch.
function cancelSearch_Callback(hObject, eventdata, handles)
% hObject    handle to cancelSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.h_searchForGroupGUI3);


% --- Executes on button press in maxOpt.
function maxOpt_Callback(hObject, eventdata, handles)
% hObject    handle to maxOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of maxOpt


% --- Executes on button press in searchForRemove.
function searchForRemove_Callback(hObject, eventdata, handles)
% hObject    handle to searchForRemove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_searchAndRemoveFromGroup3(handles);

