function h_searchAndRemoveFromGroup3(handles)

global h_img3;

UData = get(handles.h_searchForGroupGUI3, 'UserData');
structName = ['I', num2str(UData.instanceInd)];

pathname = get(handles.pathName,'String');
basename = get(handles.fileBasename,'String');
fileExtension = get(handles.fileExtensionOpt,'String');
if get(handles.searchSubdirOpt,'Value')
    searchOpt = '/s';
else
    searchOpt = '';
end
fileNumbers = get(handles.fileNumbers,'String');
if strcmpi(fileNumbers,'all')
    str = {'*'};
else
    numbers = eval(['[',fileNumbers,']']);
    str = {};
    for i = 1:length(numbers)
        str1 = '000';
        str2 = num2str(numbers(i));
        str1(end-length(str2)+1:end) = str2;
        str(i,1) = {str1};
    end
end

files = [];
for i = 1:length(str)
    filename = [basename,str{i},fileExtension];
    files = [files;h_dir(fullfile(pathname,filename),searchOpt)];
end

I = [];
for i = 1:length(files)
    if strfind(files(i).name,'max.')
        I = [I,i];
    end
end

maxOpt = get(handles.maxOpt,'Value');    
if maxOpt
    files = files(I);
else
    files(I) = [];
end

% get rid of any files immediately under 'spc' folder.
I2 = [];
for i = 1:length(files)
    pname1 = fileparts(files(i).name);
    [pname2, fname2, fExt2] = fileparts(pname1);
    %     if strfind(files(i).name,'\spc\')
    if strcmpi(fname2, 'spc')
        I2 = [I2,i];
    end
end
files(I2) = [];

for i = 1:length(files)
    h_removeFromCurrentGroup3(h_img3.(structName).gh.currentHandles, files(i).name);
end
close(handles.h_searchForGroupGUI3);
h_updateInfo3(h_img3.(structName).gh.currentHandles);