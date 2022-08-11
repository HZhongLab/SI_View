function varargout = h_animalStateTrackerGUI3(varargin)
% H_ANIMALSTATETRACKERGUI3 MATLAB code for h_animalStateTrackerGUI3.fig
%      H_ANIMALSTATETRACKERGUI3, by itself, creates a new H_ANIMALSTATETRACKERGUI3 or raises the existing
%      singleton*.
%
%      H = H_ANIMALSTATETRACKERGUI3 returns the handle to a new H_ANIMALSTATETRACKERGUI3 or the handle to
%      the existing singleton*.
%
%      H_ANIMALSTATETRACKERGUI3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in H_ANIMALSTATETRACKERGUI3.M with the given input arguments.
%
%      H_ANIMALSTATETRACKERGUI3('Property','Value',...) creates a new H_ANIMALSTATETRACKERGUI3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before h_animalStateTrackerGUI3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to h_animalStateTrackerGUI3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help h_animalStateTrackerGUI3

% Last Modified by GUIDE v2.5 10-Jan-2019 16:38:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @h_animalStateTrackerGUI3_OpeningFcn, ...
                   'gui_OutputFcn',  @h_animalStateTrackerGUI3_OutputFcn, ...
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


% --- Executes just before h_animalStateTrackerGUI3 is made visible.
function h_animalStateTrackerGUI3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to h_animalStateTrackerGUI3 (see VARARGIN)

% Choose default command line output for h_animalStateTrackerGUI3
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes h_animalStateTrackerGUI3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = h_animalStateTrackerGUI3_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in AST_loadData.
function AST_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to AST_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

[fname,pname] = uigetfile('*.dat*','Select a data file to open');
if ~(pname == 0)
    data = h_AST_readData(fullfile(pname,fname));
else
    return;
end

animalState.absDateNum = data(1,:);
animalState.relativeTimeInMin = (data(1,:) - data(1,1))*24*60;
animalState.activity = data(2,:);
if size(data,1)>2
    animalState.rawData = data(3,:);
else
    animalState.rawData = zeros(size(animalState.activity));
end
animalState.filename = fullfile(fullfile(pname,fname));

h_img3.(currentStructName).associatedData.animalState = animalState;

set(handles.AST_fileName, 'String', animalState.filename);
h_img3.(currentStructName).state.AST_fileName.string = animalState.filename;


% --- Executes on button press in AST_reload.
function AST_reload_Callback(hObject, eventdata, handles)
% hObject    handle to AST_reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

fileName = get(handles.AST_fileName, 'String');

data = h_AST_readData(fileName);

animalState.absDateNum = data(1,:);
animalState.relativeTimeInMin = (data(1,:) - data(1,1))*24*60;
animalState.activity = data(2,:);% make it general as it can be other activity as well.
if size(data,1)>2
    animalState.rawData = data(3,:);
else
    animalState.rawData = zeros(size(animalState.activity));
end
animalState.filename = fileName;

h_img3.(currentStructName).associatedData.animalState = animalState;



% --- Executes on button press in AST_plotData.
function AST_plotData_Callback(hObject, eventdata, handles)
% hObject    handle to AST_plotData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

data = h_img3.(currentStructName).associatedData.animalState;

try
    plotOpt = currentStruct.state.AST_plotOpt.value;
catch
    plotOpt = 1;
end

if ismember(plotOpt, [1 2 3 4 8:16 19:22])
    toBePlot = 'activity';
else
    toBePlot = 'rawData';
end

switch(plotOpt)
    case {1, 2, 5} % new window, plot all
        figure(4333), plot(data.relativeTimeInMin, data.(toBePlot));
        xlabel('Time (min)');
        title(['t0 = ', datestr(data.absDateNum(1))]);
    case {3, 6} % new window, but use plotGroup time.
        % first find out the time zero position
        baselineStr = currentStruct.state.baselinePos.string;
        try
            baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
        catch
            baselinePos = 1; % if not real number, use the first one as baseline.
        end
        
        %find out the time of the first file in group.
        filename = currentStruct.activeGroup.groupFiles(baselinePos(end)).fname;
        [pname, fname, fExt] = fileparts(filename);% fname is filename without extention.        
        pathname = fullfile(currentStruct.activeGroup.groupPath, currentStruct.activeGroup.groupFiles(baselinePos(end)).relativePath);
        if ~exist(pathname, 'dir') % if relative path does not work, try absolute path
            pathname = currentStruct.activeGroup.groupFiles(1).path;
        end
        imgFileName = fullfile(pathname,[fname,fExt]);
        finfo = imfinfo (imgFileName);
        header = finfo(1).ImageDescription;
        evalc(header); % this create a variable called spc.
        
        % need to offset the time zero by half of image duration and by the time zero position
        fileInfo = h_dir(imgFileName);
        imgDurationEst = datenum(fileInfo.date) - datenum(spc.datainfo.triggerTime); % fileInfo.date should be close to end of image acq.
        if imgDurationEst*24*60 > 10 %set an arbiturary thresh that each image cannot be more than 10 min
            imgDurationEst = 0;
        end
        
        t0 = datenum(spc.datainfo.triggerTime) + imgDurationEst/2;
        %     t0 = datenum(spc.datainfo.triggerTime);
        
        time = (data.absDateNum - t0)*24*60;    
        figure(4333), plot(time, data.(toBePlot));
        xlabel('Time (min)');
        title(['t0 = ', datestr(data.absDateNum(1))]);
    case {4, 7, 10, 13}
%         h_plotGroupFcn3(handles);
disp('need work!');
    case {8, 11} % avg activity per time in new window
        if plotOpt==8
            ptsPerMin = 1;
        else
            ptsPerMin = 6;
        end

        avgData = zeros(1,ceil((max(data.relativeTimeInMin) - min(data.relativeTimeInMin))*ptsPerMin));
        time = zeros(1,ceil((max(data.relativeTimeInMin) - min(data.relativeTimeInMin))*ptsPerMin));
        i = 1;
        for t = ceil(min(data.relativeTimeInMin)*ptsPerMin)/ptsPerMin:1/ptsPerMin:ceil(max(data.relativeTimeInMin)*ptsPerMin)/ptsPerMin
%         for t = ceil(min(data.relativeTimeInMin)/ptsPerMin):1/ptsPerMin:ceil(max(data.relativeTimeInMin)/ptsPerMin)
            I = data.relativeTimeInMin<t & data.relativeTimeInMin>=t-1/ptsPerMin;
            avgData(i) = mean(data.activity(I));
            time(i) = mean(data.relativeTimeInMin(I));
            i = i + 1;
        end
        figure(4333), plot(time, avgData);
        xlabel('Time (min)');
        title(['t0 = ', datestr(data.absDateNum(1))]);  
    case {9, 12} % avg activity per min in new window but using grpPlot time
        if plotOpt==9 % 1 pont per minute
            ptsPerMin = 1;
        else % 6 point per min
            ptsPerMin = 6;
        end
        
        % first find out the time zero position
        baselineStr = currentStruct.state.baselinePos.string;
        try
            baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
        catch
            baselinePos = 1; % if not real number, use the first one as baseline.
        end
        
        %find out the time of the first file in group.
        filename = currentStruct.activeGroup.groupFiles(baselinePos(end)).fname;
        [pname, fname, fExt] = fileparts(filename);% fname is filename without extention.        
        pathname = fullfile(currentStruct.activeGroup.groupPath, currentStruct.activeGroup.groupFiles(baselinePos(end)).relativePath);
        if ~exist(pathname, 'dir') % if relative path does not work, try absolute path
            pathname = currentStruct.activeGroup.groupFiles(1).path;
        end
        imgFileName = fullfile(pathname,[fname,fExt]);
        finfo = imfinfo (imgFileName);
        header = finfo(1).ImageDescription;
        evalc(header); % this create a variable called spc.
        
        % need to offset the time zero by half of image duration and by the time zero position
        fileInfo = h_dir(imgFileName);
        imgDurationEst = datenum(fileInfo.date) - datenum(spc.datainfo.triggerTime); % fileInfo.date should be close to end of image acq.
        if imgDurationEst*24*60 > 10 %set an arbiturary thresh that each image cannot be more than 10 min
            imgDurationEst = 0;
        end
        
        t0 = datenum(spc.datainfo.triggerTime) + imgDurationEst/2;
%         t0 = datenum(spc.datainfo.triggerTime);

        time1 = (data.absDateNum - t0)*24*60;    

        avgData = zeros(1,ceil((max(time1)-min(time1))*ptsPerMin));
        time = zeros(1,ceil((max(time1)-min(time1))*ptsPerMin));
        i = 1;
        for t = ceil(min(time1)*ptsPerMin)/ptsPerMin:1/ptsPerMin:ceil(max(time1)*ptsPerMin)/ptsPerMin
            I = time1<t & time1>=t-1/ptsPerMin;
            avgData(i) = mean(data.activity(I));
            time(i) = mean(time1(I));
            i = i + 1;
        end
        figure(4333), plot(time, avgData);
        xlabel('Time (min)');
        title(['t0 = ', datestr(data.absDateNum(1))]);
    case 14 % "----" do nothing
    case {15, 17} % plot in new window but use frame timing.
        % first find out the time zero position
        try
            baselineStr = currentStruct.state.frameAnalysisBaselineNum.string;
        catch
            baselineStr = '1';
        end
        try
            baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
        catch
            baselinePos = 1; % if not real number, use the first one as baseline.
        end
        
        header = currentStruct.info;
        
        % this will need modification in the future as may be certain
        % number of frames are averaged before saving:
        frameNum = currentStruct.lastAnalysis.frameAnalysis.includedZ;
        lastBaselineFrameNum = frameNum(baselinePos(end)); % note this is position in the groupfile, not the file number.
        baselineOffsetInDateNum = header.acq.linesPerFrame * header.acq.msPerLine * (lastBaselineFrameNum-0.5) ...
            / 1000 / 60 / 60 / 24; % convert from ms to date number
        t0 = datenum(header.internal.triggerTimeString) + baselineOffsetInDateNum;
        %     t0 = datenum(spc.datainfo.triggerTime);
        
        time = (data.absDateNum - t0)*24*60*60;    % in seconds as frame analysis tend to be in seconds.
        figure(4333), plot(time, data.(toBePlot));
        xlabel('Time (s)');
%         title(['t0 = ', datestr(data.absDateNum(1))]);
    case {16, 18, 20, 22} % plot in frame analysis plot window.
        h_frameAnalysisPlot3(handles);
    case {19, 21} % plot avg data in new window but use frame timing.
        if plotOpt==19 % 1 pont per minute % try to use old codes here.
            ptsPerMin = 1;
        else % 6 point per min
            ptsPerMin = 6;
        end
        
        % first find out the time zero position
        try
            baselineStr = currentStruct.state.frameAnalysisBaselineNum.string;
        catch
            baselineStr = '1';
        end
        try
            baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
        catch
            baselinePos = 1; % if not real number, use the first one as baseline.
        end
        
        header = currentStruct.info;
        
        % this will need modification in the future as may be certain
        % number of frames are averaged before saving:
        frameNum = currentStruct.lastAnalysis.frameAnalysis.includedZ;
        lastBaselineFrameNum = frameNum(baselinePos(end)); % note this is position in the groupfile, not the file number.
        baselineOffsetInDateNum = header.acq.linesPerFrame * header.acq.msPerLine * (lastBaselineFrameNum-0.5) ...
            / 1000 / 60 / 60 / 24; % convert from ms to date number
        t0 = datenum(header.internal.triggerTimeString) + baselineOffsetInDateNum;

        time1 = (data.absDateNum - t0)*24*60;    

        avgData = zeros(1,ceil((max(time1)-min(time1))*ptsPerMin));
        time = zeros(1,ceil((max(time1)-min(time1))*ptsPerMin));
        i = 1;
        for t = ceil(min(time1)*ptsPerMin)/ptsPerMin:1/ptsPerMin:ceil(max(time1)*ptsPerMin)/ptsPerMin
            I = time1<t & time1>=t-1/ptsPerMin;
            avgData(i) = mean(data.activity(I));
            time(i) = mean(time1(I));
            i = i + 1;
        end
        figure(4333), plot(time*60, avgData); % time was in min, now convert to seconds
        xlabel('Time (s)');
%         title(['t0 = ', datestr(data.absDateNum(1))]);
    otherwise
end


% --- Executes on selection change in AST_plotOpt.
function AST_plotOpt_Callback(hObject, eventdata, handles)
% hObject    handle to AST_plotOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AST_plotOpt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AST_plotOpt

h_genericSettingCallback3(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AST_plotOpt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AST_plotOpt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
