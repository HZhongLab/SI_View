function h_autoMakeMovie3(handles)

global h_img3

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

if isfield(currentStruct.state, 'movieContentOpt')
    movieContentOpt = currentStruct.state.movieContentOpt.value;
else
    movieContentOpt = get(handles.movieContentOpt, 'value');
end

if isfield(currentStruct.state, 'movieROIOpt')
    ROIOpt = currentStruct.state.movieROIOpt.value;
else
    ROIOpt = get(handles.movieROIOpt, 'value');
end

% zLim = currentStruct.display.settings.zLimit;
zLim(1) = str2num(get(handles.zStackStrLow,'String'));
zLim(2) = str2num(get(handles.zStackStrHigh,'String'));

switch movieContentOpt
    case {1, 2, 3, 4} % z stack views
        maxOpt = currentStruct.state.maxProjectionOpt.value;
        
        if ~ismember(maxOpt, [1 4])% if not single section, reset to single section
            set(handles.maxProjectionOpt,'Value',1);
            h_genericSettingCallback3(handles.maxProjectionOpt, handles);
        end
        
        switch movieContentOpt
            case 1
                ind = 1:diff(zLim)+1;
            case 2 % end to begin
                ind = diff(zLim)+1:-1:1;
            case 3 % begin to end to begin
                ind = [1:diff(zLim)+1, diff(zLim):-1:1];
            case 4 % end to begin to end
                ind = [diff(zLim)+1:-1:1, 2:diff(zLim)+1];
        end
        
        for i = 1:length(ind)
            set(handles.zStackStrLow,'String',num2str(zLim(1)+ind(i)-1));
            h_zStackQuality3(handles); 
            h_replot3(handles, 'slow');
            drawnow;
            mov(i) = getframe(handles.imageAxes);
        end
        
        set(handles.maxProjectionOpt,'Value',maxOpt);
        h_genericSettingCallback3(handles.maxProjectionOpt, handles);
        set(handles.zStackStrLow,'String',num2str(zLim(1)));
        set(handles.zStackStrHigh,'String',num2str(zLim(2)));
            h_zStackQuality3(handles); 
            h_replot3(handles, 'slow');
    case {5, 6} % grp movie
        currentFilename = get(handles.currentFileName, 'String');
        [currentPName, currentFName] = h_analyzeFilename(currentFilename);% note: currentFName has extention.
%         zLim = currentStruct.display.settings.zLimit;
        
        if ~isfield(currentStruct.activeGroup, 'groupFiles') || isempty(currentStruct.activeGroup.groupFiles)
            display('No active group. Abort!')
            return;
        end
        
        if ~ismember(lower(currentFName),lower({currentStruct.activeGroup.groupFiles.fname}'))
            disp('Current image does not belong to the active group!');
            return;
        else            
            for i = 1:length(currentStruct.activeGroup.groupFiles)
                %         currentStruct.display.previousImg = currentStruct.display.intensityImg;
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
                
                h_openFile3(handles, filename);
%                 if movieContentOpt==6
%                     FV_loadAnalyzedROI(handles);
%                 end
                mov(i) = getframe(handles.imageAxes);
            end
            h_openFile3(handles, currentFilename)
        end
        
        h_openFile3(handles, currentFilename);
        
        set(handles.zStackStrLow,'String',num2str(zLim(1)));
        set(handles.zStackStrHigh,'String',num2str(zLim(2)));
        h_zStackQuality3(handles);
        h_replot3(handles, 'slow');
    otherwise

end

h_img3.(currentStructName).movie.mov = mov;