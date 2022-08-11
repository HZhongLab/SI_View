function h_loadMEIAnalysis3(handles)

global h_img3;

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);


currentFilename = get(handles.currentFileName,'String');
[pname, fname, fExt] = fileparts(currentFilename);
analysisNumber = h_img3.(currentStructName).state.analysisNumber.value;
improfileOpts = h_getImprofileOpts(handles);

roiFilename = fullfile(pname,'Analysis',[fname,'_MEI3_A',num2str(analysisNumber),'.mat']);


if exist(roiFilename, 'file')
    temp = load(roiFilename);
    MEIAnalysis = temp.MEIAnalysis;
    h_img3.(currentStructName).lastAnalysis.MEIAnalysis = MEIAnalysis;
    
    %plot line on image
    if ~isempty(improfileOpts.plotOpt)
        axes(handles.imageAxes);
        hold on;
        if ~improfileOpts.holdOnOpt
            delete(findobj(handles.imageAxes, 'Tag', 'lineROI3'));
        end
        plot(MEIAnalysis.avg.x, MEIAnalysis.avg.y, improfileOpts.plotOpt, 'linewidth', 2, 'Tag', 'lineROI3');
        hold off
    end
    
    assignin('base','MEIAnalysis',MEIAnalysis);
    % h_copy([MEIAnalysis.width, MEIAnalysis.MEI_center]')
    
    MEIAnalysis
end
