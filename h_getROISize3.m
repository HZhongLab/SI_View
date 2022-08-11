function ROI_siz = h_getROISize3(str)


ind = horzcat(strfind(str, 'x'), strfind(str, 'X'), strfind(str, ','));
if numel(ind) == 1
    ROI_siz(1) = str2double(str(1:ind-1));
    ROI_siz(2) = str2double(str(ind+1:end));
elseif numel(ind)==0
    ROI_siz = [str2double(str), str2double(str)];
else %more than 1 give error
    ROI_siz = [16, 16];
end
if any(isnan(ROI_siz))
    ROI_siz = [16, 16]; %if not meaningful number, set to default.
end


% Below was the old code using value.
% switch value
%     case {1, 9}
%         ROI_siz = 16;
%     case {2}
%         ROI_siz = 1;
%     case {3}
%         ROI_siz = 2;
%     case {4}
%         ROI_siz = 3;
%     case {5}
%         ROI_siz = 5;
%     case {6}
%         ROI_siz = 7;
%     case {7}
%         ROI_siz = 10;
%     case {8}
%         ROI_siz = 13;
%     case {10}
%         ROI_siz = 20;
%     case {11}
%         ROI_siz = 25;
%     case {12}
%         ROI_siz = 30;
%     case {13}
%         ROI_siz = 40;
%     case {14}
%         ROI_siz = 50;
%     case {15}
%         ROI_siz = 60;
%     case {16}
%         ROI_siz = 80;
%     case {17}
%         ROI_siz = 100;
%     case {18}
%         ROI_siz = 120;
%     case {19}
%         ROI_siz = 150;
%     case {20}
%         ROI_siz = 180;
%     case {21}
%         ROI_siz = 210;
%     case {22}
%         ROI_siz = 250;
%     case {23}
%         ROI_siz = 300;
%     case {24}
%         ROI_siz = 350;
%     case {25}
%         ROI_siz = 400;
%     case {26}
%         ROI_siz = 500;
%     case {27}
%         ROI_siz = 600;
%     case {28}
%         ROI_siz = 700;
%     case {29}
%         ROI_siz = 800;    
%     otherwise
% end