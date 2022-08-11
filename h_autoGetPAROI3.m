function out = h_autoGetPAROI3(header)

pos = eval([header.init.eom.powerBoxNormCoords]);
if ~isempty(pos)
    if size(pos,1) == 2
        beam = 2;
    else
        beam = 1;
    end
    pos = pos(beam,:);
    pos([1,3]) = pos([1,3]) * header.acq.pixelsPerLine;
    pos([2,4]) = pos([2,4]) * header.acq.linesPerFrame;
    pos = round(pos);
    
    out.x_start = pos(1);
    out.x_end = pos(1) + pos(3);
    out.y_start = pos(2);
    out.y_end = pos(2) + pos(4);
    out.xyBW = roipoly(zeros(header.acq.linesPerFrame, header.acq.pixelsPerLine), ...
        [out.x_start, out.x_end, out.x_end, out.x_start, out.x_start], ...
        [out.y_start, out.y_start, out.y_end, out.y_end, out.y_start]);
    if pos(4)==1
        out.y_start = pos(2) - 3;
        out.y_end = pos(2) + 3;
        out.isLine = 1;
    else
        out.isLine = 0;
        out.y_start = pos(2);
        out.y_end = pos(2) + pos(4);
    end
    out.z_start = double(header.init.eom.startFrameArray(2));
%     z_start = z_start(beam);
    out.z_end = double(header.init.eom.endFrameArray(2));
%     z_end = z_end(beam);
    out.pixelsPerLine = header.acq.pixelsPerLine;
    out.linesPerFrame = header.acq.linesPerFrame;
    out.msPerLine = header.acq.msPerLine;
else
    out = [];
    disp('No power box infomation available');
    return
end

