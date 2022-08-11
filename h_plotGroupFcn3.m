function grpData = h_plotGroupFcn3(handles)

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
        
grpPlotParameters = h_getGrpPlotParameters3(handles);
if grpPlotParameters.holdGrpPlot
    hold on;
else
    hold off;
end


for i = 1:length(currentStruct.activeGroup.groupFiles)
    filename = currentStruct.activeGroup.groupFiles(i).fname;
    [pname, fname, fExt] = fileparts(filename);% fname -s filename without extention.
    
    pathname = fullfile(currentStruct.activeGroup.groupPath, currentStruct.activeGroup.groupFiles(i).relativePath);
    if ~exist(pathname, 'dir') % if relative path does not work, try absolute path
        pathname = currentStruct.activeGroup.groupFiles(i).path;
    end
    
    analysisNumber = currentStruct.state.analysisNumber.value;

    dataFilename = fullfile(pathname,'Analysis',[fname,'_V3roi_A',num2str(analysisNumber),'.mat']);
    if exist(dataFilename, 'file')
        try
            data = load(dataFilename);
            grpData(i) = data.Aout; % note: using cell is not good. cause error for calculating time.
        catch
            error(['Error in loading file: ', dataFilename]); % add this to help identifying problems if happening.
        end
    else
        error(['File not found: ', dataFilename]);
    end
end

try % in the past, often error here. 
    time = datenum({grpData.timestr})*24*60; % need to check whether this is possible.
catch
	error(['Timestr error: ', dataFilename]);
end

time = time - min(time);
time = time - time(grpPlotParameters.baselinePos(end)); % note this is position in the groupfile, not the file number.

grpPlotDataOpt = get(handles.grpPlotDataOpt,'Value');

roiGrp = grpPlotParameters.roiGrp;
% roiVol = [grpData.roiVol];
% roiVolTotal = vertcat(roiVol.total); % currently dimension 1 is diff files, dimension 2 is diff ROIs.

for ii = 1:length(roiGrp)
    if ischar(roiGrp{ii}) && strcmpi(roiGrp{ii}, 'all')
        currentROIInd = grpData(1).roiNumber;
    else
        currentROIInd = find(ismember(grpData(1).roiNumber, roiGrp{ii}));
    end
    if ii>1
        hold on
    end

    switch grpPlotDataOpt
        case {1} % t vs G/R ratio
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough)...
                ./vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('G/R Ratio');
            title(h_showunderscore(['G/R ratio for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['G/R ratio for ',currentStruct.activeGroup.groupName]);
        case {2} % t vs avg green
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough);
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Averaged Green Intensity (A.U.)');
            title(h_showunderscore(['averaged green intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['averaged green intensity for ',currentStruct.activeGroup.groupName]);
        case {3} % t vs avg red
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Averaged Red Intensity (A.U.)');
            title(h_showunderscore(['averaged red intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['averaged red intensity for ',currentStruct.activeGroup.groupName]);
        case {4} % t vs int. green
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough);
            ydata = ydata .* vertcat(grpData.roiVol);
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Integrated Green Intensity (A.U.)');
            title(h_showunderscore(['Integrated green intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Integrated green intensity for ',currentStruct.activeGroup.groupName]);
        case {5} % t vs int. red
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = vertcat(avg_intensity.red);
            ydata = ydata .* vertcat(grpData.roiVol);
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Integrated Red Intensity (A.U.)');
            title(h_showunderscore(['Integrated red intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Integrated red intensity for ',currentStruct.activeGroup.groupName]);
        case {6} % t vs norm G/R ratio
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough)...
                ./vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = (ydata - repmat(baselineYData, [size(ydata, 1), 1]))./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized G/R Ratio');
            title(h_showunderscore(['Normalized G/R ratio for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized G/R ratio for ',currentStruct.activeGroup.groupName]);
        case {7} % t vs norm green
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = (ydata - repmat(baselineYData, [size(ydata, 1), 1]))./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized Green Intensity (A.U.)');
            title(h_showunderscore(['Normalized green intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized green intensity for ',currentStruct.activeGroup.groupName]);
        case {8} % t vs avg red
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = (ydata - repmat(baselineYData, [size(ydata, 1), 1]))./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized Red Intensity (A.U.)');
            title(h_showunderscore(['Normalized red intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized red intensity for ',currentStruct.activeGroup.groupName]);
        case 9 % z
            ydata = zeros(length(grpData), length(grpData(1).roiNumber));%ROI #0 is not in allROIInfo.ROI.
            for i = 1:length(grpData)
                for j = 1:length(grpData(i).roiNumber)
                    ydata(i, j) = mean(grpData(i).roi(j).z);
                end
            end
            ydata = ydata(:,currentROIInd);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('depth (secton #)');
            title(h_showunderscore(['depth (secton #) for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['depth (secton #) for ',currentStruct.activeGroup.groupName]);  
        case {10} % t vs Ratio/Ratio0 (G/R)
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough)...
                ./vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = ydata./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized G/R Ratio');
            title(h_showunderscore(['Normalized G/R ratio for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized G/R ratio for ',currentStruct.activeGroup.groupName]);
        case {11} % t vs Green/Green0
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = ydata ./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized Green Intensity (A.U.)');
            title(h_showunderscore(['Normalized green intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized green intensity for ',currentStruct.activeGroup.groupName]);
        case {12} % t vs Red/Red0
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = vertcat(avg_intensity.red);
            ydata = ydata(:,currentROIInd);
            baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
            ydata = ydata ./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('Normalized Red Intensity (A.U.)');
            title(h_showunderscore(['Normalized red intensity for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['Normalized red intensity for ',currentStruct.activeGroup.groupName]);    
        case 13 % SEI
            avg_intensity = vertcat(grpData.avg_intensity);
            ydata = (vertcat(avg_intensity.green)-vertcat(avg_intensity.red)*grpPlotParameters.bleedthrough)...
                ./vertcat(avg_intensity.red);
            currentROIInd = currentROIInd(logical(mod(currentROIInd,2))); % this should keep only the odd number
            ydata = log2(ydata(:,currentROIInd) ./ ydata(:,currentROIInd+1));
%             baselineYData = mean(ydata(grpPlotParameters.baselinePos, :), 1);
%             ydata = (ydata - repmat(baselineYData, [size(ydata, 1), 1]))./repmat(baselineYData, [size(ydata, 1), 1]);
            h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters);
            xlabel('Time (min)');
            ylabel('SEI');
            title(h_showunderscore(['SEI for ',currentStruct.activeGroup.groupName]));
            set(fig,'Name',['SEI for ',currentStruct.activeGroup.groupName]);
        otherwise
            disp('Plot has not been set up for this option!');

    end

%     h_copy(horzcat(time, ydata)');%copy is now done in FV_plotGroupFcn_plot.

    LineData.activeGroup = currentStruct.activeGroup;
    LineData.timeLastClick = clock;
    LineData.parentGUIFigureHandle = handles.h_imstack3;
    set(h,'UserData',LineData);

    if length(time)>1 % for adding a label for each trace
        x = time(1) + (time(end) - time(1))*1.02;
    else
        x = time(1) * 1.02;
    end
    if grpPlotParameters.grpPlotAvgOpt>1
        y = mean(ydata(end,:));
        text(x,y,['avg#',num2str(grpData(1).roiNumber(currentROIInd))]);
    else
        for i = 1:length(currentROIInd)
            y = ydata(end,i);
            text(x,y,num2str(grpData(1).roiNumber(currentROIInd(i))));
        end
    end
end

hold off;

% % to add activity plot
% if currentStruct.state.AST_plotOpt.value==4 && isfield(currentStruct,'associatedData')
%     % first set the plot axes smaller.
%     plotAxes = findobj(fig, 'Type', 'Axes'); %These also need to be set earlier otherwise not knowing which axes to plot.
%     % find plotAxes again as for a new figure, there was not plotAxes.
% %     activityAxes = findobj(fig, 'Type', 'Axes', 'Tag', 'activityAxes');
%     if ~isempty(activityAxes)
%         plotAxes(plotAxes==activityAxes) = [];
%     else
%         pos = get(plotAxes, 'Position');
%         newPos = pos;
%         newPos(4) = pos(4)*0.55;
%         newPos(2) = pos(2)+pos(4)-newPos(4);
%         set(plotAxes, 'position', newPos);
%         
%         newPos2 = pos;
%         newPos2(4) = pos(4)*0.25;
%         activityAxes = axes('Position', newPos2, 'Tag', 'activityAxes');
%     end
%     
%     activityData = currentStruct.associatedData.animalState;
%     
%     t0 = datenum(grpData(1).timestr);
%     time = (activityData.absDateNum - t0)*24*60;
%     plot(activityAxes, time, activityData.activity);
%     title(['t0 = ', datestr(activityData.absDateNum(1))]);
%     xLim = get(plotAxes, 'XLim');
%     set(activityAxes, 'XLim', xLim);
%     xlabel(activityAxes, 'Time (min)');
%     set(activityAxes, 'Tag', 'activityAxes');
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = h_plotGroupFcn_plot3(time,ydata, grpPlotParameters)


switch grpPlotParameters.grpPlotAvgOpt
    case 1
        if strcmpi(grpPlotParameters.colorStr, 'auto')
            h = plot(time, ydata, grpPlotParameters.styleStr);
        else
            h = plot(time, ydata, grpPlotParameters.styleStr, 'color', grpPlotParameters.colorStr);
        end
%         h_copy(ydata, 'horizontal');
        h_copy(ydata, 'vertical');
    case 2
        if strcmpi(grpPlotParameters.colorStr, 'auto')
             h = plot(time, mean(ydata,2), grpPlotParameters.styleStr);
        else
            h = plot(time, mean(ydata,2), grpPlotParameters.styleStr, 'color', grpPlotParameters.colorStr);
        end
        h_copy(mean(ydata,2), 'horizontal');
    case 3
        if strcmpi(grpPlotParameters.colorStr, 'auto')
            h = errorbar(time, mean(ydata,2),std(ydata,0,2), grpPlotParameters.styleStr);
        else
            h = errorbar(time, mean(ydata,2),std(ydata,0,2), grpPlotParameters.styleStr, 'color', grpPlotParameters.colorStr);
        end
        h_copy(horzcat(mean(ydata,2),std(ydata,0,2)), 'horizontal');
    case 4
        if strcmpi(grpPlotParameters.colorStr, 'auto')
            h = errorbar(time, mean(ydata,2),std(ydata,0,2)/sqrt(size(ydata,2)), grpPlotParameters.styleStr);
        else
            h = errorbar(time, mean(ydata,2),std(ydata,0,2)/sqrt(size(ydata,2)), grpPlotParameters.styleStr,...
                'color', grpPlotParameters.colorStr);
        end
        h_copy(horzcat(mean(ydata,2),std(ydata,0,2)/sqrt(size(ydata,2))), 'horizontal');
end
set(h,'ButtonDownFcn','h_selectLine3');
xlim(grpPlotParameters.xlim);
ylim(grpPlotParameters.ylim);

axesobj = get(h(1),'Parent');
set(axesobj,'ButtonDownFcn','h_unSelectLine3');


function Aout = h_getGrpPlotParameters3(handles)

Aout.holdGrpPlot = get(handles.holdGrpPlot, 'value');

Aout.grpPlotAvgOpt = get(handles.grpPlotAvgOpt, 'value');

baselineStr = get(handles.baselinePos, 'string');
try
    Aout.baselinePos = eval(['[',baselineStr,']']); % note this is position in the groupfile, not the file number.
catch
    Aout.baselinePos = 1; % if not real number, use the first one as baseline.
end

ROIStr = get(handles.grpPlotROIOpt, 'string');

try
    I = strfind(ROIStr,'/');
    I = horzcat(0,I, length(ROIStr)+1);
    for i = 1:length(I)-1
        if ~isempty(strfind(lower(ROIStr(I(i)+1:I(i+1)-1)),'all'))
            Aout.roiGrp{i} = 'all';
        else
            Aout.roiGrp{i} = eval(['[',ROIStr(I(i)+1:I(i+1)-1),']']);
        end
    end
catch
    error(['error in evaluating ROI group str: [',ROIStr(I(i)+1:I(i+1)-1),']'])
end


try
    Aout.xlim = eval(['[', get(handles.xLimSetting, 'string'), ']']);
catch
    Aout.xlim = 'auto';
end

try
    Aout.ylim = eval(['[', get(handles.yLimSetting, 'string'), ']']);
catch
    Aout.ylim = 'auto';
end

grpPlotColorOpt = get(handles.grpPlotColorOpt, 'value'); % this is simpler coding than below.
grpPlotColorStr = get(handles.grpPlotColorOpt, 'String'); % this should be a cell.
if grpPlotColorOpt == 1; % 1 is default, same as 2.
    grpPlotColorOpt = 2;
end
Aout.colorStr = grpPlotColorStr{grpPlotColorOpt};

grpPlotStyleOpt = get(handles.grpPlotStyleOpt, 'value');
grpPlotStyleStr = get(handles.grpPlotStyleOpt, 'String'); % this should be a cell.
if grpPlotStyleOpt == 1; % 1 is default, same as 2.
    grpPlotStyleOpt = 2;
end
Aout.styleStr = grpPlotStyleStr{grpPlotStyleOpt};

bleedStr = get(handles.bleedthroughCorrectionOpt,'string');
bleedValue = get(handles.bleedthroughCorrectionOpt,'value');
bleedStr = bleedStr{bleedValue};
pointer1 = strfind(bleedStr,'%');
if ~isempty(pointer1)
    bleedNumStr = bleedStr(6:pointer1-1);
    Aout.bleedthrough = str2double(bleedNumStr) * 0.01;
else
    Aout.bleedthrough = 0;
end
        
    


