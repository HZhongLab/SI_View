function varargout = jbm_fiducialFinderGUI3(varargin)
% JBM_FIDUCIALFINDERGUI3 M-file for jbm_fiducialFinderGUI3.fig
%      JBM_FIDUCIALFINDERGUI3, by itself, creates a new JBM_FIDUCIALFINDERGUI3 or raises the existing
%      singleton*.
%
%      H = JBM_FIDUCIALFINDERGUI3 returns the handle to a new JBM_FIDUCIALFINDERGUI3 or the handle to
%      the existing singleton*.
%
%      JBM_FIDUCIALFINDERGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JBM_FIDUCIALFINDERGUI3.M with the given input arguments.
%
%      JBM_FIDUCIALFINDERGUI3('Property','Value',...) creates a new JBM_FIDUCIALFINDERGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_roiControlGUI2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jbm_fiducialFinderGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jbm_fiducialFinderGUI3

% Last Modified by GUIDE v2.5 28-Aug-2015 14:20:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jbm_fiducialFinderGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @jbm_fiducialFinderGUI3_OutputFcn, ...
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


% --- Executes just before jbm_fiducialFinderGUI3 is made visible.
function jbm_fiducialFinderGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jbm_fiducialFinderGUI3 (see VARARGIN)

% Choose default command line output for hf_spineAnalysisGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jbm_fiducialFinderGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jbm_fiducialFinderGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in jbmginput.
function jbmginput_Callback(hObject, eventdata, handles)
% hObject    handle to jbmginput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gca;
[x,y] = ginput(1);
global h_img3;
[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
h_img3.(currentStructName).jbm.xco = x;
h_img3.(currentStructName).jbm.yco = y;
h_updateInfo3(handles);
