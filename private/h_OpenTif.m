function [Aout,header,err] = h_OpenTif(filename, frame_numbers, varargin)
% [Aout,header] = h_OpenTif(filename, frame_numbers, varargin)
% Modified from genericOpenTif
% h_OPENTIF   - Opens an Image file with TIF extension.  It can retrieve
% only the frames specified by frame_numbers.
%   h_OPENTIF opens a TIF file and store its contents as array Aout.
%   Filename is the file name with extension.
%   
%   frame_numbers can be left blank ('[]') or omitted.  All frames will be
%   retrieved.
%
%   VARARGIN are paramameter value pairs that specify the output type.
%   Possible values include:
%
%    'filter'                1 or 0      Apply blocksize x blocksize Median Filter
%    'blocksize'             > 1         Blocksize for filter.
%    'splitIntoCellArray'    1 or 0      Output each input channel in cell array.
%    'linescan'              1 or 0      Reshape output into single frame by concatentating
%                                             to the bottom of the image.
%
%   See also CONVERTSTACKTOLS, PARSEHEADER

Aout=uint16([]);
header=[];

if ~(exist('frame_numbers')==1)
    frame_numbers = [];
end

% Parse the inputs....
filter=0;
blocksize=3;
splitIntoCellArray=0;
linescan=0;
err = 0;
if nargin > 2
    % Parse input parameter pairs and rewrite values.
    counter=1;
    while counter+1 <= length(varargin)
        eval([varargin{counter} '=[(varargin{counter+1})];']);
        counter=counter+2;
    end
end

if ~(length(frame_numbers)==1 && frame_numbers == 0)
    h = waitbar(0,'Opening Tif image...', 'Name', 'Open TIF Image', 'Pointer', 'watch');
end

try
    info=imfinfo(filename);
    frames = length(info);
    if isfield(info,'ImageDescription')
        header=info(1).ImageDescription;
        header=parseHeader(header);
    else
        header = [];
    end
    if isempty(frame_numbers)
        frame_numbers = [1:frames];
    else
        frame_numbers = frame_numbers(frame_numbers<=frames);
        frame_numbers = frame_numbers(frame_numbers~=0);
    end
    ver = version;
    if ~isempty(frame_numbers)
        if str2double(ver(1))<8
            j = 1;
            for i = frame_numbers
                if mod(j, 20)==0
                    waitbar(i/frames,h, ['Loading Frame Number ' num2str(i)]);
                end
                Aout(:,:,j) = imread(filename, i);
                if j == 1
                    Aout = repmat(Aout(:,:,1),[1,1,length(frame_numbers)]);
                end
                if filter
                    Aout(:,:,j)=medfilt2(Aout(:,:,j),[blocksize blocksize]);
                end
                j = j + 1;
            end
            
            if exist('h')==1 && ishandle(h)
                waitbar(1,h, 'Done');
                close(h);
            end
        else %try not using imread, which take much longer when reading later frames (frame 1000 will take ~0.6s vs frame 1 0.003s)
            warning off; % somehow there is warning log if running from GUI.
            t = Tiff(filename);
            j = 1;

            for i = frame_numbers
                if mod(j, 20)==0
                    waitbar(i/frames,h, ['Loading Frame Number ' num2str(i)]);
                end
                t.setDirectory(i);
                Aout(:,:,j) = t.read();
                if j == 1
                    Aout = repmat(Aout(:,:,1),[1,1,length(frame_numbers)]);
                end
                if filter
                    Aout(:,:,j)=medfilt2(Aout(:,:,j),[blocksize blocksize]);
                end
                j = j + 1;
            end
            t.close();
            
            if exist('h')==1 && ishandle(h)
                waitbar(1,h, 'Done');
                close(h);
            end
            warning on
        end
    end
catch
    try close(h);end
    disp(['Cannot load file: ' filename ]);
    err = 1;
    warning on;
end


% Pushes the data into cell arrays according to the number of channels read....
if splitIntoCellArray
    channels=header.acq.numberOfChannelsAcquire;
    for channelCounter=1:channels
        data{channelCounter}=Aout(:,:,channelCounter:channels:end);
    end
    Aout=data;
end

if linescan
    if iscell(Aout)
        for j=1:length(Aout)
            Aout{j}=convertStackToLS(Aout{j});
        end
    else
        Aout=convertStackToLS(Aout);
    end
end
