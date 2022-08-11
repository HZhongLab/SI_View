function [header] = jbm_parseHeader(fn)

imginfo = imfinfo(fn);
imginfo = imginfo.ImageDescription;
input = imginfo;


tempstring = {};
index = 0;
tempcell = strread(input, '%q');

for lineCounter = 1 : length(tempcell)
    data = tempcell{lineCounter};
    if strncmp(data, 'state.', 6)
        index = index + 1;
        tempstring{index} = data;
    else
        tempstring{index} = [tempstring{index} ' ' data];
    end
end

for i = 1 : index
    data = tempstring{i};
    equal = findstr('=', data);
    param = data(7 : equal-1);
    if length(data) == equal
        val = [];
    else
        if data(equal+1)=='''' & data(end)==''''
            % string
            val = data(equal+2 : end-1);
        else
            % double
            val = str2num(data(equal+1 : end));
        end
    end
    eval(['header.' param '=val;']);
end





end

