function [stack, maxFrameNumber] = read_qcamraw(fn, frameNumber)
%
%
% fn: string file name of QCAMRAW binary file.
% frameNumber: vector of frame numbers.
%
%
%

% fn = 'JF8635_green01_.qcamraw';

pf = fopen(fn, 'r');
fseek(pf, 0, 'eof');
fsize = ftell(pf);

gotThreeData = 0;

%get header infomation from the file
frewind(pf);
while gotThreeData < 3 
    tline = fgets(pf);
    [left, rem] = strtok( tline, ':');
    if strcmp(left, 'Fixed-Header-Size')
        right = strtok(rem, ':');
        fHeaderSize = strtok(right);
        fHeaderSize = str2num(fHeaderSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'Frame-Size')
        right = strtok(rem, ':');
        frameSize = strtok(right);
        frameSize = str2num(frameSize);
        gotThreeData = gotThreeData +1;
    elseif strcmp(left, 'ROI')
        right = strtok(rem, ':');
        [left, right]=strtok(right, ',');
        [left, right]=strtok(right, ',');
        [width, right]=strtok(right, ',');
        height = strtok(right, ',');
        width = str2num(width);
        height = str2num(height);
        gotThreeData = gotThreeData +1;
    else   
        continue;
    end
end

numberOfFrames = (fsize -fHeaderSize)/frameSize;
maxFrameNumber = numberOfFrames;
% frameNumber = 1:50;

if isempty(frameNumber)
    return;
end

if max(frameNumber) > numberOfFrames
    error(['Frame number (' num2str(frameNumber) ') exceeded maximum (' num2str(numberOfFrames) ').']);
    return;
end

stack = zeros(width, height, length(frameNumber),'uint16');

for i = 1 : length(frameNumber)
    fseek(pf, fHeaderSize + (frameNumber(i)-1)* frameSize, 'bof');
    frameData = fread(pf, [width, height], 'uint16');
    stack(:,:,i) = frameData;
end

fclose(pf);

