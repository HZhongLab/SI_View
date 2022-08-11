function varargout = h_makeMovieGUI3(varargin)
% H_MAKEMOVIEGUI3 M-file for h_makeMovieGUI3.fig
%      H_MAKEMOVIEGUI3, by itself, creates a new H_MAKEMOVIEGUI3 or raises the existing
%      singleton*.
%
%      H = H_MAKEMOVIEGUI3 returns the handle to a new H_MAKEMOVIEGUI3 or the handle to
%      the existing singleton*.
%
%      H_MAKEMOVIEGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_MAKEMOVIEGUI3.M with the given input arguments.
%
%      H_MAKEMOVIEGUI3('Property','Value',...) creates a new H_MAKEMOVIEGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_makeMovieGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_makeMovieGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_makeMovieGUI3

% Last Modified by GUIDE v2.5 11-Feb-2019 17:04:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_makeMovieGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_makeMovieGUI3_OutputFcn, ...
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


% --- Executes just before h_makeMovieGUI3 is made visible.
function h_makeMovieGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_makeMovieGUI3 (see VARARGIN)

% Choose default command line output for h_makeMovieGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_makeMovieGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = h_makeMovieGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function movieContentOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movieContentOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in movieContentOpt.
function movieContentOpt_Callback(hObject, eventdata, handles)
% hObject    handle to movieContentOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns movieContentOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from movieContentOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function frameRateOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameRateOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function frameRateOpt_Callback(hObject, eventdata, handles)
% hObject    handle to frameRateOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameRateOpt as text
%        str2double(get(hObject,'String')) returns contents of frameRateOpt as a double

h_genericSettingCallback3(hObject, handles);


% --- Executes on button press in addFrameToMovie.
function addFrameToMovie_Callback(hObject, eventdata, handles)
% hObject    handle to addFrameToMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img
if ~isfield(h_img,'movie')||isempty(h_img.movie.mov)
    h_img.movie.mov = getframe(handles.imageAxes);
else
    h_img.movie.mov(end+1) = getframe(handles.imageAxes);
end

% --- Executes on button press in autoGenerateMovie.
function autoGenerateMovie_Callback(hObject, eventdata, handles)
% hObject    handle to autoGenerateMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_autoMakeMovie3(handles);

% --- Executes during object creation, after setting all properties.
function movieROIOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movieROIOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in movieROIOpt.
function movieROIOpt_Callback(hObject, eventdata, handles)
% hObject    handle to movieROIOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns movieROIOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from movieROIOpt

h_genericSettingCallback3(hObject, handles);

% --- Executes on button press in saveCurrentMovie.
function saveCurrentMovie_Callback(hObject, eventdata, handles)
% hObject    handle to saveCurrentMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

if isfield(currentStruct.state, 'frameRate')
    frameRate = str2double(currentStruct.state.frameRateOpt.string);
else
    frameRate = str2double(get(handles.frameRateOpt, 'string'));
end

[filename, pathname] = uiputfile('*.avi', 'Save Movie as');
obj = VideoWriter(fullfile(pathname, filename));
obj.FrameRate = frameRate;
open(obj);
writeVideo(obj, currentStruct.movie.mov);
close(obj);


% --- Executes on button press in playMovie.
function playMovie_Callback(hObject, eventdata, handles)
% hObject    handle to playMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img

handles = h_img.currentHandles;
fps = str2num(get(handles.frameRateOpt,'String'));
movie(handles.imageAxes,h_img.movie.mov,1,fps);
