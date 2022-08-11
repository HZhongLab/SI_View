function improfileOpts = h_getImprofileOpts(handles)

[currentInd, handles, currentStruct, currentStructName] = h_getCurrendInd3(handles);

if isfield(currentStruct.state, 'lineWidthOpt')
    switch currentStruct.state.lineWidthOpt.value
        case {1, 5}
            improfileOpts.lineWidth = 5;
        case 2
            improfileOpts.lineWidth = 1;
        case 3
            improfileOpts.lineWidth = 2;        
        case 4
            improfileOpts.lineWidth = 3;        
        case 6
            improfileOpts.lineWidth = 7;        
        case 7
            improfileOpts.lineWidth = 9;        
        case 8
            improfileOpts.lineWidth = 12;        
        case 9
            improfileOpts.lineWidth = 15;        
        case 10
            improfileOpts.lineWidth = 19;              
        otherwise
            improfileOpts.lineWidth = 5;
    end
else % this can happen before it was set for the first time.
    improfileOpts.lineWidth = 5;
end

improfileOpts.holdOnOpt = get(handles.improfileHoldOpt, 'value');
str = get(handles.improfilePlotOpt, 'String');
value = get(handles.improfilePlotOpt, 'Value');
if value==1
    improfileOpts.plotOpt = '';
else
    improfileOpts.plotOpt = str{value};
end
