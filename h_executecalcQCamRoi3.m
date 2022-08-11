function Aout = h_executecalcQCamRoi3(handles)



global h_img3

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

Aout = struct('roiNumber',[],'roi', [], 'timestr', '', 'filename', '');

fname = get(handles.currentFileName,'String');
[filepath, filename, fExt] = fileparts(fname);

zLim(1) = str2num(get(handles.zStackStrLow,'String'));
zLim(2) = str2num(get(handles.zStackStrHigh,'String'));

siz = h_img3.(currentStructName).image.data.size;

roiObj = sort(findobj(handles.imageAxes,'Tag', 'ROI3'));


n_roi = length(roiObj);

for j = 1:n_roi
    UserData = get(roiObj(j), 'UserData');
    [Aout.roi(j).BW,Aout.roi(j).xi,Aout.roi(j).yi] = roipoly(ones(siz(1), siz(2)), UserData.roi.xi, UserData.roi.yi);
    Aout.roiNumber(j) = UserData.number;
end

[Aout.roiNumber,I] = sort(Aout.roiNumber);
Aout.roi = Aout.roi(I);

bgroiobj = findobj(handles.imageAxes,'Tag','BGROI3');
if ~isempty(bgroiobj)
    UserData = get(bgroiobj, 'UserData');
    [Aout.bgroi.BW,Aout.bgroi.xi,Aout.bgroi.yi] = roipoly(ones(siz(1), siz(2)), UserData.roi.xi, UserData.roi.yi);
%     bgBW = find(Aout.bgroi.BW);
else
    Aout.bgroi = [];
end

[img, maxFrameNumber] = read_qcamraw(fname, 1);
F = zeros(maxFrameNumber, n_roi);%avg fluorescent intensity 
bg = zeros(maxFrameNumber, 1);

for ii = 1:50:maxFrameNumber
    currentFrames = ii:ii+49;
    currentFrames(currentFrames>maxFrameNumber) = [];
    img = flipdim(rot90(read_qcamraw(fname, currentFrames)),1);
    siz = size(img);
    if ~isempty(Aout.bgroi)
        bgBW = repmat(Aout.bgroi.BW, [1, 1, siz(3)]);
        bgROIImg = double(img).*double(bgBW);
        bgROI_F = squeeze(sum(sum(bgROIImg, 1),2));
        bg(currentFrames) = bgROI_F/sum(sum(bgBW(:,:,1)));
    end
    for i = 1:n_roi
        BW = repmat(Aout.roi(i).BW, [1, 1, siz(3)]);
        ROIImg = double(img).*double(BW);
        ROI_F = squeeze(sum(sum(ROIImg, 1),2));
        F(currentFrames, i) = ROI_F/sum(sum(BW(:,:,1))) - bg(currentFrames);
    end
end

Aout.F = F;
Aout.bg = bg;
baseline = mean(F(10:20,:),1);
baseline = repmat(baseline, [size(F, 1), 1]); 
Aout.deltaFoverF = (F - baseline) ./ baseline;
        


        fileinfo = dir(fname);
        Aout.timestr = fileinfo.date;


Aout.filename = fname;




%%%%%%%% Save %%%%%%%%%%%%%%%%%%%%

if ~exist(fullfile(filepath,'Analysis'),'dir')
    currpath = pwd;
    cd (filepath);
    mkdir('Analysis');
    cd (currpath);
end
analysisNumber = h_img3.(currentStructName).state.analysisNumber.value;

fname = fullfile(filepath,'Analysis',[filename,'_qCamROI3_A',num2str(analysisNumber),'.mat']);
save(fname, 'Aout');

h_updateInfo3(handles);
