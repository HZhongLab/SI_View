function h_executeGroupCalcRoi3(handles)

global h_img3

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

set(handles.pauseGroupCalc,'Enable','on');

if ~isfield(currentStruct, 'activeGroup') || isempty(currentStruct.activeGroup.groupFiles)
    disp('No active group!')
    return;
end

currentFilename = get(handles.currentFileName,'String');  
[currentPName, currentFName] = h_analyzeFilename(currentFilename);% note: currentFName has extention.
if isfield(currentStruct.state, 'grpCalcOpt')
    grpCalcOpt = currentStruct.state.grpCalcOpt.value;
else
    grpCalcOpt = 1;
end
zLim = [str2num(get(handles.zStackStrLow,'String')), str2num(get(handles.zStackStrHigh,'String'))];

if ~ismember(lower(currentFName),lower({currentStruct.activeGroup.groupFiles.fname}'))
    disp('Current image does not belong to the active group not match!');
    return;
else
%     %%%%%%%%%%% Get ROIs %%%%%%%%%%%%%%%%%%%%%%%%%%%
%     roiobj = [sort(findobj(handles.h_imstack3,'Tag', 'ROI3'));findobj(handles.h_imstack,'Tag','BGROI3');...
%         findobj(handles.imageAxes, 'Tag', 'annotationROI3')];
%         roiUData = get(roiobj, 'UserData');
    
    
    
    %%%%%%%%%%%%% Calc one by one %%%%%%%%%%%%%%%%%%%%%%%%%%
    montage = h_montageSize(length(currentStruct.activeGroup.groupFiles));
    fig = figure('Name', currentStruct.activeGroup.groupName);
    isImg = 0;
    for i = 1:length(currentStruct.activeGroup.groupFiles)
%         h_img3.(currentStructName).oldimg = h_getOldImg3(handles);
        
        relativePathFName = fullfile(currentStruct.activeGroup.groupPath, currentStruct.activeGroup.groupFiles(i).relativePath,...
            currentStruct.activeGroup.groupFiles(i).fname);
        if exist(relativePathFName, 'file') %preferentially using relative path filename, if not exist, try absolutely filename.
            filename = relativePathFName;
        elseif exist(currentStruct.activeGroup.groupFiles(i).name, 'file')
            filename = currentStruct.activeGroup.groupFiles(i).name;
        else
            display(['cannot find file: ', currentStruct.activeGroup.groupFiles(i).fname]);
            continue; % this means loop to next i.
        end
        
        [pname, fname, fExt] = fileparts(filename);
        analysisNum = currentStruct.state.analysisNumber.value;
        analysisFilename = fullfile(pname,'Analysis',[fname,'_V3roi_A', num2str(analysisNum), '.mat']);
        
        if ~(ismember(grpCalcOpt, [3, 5]) && exist(analysisFilename, 'file'))% 3 and 5 are un-analyzed only.
            h_openFile3(handles, filename);
            if ismember(grpCalcOpt, [4, 5, 8]) % keep z
                % additional: z are not recorded in state:
                set(handles.zStackStrLow,'String', num2str(zLim(1)));
                set(handles.zStackStrHigh,'String', num2str(zLim(2)));
                %     set(handles.imageAxes,'XLim',xlim,'YLim',ylim);
                h_zStackQuality3(handles);
%                 FV_updateDispSettingVar(handles);
                h_replot3(handles, 'slow');%Note: put getCurrentImg into replot
            end
            
            if isfield(currentStruct.state, 'autoPosWhenGrpCalc') && currentStruct.state.autoPosWhenGrpCalc.value
                h_autoPosition3(handles);
                pause(3.5);% 5 seems a bit too slow, but 3 sometimes is not enough time.
            elseif ismember(grpCalcOpt, 6)%load ROI and recalc
                h_loadAnalyzedRoiData3(handles, 'v3');
            elseif ismember(grpCalcOpt, [7, 8])%load h_imstack ROI and recalc
                h_loadAnalyzedRoiData3(handles, 'v1');
            end
            
            h_executecalcRoi3(handles);
%             isImg = 0; % a flag for whether there is any image in fig
            try
                F = getframe(handles.imageAxes);
                figure(fig);
                subplot(montage(1),montage(2),i)
                colormap(F.colormap);
                isImg = image(F.cdata);
                set(gca,'XTickLabel', '', 'YTickLabel', '', 'XTick',[],'YTick',[]);
                xlabel(currentStruct.activeGroup.groupFiles(i).fname);
                isImg = 1;
            catch
                disp('getframe error. Possibly h_imstack3 window is not in the main screen.')
            end
        end
    end
    
    if ~isImg
        delete(fig);
    end
end


        
h_openFile3(handles, currentFilename);
set(handles.zStackStrLow,'String', num2str(zLim(1)));
set(handles.zStackStrHigh,'String', num2str(zLim(2)));
%     set(handles.imageAxes,'XLim',xlim,'YLim',ylim);
h_zStackQuality3(handles);

h_loadAnalyzedRoiData3(handles, 'v3');

% for j = 1:length(roiobj)
%     set(roiobj(j),'UserData',roiUData{j},'XData',roiUData{j}.roi.xi,'YData',roiUData{j}.roi.yi);
%     x = (min(roiUData{j}.roi.xi) + max(roiUData{j}.roi.xi))/2;
%     y = (min(roiUData{j}.roi.yi) + max(roiUData{j}.roi.yi))/2;
%     set(roiUData{j}.texthandle,'UserData',roiUData{j},'Position',[x,y]);
% end

set(handles.pauseGroupCalc,'Enable','off');


