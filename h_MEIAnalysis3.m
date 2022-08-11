function MEIAnalysis = h_MEIAnalysis3(handles)

global h_img3;  

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

improfileOpts = h_getImprofileOpts(handles);

n = improfileOpts.lineWidth;

individuals = [];
avg = [];

% measure line profile
redImg = currentStruct.image.display.red; 
greenImg = currentStruct.image.display.green;
% for color (overlay) images this is not the direct displayed image. No
% saturation due to look up table.
bleedthrough = h_getBleedthrough(handles);

[xi,yi] = getline(handles.h_imstack3);

if length(xi)== 2
    slope = (yi(1)-yi(2))/(xi(1)-xi(2));
    angle = atand(slope);
    j = 0;
    len = sqrt(diff(xi)^2+diff(yi)^2);
    N = round(len);
    for i = (1:n)-mean(1:n)
        j = j+1;
        individuals(j).x = i*cosd(angle+90)+xi;
        individuals(j).y = i*sind(angle+90)+yi;
        individuals(j).red = improfile(redImg,individuals(j).x,individuals(j).y,N);
        individuals(j).green = improfile(greenImg,individuals(j).x,individuals(j).y,N);
        % note: have to specify N, otherwise it will has diff(xi) number of
        % points, not 1 point per pixel.
        
        if j == 1
            individuals = repmat(individuals, [1, n]);
        end
    end
    
    avg.x = mean(cat(2,individuals.x),2);
    avg.y = mean(cat(2,individuals.y),2);
    avg.red = mean(cat(2,individuals.red),2);
    avg.green = mean(cat(2,individuals.green),2);
    avg.RToGBleedthrough = bleedthrough;
    avg.bleedThroughCorrectedGreen = avg.green - avg.red*bleedthrough;
    avg.bleedThroughCorrectedGreen = avg.green - avg.red*bleedthrough;
    
    temp = sort(avg.red(:));
    temp(isnan(temp)) = [];
    avg.bgRed = mean(temp(1:10));
    avg.normRed = (avg.red - avg.bgRed)/(max(avg.red) - avg.bgRed);
    
    temp = sort(avg.bleedThroughCorrectedGreen(:));
    temp(isnan(temp)) = [];
    avg.bgGreen = mean(temp(1:10));
    avg.normGreen = (avg.bleedThroughCorrectedGreen - avg.bgGreen)/(max(avg.bleedThroughCorrectedGreen) - avg.bgGreen);
       
    MEIAnalysis.individuals = individuals;
    MEIAnalysis.avg = avg;
    
    % now calculate MEI
    thresh = 0.3; % in the fugure we may play with this thresh.
    [widthRed, pos] = h_findFWHM(avg.normRed,thresh);
    
    MEIAnalysis.boundaryThresh = thresh;
    MEIAnalysis.boundaryPos = pos;
    MEIAnalysis.redImg = redImg;
    MEIAnalysis.greenImg = greenImg;
    if currentStruct.info.software.version >=3.8
        MEIAnalysis.zoom = currentStruct.info.acq.zoomFactor;
    else
        MEIAnalysis.zoom = currentStruct.info.acq.zoomhundreds*100 + ...
            currentStruct.info.acq.zoomtens*10 + currentStruct.info.acq.zoomones;
    end
    MEIAnalysis.width = calculateFieldOfView(MEIAnalysis.zoom)/size(redImg,1)*diff(pos);
    
    xdata = 1:length(avg.red);
    g = mean(interp1(xdata, avg.normGreen, (-1:1)+pos(1)));%use three points avg
    g2 = mean(interp1(xdata, avg.normGreen, (-1:1)+pos(2)));
    r =  mean(interp1(xdata, avg.normRed, (-1:1)+pos(1)));
    r2 =  mean(interp1(xdata, avg.normRed, (-1:1)+pos(2)));
    
    MEIAnalysis.avg.rCenterIntensity = mean(interp1(xdata, avg.red, (-1:1)+mean(pos))) - avg.bgRed;% this is not bleedthrough corrected.
    MEIAnalysis.avg.gCenterIntensity = mean(interp1(xdata, avg.green, (-1:1)+mean(pos))) - avg.bgGreen; % this is not bleedthrough corrected.
    MEIAnalysis.avg.btCorrectedGCenterInt = mean(interp1(xdata, avg.bleedThroughCorrectedGreen, (-1:1)+mean(pos))) - avg.bgGreen; % this is not bleedthrough corrected      
    
    gCenter = mean(interp1(xdata, avg.normGreen, (-1:1)+mean(pos)));
    rCenter = mean(interp1(xdata, avg.normRed, (-1:1)+mean(pos)));
    MEIAnalysis.MEI_center = log2((g/r+g2/r2)/2/(gCenter/rCenter));
    
    [max_r,I] = max(avg.normRed); %should we use center or use max?    
    MEIAnalysis.maxPos = I;
    MEIAnalysis.MEI_max = log2((g/r+g2/r2)/2/(avg.normGreen(I)/avg.normRed(I)));
    MEIAnalysis.fileName = get(handles.currentFileName,'String');
    
    h = 13330+currentInd;
    if ishandle(h)
        delete(h); % new figure every time, so won't run into the problem of overwriting previous one when click save.
    end
    
    [pname, fname] = fileparts(MEIAnalysis.fileName);
    h = figure(h);
    set(h, 'Name', 'h_imstack3 MEI analysis');
    plot(xdata, avg.normRed, 'r-', xdata, avg.normGreen, 'g-');
    hold on, plot(vertcat([pos(1), pos(1)], [pos(2), pos(2)], [mean(pos), mean(pos)]), [0 1], 'b-');   
    title([fname, '  MEI=', num2str(MEIAnalysis.MEI_center), '   dendrite width=', num2str(MEIAnalysis.width)])

    %plot line on image
    if ~isempty(improfileOpts.plotOpt)
        axes(handles.imageAxes);
        hold on;
        if ~improfileOpts.holdOnOpt
            delete(findobj(handles.imageAxes, 'Tag', 'lineROI3'));
        end
        plot(avg.x, avg.y, improfileOpts.plotOpt, 'linewidth', 2, 'Tag', 'lineROI3');
        hold off
    end
    
    %%%%%%%% Save %%%%%%%%%%%%%%%%%%%%
    
    [filepath, filename] = fileparts(MEIAnalysis.fileName);
    
    if ~exist(fullfile(filepath,'Analysis'),'dir')
        currpath = pwd;
        cd (filepath);
        mkdir('Analysis');
        cd (currpath);
    end
    analysisNumber = h_img3.(currentStructName).state.analysisNumber.value;
    
    fname = fullfile(filepath,'Analysis',[filename,'_MEI3_A',num2str(analysisNumber),'.mat']);
    save(fname, 'MEIAnalysis');
    
    h_updateInfo3(handles);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    assignin('base','MEIAnalysis',MEIAnalysis);
    h_copy([MEIAnalysis.MEI_center, MEIAnalysis.width], 'horizontal', filename)
    
    MEIAnalysis
    
    % some extra stuffs for convenience.
    % Aout = h_quickinfo(currentStruct.info);
%     h_copy(MEIAnalysis.avg.btCorrectedGCenterInt);

else
    MEIAnalysis = [];
end






function bleedthrough = h_getBleedthrough(handles)

bleedStr = get(handles.bleedThroughCorrOpt,'string');
bleedValue = get(handles.bleedThroughCorrOpt,'value');
bleedStr = bleedStr{bleedValue};
pointer1 = strfind(bleedStr,'%');
if ~isempty(pointer1)
    bleedNumStr = bleedStr(6:pointer1-1);
    bleedthrough = str2double(bleedNumStr) * 0.01;
else
    bleedthrough = 0;
end
       


