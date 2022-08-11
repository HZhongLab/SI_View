function varargout = jbm_dendriteSkeletonGUI3(varargin)
% JBM_DENDRITESKELETONGUI3 M-file for jbm_dendriteSkeletonGUI3.fig
%      JBM_DENDRITESKELETONGUI3, by itself, creates a new JBM_DENDRITESKELETONGUI3 or raises the existing
%      singleton*.
%
%      H = JBM_DENDRITESKELETONGUI3 returns the handle to a new JBM_DENDRITESKELETONGUI3 or the handle to
%      the existing singleton*.
%
%      JBM_DENDRITESKELETONGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JBM_DENDRITESKELETONGUI3.M with the given input arguments.
%
%      JBM_DENDRITESKELETONGUI3('Property','Value',...) creates a new JBM_DENDRITESKELETONGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_roiControlGUI2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jbm_dendriteSkeletonGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jbm_dendriteSkeletonGUI3

% Last Modified by GUIDE v2.5 24-Mar-2016 12:52:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jbm_dendriteSkeletonGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @jbm_dendriteSkeletonGUI3_OutputFcn, ...
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


% --- Executes just before jbm_dendriteSkeletonGUI3 is made visible.
function jbm_dendriteSkeletonGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jbm_dendriteSkeletonGUI3 (see VARARGIN)

% Choose default command line output for hf_spineAnalysisGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes jbm_dendriteSkeletonGUI3 wait for user response (see UIRESUME)
% uiwait(handles.dendriteSkeletonGUI);
global jbm;
if isstruct(jbm)
    if isfield(jbm,'instancesOpen')
        %
    else 
        disp('error: please load a .syn file first')
    end
else
    disp('error: please load a .syn file first')
end


% --- Outputs from this function are returned to the command line.
function varargout = jbm_dendriteSkeletonGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function dendriteSkeletonGUI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dendriteSkeletonGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called








% --- Executes on button press in enterTraceMode.
function enterTraceMode_Callback(hObject, eventdata, handles)
% hObject    handle to enterTraceMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA
jbm_synapsescoringengine('enter skeleton trace mode',handles);


% --- Executes during object creation, after setting all properties.
function dendriteLengthTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dendriteLengthTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global jbm;
numTP = length(jbm.instancesOpen);
data = cell(1,numTP);
set(hObject,'data',data,'rowName','L.')



% --- Executes on button press in pushbutton53.
function pushbutton53_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jbm_synapsescoringengine('exit skeleton trace mode',handles);


% --- Executes on button press in markSkeleton.
function markSkeleton_Callback(hObject, eventdata, handles)
% hObject    handle to markSkeleton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h_makeTracingMark3(handles);


% --- Executes on button press in traceSkeleton.
function traceSkeleton_Callback(hObject, eventdata, handles)
% hObject    handle to traceSkeleton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h_img3;  
global jbm;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);
h_img3.(currentStructName).lastAnalysis.tracingData = h_tracingByMarks3(handles);

tracingData = h_img3.(currentStructName).lastAnalysis.tracingData;
jbm.scoringData.skeleton.lastAnalysis = tracingData;


% --- Executes on button press in finalizeSkeleton.
function finalizeSkeleton_Callback(hObject, eventdata, handles)
% hObject    handle to finalizeSkeleton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm;
numTP = length(jbm.instancesOpen);

currentInstance = h_getCurrendInd3(handles);

if isfield(jbm.scoringData.skeleton,'tracingData')
    %
else
    jbm.scoringData.skeleton.tracingData = cell(1,numTP);
end

if isfield(jbm.scoringData.skeleton,'skeletonLengths')
    %
else
    jbm.scoringData.skeleton.skeletonLengths = zeros(1,numTP)
end

jbm.scoringData.skeleton.tracingData{currentInstance} = jbm.scoringData.skeleton.lastAnalysis;
jbm.scoringData.skeleton.skeletonLengths(currentInstance) = max(jbm.scoringData.skeleton.tracingData{currentInstance}.skeletonInMicron(:,4));

jbm_synapsescoringengine('update info', handles);


