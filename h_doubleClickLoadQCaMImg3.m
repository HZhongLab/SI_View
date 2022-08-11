function h_doubleClickLoadQCaMImg3

UserData = get(gco,'UserData');
t0 = clock;
if ~isfield(UserData,'timeLastClick') || ~(etime(t0,UserData.timeLastClick) < 0.4)
%     disp(etime(t0,UserData.timeLastClick))
    UserData.timeLastClick = t0;
    set(gco,'UserData',UserData);
    return;
else
    UserData.timeLastClick = 0*t0;%reset the click time.
    set(gco,'UserData',UserData);
    point1 = get(gca,'CurrentPoint'); 
    point1 = point1(1,1:2);
    currentFrameNumber = round(point1(1));
    img = flipdim(rot90(read_qcamraw(UserData.fname, currentFrameNumber)),1);
    siz = size(img);
    deltaX = max(UserData.xi) - min(UserData.xi);
    xRange = round(min(UserData.xi) - deltaX):round(max(UserData.xi) + deltaX);
    xRange(xRange<1) = 1;
    xRange(xRange>siz(2)) = siz(2);
    deltaY = max(UserData.yi) - min(UserData.yi);
    yRange = round(min(UserData.yi) - deltaY):round(max(UserData.yi) + deltaY);
    yRange(yRange<1) = 1;
    yRange(yRange>siz(1)) = siz(1);
    figure, h = h_imagesc(img(yRange,xRange));
    hold on, plot((UserData.xi-min(UserData.xi)+deltaX),(UserData.yi-min(UserData.yi)+deltaY));

    x = (min(UserData.xi) + max(UserData.xi))/2;
    y = (min(UserData.yi) + max(UserData.yi))/2;
    text(x-min(UserData.xi)+deltaX,y-min(UserData.yi)+deltaY,num2str(UserData.roiNumber),'HorizontalAlignment', 'Center','VerticalAlignment','Middle', ...
        'Color','black', 'EraseMode','xor','ButtonDownFcn', 'h_dragRoiText3','FontSize', 14, 'FontWeight', 'Bold');

end