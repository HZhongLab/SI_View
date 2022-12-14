function varargout = jbm_skeletonGUI3(varargin)
% JBM_SKELETONGUI3 MATLAB code for jbm_skeletonGUI3.fig
%      JBM_SKELETONGUI3, by itself, creates a new JBM_SKELETONGUI3 or raises the existing
%      singleton*.
%
%      H = JBM_SKELETONGUI3 returns the handle to a new JBM_SKELETONGUI3 or the handle to
%      the existing singleton*.
%
%      JBM_SKELETONGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JBM_SKELETONGUI3.M with the given input arguments.
%
%      JBM_SKELETONGUI3('Property','Value',...) creates a new JBM_SKELETONGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jbm_skeletonGUI3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jbm_skeletonGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jbm_skeletonGUI3

% Last Modified by GUIDE v2.5 24-Mar-2016 09:57:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jbm_skeletonGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @jbm_skeletonGUI3_OutputFcn, ...
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


% --- Executes just before jbm_skeletonGUI3 is made visible.
function jbm_skeletonGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jbm_skeletonGUI3 (see VARARGIN)

% Choose default command line output for jbm_skeletonGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jbm_skeletonGUI3 wait for user response (see UIRESUME)
% uiwait(handles.skeletonGUI3);
global jbm;

if isstruct(jbm)
    if isfield(jbm,'instancesOpen')
       %
    else
        close(handles.skeletonGUI3);
    end
    
else
    close(handles.skeletonGUI3);
   
end

% --- Outputs from this function are returned to the command line.
function varargout = jbm_skeletonGUI3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in markup.
function markup_Callback(hObject, eventdata, handles)
% hObject    handle to markup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of markup


% --- Executes during object creation, after setting all properties.
function skeletonTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to skeletonTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global jbm;
numInstances = length(jbm.instancesOpen);
data = cell(1,numInstances);
set(hObject,'data',data);

set(hObject,'rowName','Length');
