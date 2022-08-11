function data = h_frameAnalysisPlot3(handles)

% global FV_img

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

fig = findobj('Tag','h_imstack3Plot','Selected','on');
if isempty(fig)
    fig = figure('Tag','h_imstack3Plot','ButtonDownFcn','h_selectCurrentPlot3','Selected','on');
end
fig = fig(1);% just in case there are more than one.
figure(fig);

plotAxes = findobj(fig, 'Type', 'Axes'); 
activityAxes = findobj(fig, 'Type', 'Axes', 'Tag', 'activityAxes');
if ~isempty(plotAxes)
    if ~isempty(activityAxes)
        plotAxes(plotAxes==activityAxes) = [];
    end
    axes(plotAxes);
end

plotParameters = internal_getFrameAnalysisPlotParameters(handles);
if plotParameters.holdPlot
    hold on;
else
    hold off;
end

currentFileName = get(handles.currentFileName, 'String');
[pname, fname, fExt] = fileparts(currentFileName);% fname -s filename without extention.
analysisNumber = currentStruct.state.analysisNumber.value;
dataFilename = fullfile(pname,'Analysis',[fname,'_frameAnalysis3_A',num2str(analysisNumber),'.mat']);

% load data
if exist(dataFilename, 'file')
    data = load(dataFilename);
    data = data.Aout; % note: using cell is not good. cause error for calculating time.
else
    error(['File not found: ', dataFilename]);
end

if strcmpi(plotParameters.baselinePos, 'auto')
    if isfield(data, 'PAInfo') && ~isempty(data.PAInfo)
        plotParameters.baselinePos = 1 : data.PAInfo.z_start-1;
    else
        plotParameters.baselinePos = 1;
        plotParameters.isPAOpt = 0; % force to be zero so no powerbox plot opt. third party data has not power opt.
    end
end

frameNum = data.includedZ - 0.5; % pointing towards the center of the frame.
frameNum = frameNum - frameNum(plotParameters.baselinePos(end)); % note this is position in the groupfile, not the file number.
if isfield(data, 'PAInfo') && ~isempty(data.PAInfo)
    time = frameNum .* data.PAInfo.linesPerFrame * data.PAInfo.msPerLine / 1000;
    % note this time is not correct if it is slice scan not frame scan.
else
    time = frameNum;
end
plotDataOpt = get(handles.frameAnalysisPlotDataOpt,'Value');

if plotParameters.isPAOpt
    overlapWPowerbox = [data.roi.overlapWPowerbox];
    powerboxI = ismember(data.includedZ,data.PAInfo.z_start:data.PAInfo.z_end);
end
    
roiGrp = [];
for i = 1:length(plotParameters.roiGrp)% since the plot do not average, combine all groups.
    if ~ischar(plotParameters.roiGrp{i})
        roiGrp = unique(horzcat(roiGrp, plotParameters.roiGrp{i})); 
    else
        roiGrp = data.ROINumber; % if there is any "all", just include everything.
        break
    end
end
currentROIInd = find(ismember(data.ROINumber, roiGrp));

switch plotDataOpt
    case {1} % mean G
        ydata = data.avg_intensity.green(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Averaged green intensity');
        title(h_showunderscore(['Averaged green intensity for ',fname]));
        set(fig,'Name',['Averaged green intensity for ',fname]);
    case {2} % total G
        ydata = data.integratedIntensity.green(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Integrated green intensity');
        title(h_showunderscore(['Integrated green intensity for ',fname]));
        set(fig,'Name',['Integrated green intensity for ',fname]);
    case {3} % norm. G
        ydata = data.avg_intensity.green(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1);
        maxYData = max(ydata, [], 1);        
        ydata = (ydata-repmat(ref, size(ydata, 1), 1))./repmat(maxYData-ref, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Normalized green intensity');
        title(h_showunderscore(['Normalized green intensity for ',fname]));
        set(fig,'Name',['Normalized green intensity for ',fname]);
    case 4 % deltaG/G
        ydata = data.avg_intensity.green(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1); % sometimes there is only one baseline point...
        ydata = ydata - repmat(ref, size(ydata, 1), 1);
        ydata = ydata ./ repmat(ref, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('deltaG / G');
        title(h_showunderscore(['[deltaG / G] for ',fname]));
        set(fig,'Name',['[deltaG / G] for ',fname]);
        
    case {5} % mean R
        ydata = data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Averaged red intensity');
        title(h_showunderscore(['Averaged red intensity for ',fname]));
        set(fig,'Name',['Averaged red intensity for ',fname]);
    case {6} % total R
        ydata = data.integratedIntensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Integrated red intensity');
        title(h_showunderscore(['Integrated red intensity for ',fname]));
        set(fig,'Name',['Integrated red intensity for ',fname]);
    case {7} % norm. R
        ydata = data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        maxYData = max(ydata, [], 1);        
        ydata = (ydata-repmat(ref, size(ydata, 1), 1))./repmat(maxYData-ref, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Normalized red intensity');
        title(h_showunderscore(['Normalized red intensity for ',fname]));
        set(fig,'Name',['Normalized red intensity for ',fname]);
    case 8 % deltaR/R
        ydata = data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1);
        ydata = ydata - repmat(ref, size(ydata, 1), 1);
        ydata = ydata ./ repmat(ref, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('deltaR / R');
        title(h_showunderscore(['[deltaR / R] for ',fname]));
        set(fig,'Name',['[deltaR / R] for ',fname]);
    case {9} % G/R
        ydata = data.avg_intensity.green(:,currentROIInd) ./ data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('G / R');
        title(h_showunderscore(['Normalized G/R intensity for ',fname]));
        set(fig,'Name',['Normalized G/R intensity for ',fname]);    
    case {10} % norm. G/R
        ydata = data.avg_intensity.green(:,currentROIInd) ./ data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1);
        ydata = ydata./repmat(ref, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Normalized red intensity');
        title(h_showunderscore(['Normalized red intensity for ',fname]));
        set(fig,'Name',['Normalized red intensity for ',fname]);
    case {11} % delta[G/R]/[G/R]
        ydata = data.avg_intensity.green(:,currentROIInd) ./ data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1);
        ydata = ydata./repmat(ref, size(ydata, 1), 1) - 1;
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Normalized red intensity');
        title(h_showunderscore(['Normalized red intensity for ',fname]));
        set(fig,'Name',['Normalized red intensity for ',fname]);
    case {12} % deltaG / R0
        ydata = data.avg_intensity.green(:,currentROIInd);%first dimension are frames, second is ROIs
        if plotParameters.isPAOpt
            ydata(powerboxI, overlapWPowerbox(currentROIInd)) = nan;
        end
        ref = mean(ydata(plotParameters.baselinePos,:), 1);
        ydata = ydata - repmat(ref, size(ydata, 1), 1);
        ydata2 = data.avg_intensity.red(:,currentROIInd);%first dimension are frames, second is ROIs
        ref2 = mean(ydata2(plotParameters.baselinePos,:), 1);
        ydata = ydata ./ repmat(ref2, size(ydata, 1), 1);
        h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters);
        xlabel('Time (s)');
        ylabel('Normalized red intensity');
        title(h_showunderscore(['Normalized red intensity for ',fname]));
        set(fig,'Name',['Normalized red intensity for ',fname]);
    otherwise
        
end

if length(time)>1 % for adding a label for each trace
    x = time(1) + (time(end) - time(1))*1.02;
else
    x = time(1) * 1.02;
end

for i = 1:length(currentROIInd)
    y = ydata(end,i);
    text(x,y,num2str(data(1).ROINumber(currentROIInd(i))));
end

hold off;

% to add activity plot
if isfield(currentStruct,'associatedData') && ismember(currentStruct.state.AST_plotOpt.value, [16, 18, 20, 22]) 
    % first set the plot axes smaller.
    plotAxes = findobj(fig, 'Type', 'Axes'); %These also need to be set earlier otherwise not knowing which axes to plot.
    % find plotAxes again as for a new figure, there was not plotAxes.
    %     activityAxes = findobj(fig, 'Type', 'Axes', 'Tag', 'activityAxes');
    if ~isempty(activityAxes)
        plotAxes(plotAxes==activityAxes) = [];
    else
        pos = get(plotAxes, 'Position');
        newPos = pos;
        newPos(4) = pos(4)*0.55;
        newPos(2) = pos(2)+pos(4)-newPos(4);
        set(plotAxes, 'position', newPos);
        
        newPos2 = pos;
        newPos2(4) = pos(4)*0.25;
        activityAxes = axes('Position', newPos2, 'Tag', 'activityAxes');
    end
        
    activityData = currentStruct.associatedData.animalState;
        
        % first find out the time zero position
%         try
%             baselineStr = currentStruct.state.frameAnalysisBaselineNum.string;
%         catch
%             baselineStr = '1';
%         end
%         try
%             baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
%         catch
%             baselinePos = 1; % if not real number, use the first one as baseline.
%         end
        
%         header = currentStruct.info;
        % this will need modification in the future as may be certain
        % number of frames are averaged before saving:
        lastBaselineFrameNum = data.includedZ(plotParameters.baselinePos(end)); % note this is position in the groupfile, not the file number.
        baselineOffsetInDateNum = header.acq.linesPerFrame * header.acq.msPerLine * (lastBaselineFrameNum-0.5) ...
            / 1000 / 60 / 60 / 24; % convert from ms to date number
        t0 = datenum(header.internal.triggerTimeString) + baselineOffsetInDateNum;
    
    time = (activityData.absDateNum - t0)*24*60;
    
    if ismember(currentStruct.state.AST_plotOpt.value, [16, 18])
        if currentStruct.state.AST_plotOpt.value==16
            toBePlot = 'activity';
        else
            toBePlot = 'rawData';
        end
        
        plot(activityAxes, time*60, activityData.(toBePlot));
    else% integrated activity (AST_plotOpt.value = 20 or 22
        if currentStruct.state.AST_plotOpt.value==20 % 1 point per minute
            ptsPerMin = 1;
        else % 6 point per min
            ptsPerMin = 6;
        end
        
        avgData = zeros(1,ceil((max(time)-min(time))*ptsPerMin));
        time1 = zeros(1,ceil((max(time)-min(time))*ptsPerMin));
        i = 1;
        for t = ceil(min(time)*ptsPerMin)/ptsPerMin:1/ptsPerMin:ceil(max(time)*ptsPerMin)/ptsPerMin
            I = time<t & time>=t-1/ptsPerMin;
            avgData(i) = mean(activityData.activity(I));
            time1(i) = mean(time(I));
            i = i + 1;
        end
        plot(activityAxes, time1*60, avgData);
    end
    
    title(['t0 = ', datestr(activityData.absDateNum(1))]);
    xLim = get(plotAxes, 'XLim');
    set(activityAxes, 'XLim', xLim);
    xlabel(activityAxes, 'Time (min)');
    set(activityAxes, 'Tag', 'activityAxes');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = internal_frameAnalysisPlot_plot(time,ydata, plotParameters)

if strcmpi(plotParameters.colorStr, 'auto')
    h = plot(time, ydata, plotParameters.styleStr);
else
    h = plot(time, ydata, plotParameters.styleStr, 'color', plotParameters.colorStr);
end
h_copy(ydata, 'horizontal');

set(h,'ButtonDownFcn','FV_selectFrameAnalysisPlotLine');
xlim(plotParameters.xlim);
ylim(plotParameters.ylim);

axesobj = get(h(1),'Parent');
set(axesobj,'ButtonDownFcn','FV_unSelectLine');


function para = internal_getFrameAnalysisPlotParameters(handles)

para.holdPlot = get(handles.frameAnalysisHoldPlotOpt, 'value');

para.grpPlotAvgOpt = get(handles.frameAnalysisGrpPlotAvgOpt, 'value'); % this is not need here but keep for frameAnalysisGrpPlot

baselineStr = get(handles.frameAnalysisBaselineNum, 'string');
try
    if strcmpi(baselineStr, 'auto')
        para.baselinePos = 'auto'; % cannot be set here, because there is no PA info yet.
    else
        para.baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
    end
catch
    para.baselinePos = 1; % if not real number, use the first one as baseline.
end

ROIStr = get(handles.frameAnalysisPlotROINum, 'string');

try %plot has no avg. any avg should go through mergeROI. but still keep for frameAnalysisGrpPlot.
    I = strfind(ROIStr,'/');
    I = horzcat(0,I, length(ROIStr)+1);
    for i = 1:length(I)-1
        if ~isempty(strfind(lower(ROIStr(I(i)+1:I(i+1)-1)),'all'))
            para.roiGrp{i} = 'all';
        else
            para.roiGrp{i} = eval(['[',ROIStr(I(i)+1:I(i+1)-1),']']);
        end
    end
catch
    error(['error in evaluating ROI group str: [',ROIStr(I(i)+1:I(i+1)-1),']'])
end


try
    para.xlim = eval(['[', get(handles.frameAnalysisXLimSetting, 'string'), ']']);
catch
    para.xlim = 'auto';
end

try
    para.ylim = eval(['[', get(handles.frameAnalysisYLimSetting, 'string'), ']']);
catch
    para.ylim = 'auto';
end

plotColorOpt = get(handles.frameAnalysisLineColorOpt, 'value'); % this is simpler coding than below.
plotColorStr = get(handles.frameAnalysisLineColorOpt, 'String'); % this should be a cell.
if plotColorOpt == 1; % 1 is default, same as 2.
    plotColorOpt = 2;
end
para.colorStr = plotColorStr{plotColorOpt};


plotStyleOpt = get(handles.frameAnalysisLineStyleOpt, 'value');
plotStyleStr = get(handles.frameAnalysisLineStyleOpt, 'String'); % this should be a cell.
if plotStyleOpt == 1; % 1 is default, same as 2.
    plotStyleOpt = 2;
end
para.styleStr = plotStyleStr{plotStyleOpt};

para.isPAOpt = get(handles.frameAnalysisIsPAOpt, 'value'); % if yes, remove the PA frames.    
        
    


