function varargout = jbm_synapseAnalysisGUI3(varargin)
% JBM_SYNAPSEANALYSISGUI3 M-file for jbm_synapseAnalysisGUI3.fig
%      JBM_SYNAPSEANALYSISGUI3, by itself, creates a new JBM_SYNAPSEANALYSISGUI3 or raises the existing
%      singleton*.
%
%      H = JBM_SYNAPSEANALYSISGUI3 returns the handle to a new JBM_SYNAPSEANALYSISGUI3 or the handle to
%      the existing singleton*.
%
%      JBM_SYNAPSEANALYSISGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JBM_SYNAPSEANALYSISGUI3.M with the given input arguments.
%
%      JBM_SYNAPSEANALYSISGUI3('Property','Value',...) creates a new JBM_SYNAPSEANALYSISGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_roiControlGUI2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jbm_synapseAnalysisGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jbm_synapseAnalysisGUI3

% Last Modified by GUIDE v2.5 25-Oct-2015 21:33:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jbm_synapseAnalysisGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @jbm_synapseAnalysisGUI3_OutputFcn, ...
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


% --- Executes just before jbm_synapseAnalysisGUI3 is made visible.
function jbm_synapseAnalysisGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jbm_synapseAnalysisGUI3 (see VARARGIN)

% Choose default command line output for hf_spineAnalysisGUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jbm_synapseAnalysisGUI3 wait for user response (see UIRESUME)
% uiwait(handles.template);


% --- Outputs from this function are returned to the command line.
function varargout = jbm_synapseAnalysisGUI3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function template_CreateFcn(hObject, eventdata, handles)
% hObject    handle to template (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in newsynapse.
function newsynapse_Callback(hObject, eventdata, handles)
% hObject    handle to newsynapse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm
if isfield(jbm,'synapseAnalysis')
    jbm_synapseAnalysisEngine(handles);
else
    warndlg('Please create a data file first')
end


% --- Executes on button press in pass.
function pass_Callback(hObject, eventdata, handles)
% hObject    handle to pass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in undolast.
function undolast_Callback(hObject, eventdata, handles)
% hObject    handle to undolast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm

sz = size(jbm.synapseAnalysis.synapseAnalysisData.dataMatrix);
lth = sz(1);

jbm.synapseAnalysis.synapseAnalysisData.dataMatrix(lth,:) = [];
jbm.synapseAnalysis.synapseAnalysisData.xCoordinates(lth,:) = [];
jbm.synapseAnalysis.synapseAnalysisData.yCoordinates(lth,:) = [];
roihandles = jbm.synapseAnalysis.synapseAnalysisData.roiHandles(lth,:);

roihandles(roihandles==0)=[];
roihandles = unique(roihandles);
delete(roihandles)

jbm.synapseAnalysis.synapseAnalysisData.roiHandles(lth,:) = [];

texthandles = jbm.synapseAnalysis.synapseAnalysisData.text(lth,:);
texthandles(texthandles ==0) = [];
texthandles = unique(texthandles);
delete(texthandles);
jbm.synapseAnalysis.synapseAnalysisData.text(lth,:) = [];
jbm.synapseAnalysis.visNumber = jbm.synapseAnalysis.visNumber - 1;

% --- Executes on button press in initialize.
function initialize_Callback(hObject, eventdata, handles)
% hObject    handle to initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm;
if isfield(jbm,'synapseAnalysis')
    choice = questdlg('Creating a new file will delete any currently loaded data. Are you sure you want to proceed?',...
        'WARNING!!!' ...
        ,'OK', 'No','No');
    switch choice
        case 'OK'
            jbm.synapseAnalysis = [];
            fn = inputdlg('New File Name: ');
            jbm.synapseAnalysis.FileName = fn{1};
        case 'No'
            return
    end
else
jbm.synapseAnalysis = [];
fn = inputdlg('New File Name: ');
jbm.synapseAnalysis.FileName = fn{1};          
end

h_updateInfo3(handles);


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm
synapseAnalysisData = jbm.synapseAnalysis.synapseAnalysisData;
uisave('synapseAnalysisData',jbm.synapseAnalysis.FileName);


% --- Executes on button press in assignin.
function assignin_Callback(hObject, eventdata, handles)
% hObject    handle to assignin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global jbm
synapseAnalysisData = jbm.synapseAnalysis.synapseAnalysisData;
dataMatrix = synapseAnalysisData.dataMatrix;
assignin('base','dataMatrix',dataMatrix);


