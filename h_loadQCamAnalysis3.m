function h_loadQCamAnalysis3(handles)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);


currentFilename = get(handles.currentFileName,'String');
[pname, fname, fExt] = fileparts(currentFilename);
analysisNumber = h_img3.(currentStructName).state.analysisNumber.value;


roiFilename = fullfile(pname,'Analysis',[fname,'_qCamROI3_A',num2str(analysisNumber),'.mat']);


if exist(roiFilename, 'file')
    load(roiFilename);
    h_img3.(currentStructName).lastAnalysis.qCamAnalysis = Aout;
    objs = [findobj(handles.imageAxes,'Tag','ROI3');findobj(handles.imageAxes,'Tag','BGROI3')];
    for i = 1:length(objs)
        UserData = get(objs(i),'UserData');
        delete(objs(i));
        delete(UserData.texthandle);
    end
    axes(handles.imageAxes);
    if isfield(Aout,'roi')
        for i = 1:length(Aout.roi)
            UserData.roi.xi = Aout.roi(i).xi;
            UserData.roi.yi = Aout.roi(i).yi;
            
            hold on;
            h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
            set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'ROI3', 'Color','red', 'EraseMode','xor');
            hold off;
            
            x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
            y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
            UserData.texthandle = text(x,y,num2str(Aout.roiNumber(i)),'HorizontalAlignment',...
                'Center','VerticalAlignment','Middle', 'Color','red', 'EraseMode','xor', 'ButtonDownFcn', 'h_dragRoiText3');
            UserData.number = Aout.roiNumber(i);
            UserData.ROIhandle = h;
            UserData.timeLastClick = clock;
            set(h,'UserData',UserData);
            set(UserData.texthandle,'UserData',UserData);
        end
    end
    
    if isfield(Aout,'bgroi') && ~isempty(Aout.bgroi)
        UserData.roi.xi = Aout.bgroi.xi;
        UserData.roi.yi = Aout.bgroi.yi;
        
        hold on;
        h = plot(UserData.roi.xi,UserData.roi.yi,'m-');
        set(h,'ButtonDownFcn', 'h_dragRoi3', 'Tag', 'BGROI3');
        hold off;
        
        x = (min(UserData.roi.xi) + max(UserData.roi.xi))/2;
        y = (min(UserData.roi.yi) + max(UserData.roi.yi))/2;
        UserData.texthandle = text(x,y,'BG','HorizontalAlignment',...
            'Center','VerticalAlignment','Middle', 'Color','red', 'EraseMode','xor', 'ButtonDownFcn', 'h_dragRoiText3');
        UserData.number = 'BG';
        UserData.ROIhandle = h;
        UserData.timeLastClick = clock;
        set(h,'UserData',UserData);
        set(UserData.texthandle,'UserData',UserData);
    end
end


    