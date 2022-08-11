function grpData = h_frameAnalysisGrpPlot3(handles)

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

fig = findobj('Tag','h_imstack3Plot','Selected','on');
if isempty(fig)
    fig = figure('Tag','h_imstack3Plot','ButtonDownFcn','h_selectCurrentPlot3','Selected','on');
end
fig = fig(1);% just in case there are more than one.
figure(fig);

plotAxes = findobj(fig, 'Type', 'Axes');
if ~isempty(plotAxes)
    axes(plotAxes(1));
end
      
plotParameters = internal_getFrameAnalysisPlotParameters(handles);
if plotParameters.holdPlot
    hold on;
else
    hold off;
end

% get all data file from a group.
if ~(isfield(currentStruct, 'activeGroup') && ~isempty(currentStruct.activeGroup.groupFiles))
    grpData = [];
    return;
end

for i = 1:length(currentStruct.activeGroup.groupFiles)
    filename = currentStruct.activeGroup.groupFiles(i).fname;
    [pname, fname, fExt] = fileparts(filename);% fname -s filename without extention.
    
    pathname = fullfile(currentStruct.activeGroup.groupPath, currentStruct.activeGroup.groupFiles(i).relativePath);
    if ~exist(pathname, 'dir') % if relative path does not work, try absolute path
        pathname = currentStruct.activeGroup.groupFiles(i).path;
    end
    
    analysisNumber = currentStruct.state.analysisNumber.value;

    dataFilename = fullfile(pathname,'Analysis',[fname,'_frameAnalysis3_A',num2str(analysisNumber),'.mat']);
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

% note all data have to have the same length. Otherwise there will be
% error.
if strcmpi(plotParameters.baselinePos, 'auto')
    plotParameters.baselinePos = 1: grpData(1).PAInfo.z_start-1;
end

% use the first file in group to set parameters.
frameNum = grpData(1).includedZ - 0.5; % pointing towards the center of the frame.
frameNum = frameNum - frameNum(plotParameters.baselinePos(end)); % note this is position in the groupfile, not the file number.
time = frameNum .* grpData(1).PAInfo.linesPerFrame * grpData(1).PAInfo.msPerLine / 1000;% note this time is not correct if it is slice scan not frame scan.
if plotParameters.isPAOpt
    overlapWPowerbox = [grpData(1).roi.overlapWPowerbox];
    powerboxI = ismember(grpData(1).includedZ,grpData(1).PAInfo.z_start:grpData(1).PAInfo.z_end);
end

roiGrp = plotParameters.roiGrp;

for ii = 1:length(roiGrp) % for frame analysis, should not avg across ROIs, but keep the structure for future if needed.
    if ischar(roiGrp{ii}) && strcmpi(roiGrp{ii}, 'all')
        currentROIInd = grpData(1).ROINumber;
    else
        currentROIInd = find(ismember(grpData(1).ROINumber, roiGrp{ii}));
    end
    if ii>1
        hold on
    end

    switch plotParameters.dataPlotOpt
        case {1} % mean G
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.green); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Averaged green intensity');
            title(h_showunderscore(['Averaged green intensity for ',fname]));
            set(fig,'Name',['Averaged green intensity for ',fname]);
        case {2} % total G
            temp = horzcat(grpData.integratedIntensity);
            ydata = cat(3, temp.green); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Integrated green intensity');
            title(h_showunderscore(['Integrated green intensity for ',fname]));
            set(fig,'Name',['Integrated green intensity for ',fname]);
        case {3} % norm. G
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.green); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:,:), 1);
            maxYData = max(ydata, [], 1);        
            ydata = (ydata-repmat(ref, size(ydata, 1), 1))./repmat(maxYData-ref, size(ydata, 1), 1);
            %ydata = ydata./repmat(ref, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Normalized green intensity');
            title(h_showunderscore(['Normalized green intensity for ',fname]));
            set(fig,'Name',['Normalized green intensity for ',fname]);
        case 4 % deltaG/G
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.green); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1); % sometimes there is only one baseline point...
            ydata = ydata - repmat(ref, size(ydata, 1), 1);
            ydata = ydata ./ repmat(ref, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('deltaG / G');
            title(h_showunderscore(['[deltaG / G] for ',fname]));
            set(fig,'Name',['[deltaG / G] for ',fname]);
            
        case {5} % mean R
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.red); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Averaged red intensity');
            title(h_showunderscore(['Averaged red intensity for ',fname]));
            set(fig,'Name',['Averaged red intensity for ',fname]);
        case {6} % total R
            temp = horzcat(grpData.integratedIntensity);
            ydata = cat(3, temp.red); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Integrated red intensity');
            title(h_showunderscore(['Integrated red intensity for ',fname]));
            set(fig,'Name',['Integrated red intensity for ',fname]);
        case {7} % norm. R
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.red); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1);
            maxYData = max(ydata, [], 1);        
            ydata = (ydata-repmat(ref, size(ydata, 1), 1))./repmat(maxYData-ref, size(ydata, 1), 1);
%             ydata = ydata./repmat(ref, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Normalized red intensity');
            title(h_showunderscore(['Normalized red intensity for ',fname]));
            set(fig,'Name',['Normalized red intensity for ',fname]);
        case 8 % deltaR/R
            temp = horzcat(grpData.avg_intensity);
            ydata = cat(3, temp.red); %first dimension are frames, second is ROIs, third is different files
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1);
            ydata = ydata - repmat(ref, size(ydata, 1), 1);
            ydata = ydata ./ repmat(ref, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('deltaR / R');
            title(h_showunderscore(['[deltaR / R] for ',fname]));
            set(fig,'Name',['[deltaR / R] for ',fname]);
        case {9} % G/R
            temp = horzcat(grpData.avg_intensity);            
            ydata = cat(3, temp.green) ./ cat(3, temp.red); 
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('G / R');
            title(h_showunderscore(['Normalized G/R intensity for ',fname]));
            set(fig,'Name',['Normalized G/R intensity for ',fname]);
        case {10} % norm. G/R
            temp = horzcat(grpData.avg_intensity);            
            ydata = cat(3, temp.green) ./ cat(3, temp.red); 
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1);
            ydata = ydata./repmat(ref, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Normalized red intensity');
            title(h_showunderscore(['Normalized red intensity for ',fname]));
            set(fig,'Name',['Normalized red intensity for ',fname]);
        case {11} % delta[G/R]/[G/R]
            temp = horzcat(grpData.avg_intensity);            
            ydata = cat(3, temp.green) ./ cat(3, temp.red); 
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1);
            ydata = ydata./repmat(ref, size(ydata, 1), 1) - 1;
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Normalized red intensity');
            title(h_showunderscore(['Normalized red intensity for ',fname]));
            set(fig,'Name',['Normalized red intensity for ',fname]);
        case {12} % deltaG / R0
            temp = horzcat(grpData.avg_intensity);            
            ydata = cat(3, temp.green) ./ cat(3, temp.red); 
            ydata = ydata(:,currentROIInd,:);
            if plotParameters.isPAOpt
                ydata(powerboxI, overlapWPowerbox(currentROIInd),:) = nan;
            end
            ref = mean(ydata(plotParameters.baselinePos,:, :), 1);
            ydata = ydata - repmat(ref, size(ydata, 1), 1);
            temp = horzcat(grpData.avg_intensity);
            ydata2 = cat(3, temp.red); %first dimension are frames, second is ROIs, third is different files
            ydata2 = ydata2(:,currentROIInd,:);
            ref2 = mean(ydata2(plotParameters.baselinePos,:, :), 1);
            ydata = ydata ./ repmat(ref2, size(ydata, 1), 1);
            h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters);
            xlabel('Time (s)');
            ylabel('Normalized red intensity');
            title(h_showunderscore(['Normalized red intensity for ',fname]));
            set(fig,'Name',['Normalized red intensity for ',fname]);
            
 
% 
%     if length(time)>1 % for adding a label for each trace
%         x = time(1) + (time(end) - time(1))*1.02;
%     else
%         x = time(1) * 1.02;
%     end
%     if plotParameters.grpPlotAvgOpt>1
%         y = mean(ydata(end,:));
%         text(x,y,['ROI#',num2str(grpData(1).roiNumber(currentROIInd))]);
%     else
%         for i = 1:length(currentROIInd)
%             y = ydata(end,i);
%             text(x,y,num2str(grpData(1).roiNumber(currentROIInd(i))));
%         end
%     end
    end
end

hold off;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = internal_frameAnalysisGrpPlot_plot(time,ydata, plotParameters)

cstr = {'red', 'blue', 'green', 'magenta', 'cyan', 'black'};
switch plotParameters.grpPlotAvgOpt
    case {1, 2}
        for i = 1:size(ydata, 3)
            if i>1
                hold on
            end
            if strcmpi(plotParameters.colorStr, 'auto')
                h = plot(time, ydata(:,:,i), plotParameters.styleStr, 'color', cstr{mod(i-1,6)+1});
            else
                h = plot(time, ydata(:,:,i), plotParameters.styleStr, 'color', plotParameters.colorStr);
            end
        end
        hold off
        if any(size(ydata)==1) || length(size(ydata))<3 % if it is not 3d matrix, then copy to clipboard.
            h_copy(squeeze(ydata), 'vertical');
        end
    case 3
        for j = 1:size(ydata,2)
            if j>1
                hold on
            end
            if strcmpi(plotParameters.colorStr, 'auto')
                h = plot(time, mean(ydata(:,j,:),3), plotParameters.styleStr, 'color', cstr{mod(j-1,6)+1});
            else
                h = plot(time, mean(ydata(:,j,:),3), plotParameters.styleStr, 'color', plotParameters.colorStr);
            end
        end
        hold off
        h_copy(mean(ydata,3), 'horizontal');
    case 4
        for j = 1:size(ydata,2)
            if j>1
                hold on
            end
            if strcmpi(plotParameters.colorStr, 'auto')
                h = errorbar(time, mean(ydata(:,j,:),3),std(ydata(:,j,:),0,3), plotParameters.styleStr, 'color', cstr{mod(j-1,6)+1});
            else
                h = errorbar(time, mean(ydata(:,j,:),3),std(ydata(:,j,:),0,3), plotParameters.styleStr, 'color', plotParameters.colorStr);
            end
        end
        hold off
        h_copy(horzcat(mean(ydata,3),std(ydata,0,3)), 'horizontal');
    case 5
        for j = 1:size(ydata,2)
            if j>1
                hold on
            end
            if strcmpi(plotParameters.colorStr, 'auto')
                h = errorbar(time, mean(ydata(:,j,:),3),std(ydata(:,j,:),0,3)/sqrt(size(ydata,3)), plotParameters.styleStr,...
                    'color', cstr{mod(j-1,6)+1});
            else
                h = errorbar(time, mean(ydata(:,j,:),3),std(ydata(:,j,:),0,3)/sqrt(size(ydata,3)), plotParameters.styleStr,...
                    'color', plotParameters.colorStr);
            end
        end
        hold off
        h_copy(horzcat(mean(ydata,3),std(ydata,0,3)/sqrt(size(ydata,3))), 'horizontal');
end

set(h,'ButtonDownFcn','h_selectFrameAnalysisPlotLine3');
xlim(plotParameters.xlim);
ylim(plotParameters.ylim);

axesobj = get(h(1),'Parent');
set(axesobj,'ButtonDownFcn','h_unSelectLine3');



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
para.dataPlotOpt = get(handles.frameAnalysisPlotDataOpt,'Value');



