function Aout = h_executeFrameAnalysisCalc3(handles)

global h_img3

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

fname = get(handles.currentFileName,'String');
[filepath, filename, fExt] = fileparts(fname);

zLim(1) = str2num(get(handles.zStackStrLow,'String'));
zLim(2) = str2num(get(handles.zStackStrHigh,'String'));



siz = currentStruct.image.data.size;

% initialized Aout so that the structure is consistent across files.
Aout = struct('currentSettings', struct('state', struct), 'PAInfo', [], 'ROINumber',[],'roi', [],...
    'bgroi', [], 'includedZ', [], 'avg_bg', [], 'avg_intensity', [], 'integratedIntensity', [],...
    'max_intensity', [], 'roiVol', [], 'timestr', '', 'filename', '');

Aout(1).currentSettings.state = currentStruct.state; %Aout start as an empty structure. Need to used Aout(1) to give it a size.

if strcmpi(h_img3.(currentStructName).info.fileType, 'scanimage') && ~isempty(currentStruct.info.init.eom.powerBoxNormCoords) %sometimes powerBoxNormCoords is empty.
    Aout.PAInfo = h_autoGetPAROI3(currentStruct.info); % save this for future.
    xyBW = Aout.PAInfo.xyBW;
else
    xyBW = true(siz(1), siz(2));
end
    

includedZ = zLim(1):zLim(2);
Aout.includedZ = includedZ;

ROIObj = sort(findobj(handles.imageAxes,'Tag', 'ROI3'));
bgROIObj = findobj(handles.imageAxes,'Tag','BGROI3');

n_roi = length(ROIObj);

if n_roi > 0
    for j = 1:n_roi
        UserData = get(ROIObj(j), 'UserData');
        [Aout.roi(j).BW,Aout.roi(j).xi,Aout.roi(j).yi] = roipoly(ones(siz(1), siz(2)), UserData.roi.xi, UserData.roi.yi);
        if any(any(Aout.roi(j).BW & xyBW))
            Aout.roi(j).overlapWPowerbox = true;
        else
            Aout.roi(j).overlapWPowerbox = false;
        end
        Aout.ROINumber(j) = UserData.number;
    end    
    [Aout.ROINumber,I] = sort(Aout.ROINumber);
    Aout.roi = Aout.roi(I);
end

if ~isempty(bgROIObj)
    UserData = get(bgROIObj, 'UserData');
    [Aout.bgroi.BW,Aout.bgroi.xi,Aout.bgroi.yi] = roipoly(ones(siz(1), siz(2)), UserData.roi.xi, UserData.roi.yi);
    bgBW = repmat(Aout.bgroi.BW, [1 1 length(includedZ)]);
else
    bgBW = false(siz(1), siz(2), length(includedZ));
end

if ~isempty(currentStruct.image.data.red)
    red = double(currentStruct.image.data.red(:,:,includedZ));% make it double so it is coding is simplier.
else
    red = nan(siz(1), siz(2), length(includedZ));
end

if ~isempty(currentStruct.image.data.green)
    green = double(currentStruct.image.data.green(:,:,includedZ));
else
    green = nan(siz(1), siz(2), length(includedZ));
end

if ~isempty(currentStruct.image.data.blue)
    blue = double(currentStruct.image.data.blue(:,:,includedZ));
else
    blue = nan(siz(1), siz(2), length(includedZ));
end

currentRed2 = reshape(red, siz(1)*siz(2), length(includedZ));
currentGreen2 = reshape(green, siz(1)*siz(2), length(includedZ));
currentBlue2 = reshape(blue, siz(1)*siz(2), length(includedZ));

if ~isempty(bgROIObj)
% this is wrong!!! it also average in all the zeros. Sum is ok, mean is not.
%     Aout.avg_bg.red = squeeze(mean(mean(red.*bgBW,1),2));
%     Aout.avg_bg.green = squeeze(mean(mean(green.*bgBW,1),2));
%     Aout.avg_bg.blue = squeeze(mean(mean(blue.*bgBW,1),2));

    currentInd = find(Aout.bgroi.BW); 
    Aout.avg_bg.red = mean(currentRed2(currentInd, :),1)';
    Aout.avg_bg.green = mean(currentGreen2(currentInd, :),1)';
    Aout.avg_bg.blue = mean(currentBlue2(currentInd, :),1)';

else
    Aout.avg_bg.red = zeros(length(includedZ), 1);
    Aout.avg_bg.green = zeros(length(includedZ), 1);
    Aout.avg_bg.blue = zeros(length(includedZ), 1);
end

sigma = 2;
f = fspecial('gaussian', 2*(sigma+1)+1, sigma);%to reduce noise in measuring max value.


for i = 1:n_roi
%     currentBW = repmat(Aout.roi(i).BW, [1 1 length(includedZ)]);
%     currentRed = red.*currentBW;
%     currentGreen = green.*currentBW;
%     currentBlue = blue.*currentBW;
%         
%     Aout.roiVol(i) = sum(sum(Aout.roi(i).BW));%note: this is only for one section.
%    
%     Aout.integratedIntensity.red(:,i) = squeeze(sum(sum(currentRed, 1),2)) - Aout.avg_bg.red*Aout.roiVol(i);
%     Aout.integratedIntensity.green(:,i) = squeeze(sum(sum(currentGreen, 1),2)) - Aout.avg_bg.green*Aout.roiVol(i);
%     Aout.integratedIntensity.blue(:,i) = squeeze(sum(sum(currentBlue, 1),2)) - Aout.avg_bg.blue*Aout.roiVol(i);
%     
%     Aout.max_intensity.red(:,i) = squeeze(max(max(imfilter(currentRed, f), [], 1),[],2)) - Aout.avg_bg.red;
%     Aout.max_intensity.green(:,i) = squeeze(max(max(imfilter(currentGreen, f), [], 1),[],2)) - Aout.avg_bg.green;
%     Aout.max_intensity.blue(:,i) = squeeze(max(max(imfilter(currentBlue, f), [], 1), [], 2)) - Aout.avg_bg.blue;
    
    currentInd = find(Aout.roi(i).BW); % this is try to make max faster, and remove the need to squeeze. 
    % this is ~50X faster than above.
   
        Aout.roiVol(i) = sum(sum(Aout.roi(i).BW));%note: this is only for one section.
    
        Aout.integratedIntensity.red(:,i) = sum(currentRed2(currentInd, :),1)' - Aout.avg_bg.red*Aout.roiVol(i);
        Aout.integratedIntensity.green(:,i) = sum(currentGreen2(currentInd, :),1)' - Aout.avg_bg.green*Aout.roiVol(i);
        Aout.integratedIntensity.blue(:,i) = sum(currentBlue2(currentInd, :),1)' - Aout.avg_bg.blue*Aout.roiVol(i);
    
        Aout.max_intensity.red(:,i) = max(currentRed2(currentInd, :),[],1)' - Aout.avg_bg.red;
        Aout.max_intensity.green(:,i) = max(currentGreen2(currentInd, :),[],1)' - Aout.avg_bg.green;
        Aout.max_intensity.blue(:,i) = max(currentBlue2(currentInd, :),[],1)' - Aout.avg_bg.blue;
        
end

Aout.avg_intensity.red = Aout.integratedIntensity.red ./ repmat(Aout.roiVol, [length(includedZ),1]);
Aout.avg_intensity.green = Aout.integratedIntensity.green ./ repmat(Aout.roiVol, [length(includedZ),1]);
Aout.avg_intensity.blue = Aout.integratedIntensity .blue./ repmat(Aout.roiVol, [length(includedZ),1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55555
switch lower(h_img3.(currentStructName).info.fileType)
    case 'scanimage'
        Aout.timestr = h_img3.(currentStructName).info.internal.triggerTimeString;
        if isempty(Aout.timestr) % this can happen sometimes, especially in older versions of scanimage.
            fileinfo = dir(fname);
            Aout.timestr = fileinfo.date;
        end
    case 'lsmtif'
        Aout.timestr = h_img3.(currentStructName).info.FileModDate;
    otherwise
        fileinfo = dir(fname);
        Aout.timestr = fileinfo.date;
end

Aout.filename = fname;


%%%%%%%% Save %%%%%%%%%%%%%%%%%%%%

if ~(exist(fullfile(filepath,'Analysis'))==7)
    currpath = pwd;
    cd (filepath);
    mkdir('Analysis');
    cd (currpath);
end


analysisNumber = currentStruct.state.analysisNumber.value;

save(fullfile(filepath,'Analysis',[filename,'_frameAnalysis3_A',num2str(analysisNumber),'.mat']), 'Aout');
assignin('base','frameAnalysis3',Aout);

h_img3.(currentStructName).lastAnalysis.frameAnalysis = Aout;

h_updateInfo3(handles);
