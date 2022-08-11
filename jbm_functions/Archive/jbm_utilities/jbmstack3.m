function handles = jbmstack(num_open)

if num_open > 8
    fprintf('Please select a number between 1 and 8');
    return
end

pos1 = [15 567 655 451];
pos3 = [15 50 655 451];
pos2 = [700 567 655 451];
pos4 = [700 50 655 451];
pos6 = [885 434 655 451];;
pos5 = [885 434 655 451];
pos8 = [885 434 655 451];;
pos7 = pos5; 

h1 = h_imstack3;
h2 = h_imstack3;
h3 = h_imstack3;
h4 = h_imstack3;
h5 = h_imstack3;
h6 = h_imstack3;
h7 = h_imstack3;
h8 = h_imstack3;

set(h1,'Position',pos1);
set(h2,'Position',pos2);
set(h3,'Position',pos3);
set(h4,'Position',pos4);
set(h5,'Position',pos5);
set(h6,'Position',pos6);
set(h7,'Position',pos7);
set(h8,'Position',pos8);

handles(1) = h1;
handles(2) = h2;
handles(3) = h3;
handles(4) = h4;
handles(5) = h5;
handles(6) = h6;
handles(7) = h7;
handles(8) = h8;

if num_open < 8
    num_to_close = 8 - num_open;
    for i = 1:num_to_close
        close(handles(8-i+1));
        handles(8-i+1) = [];
    end
else
    
end

assignin('base','jbmstack_handles',handles);