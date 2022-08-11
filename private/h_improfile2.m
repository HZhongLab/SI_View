function [Aout, avg_C, img] = h_improfile2(n)

%[Aout, avg_C] = h_improfile2(n)
%h_improfile2 mimic improfile but with an averaging function across a few lines
%n = parallel lines to average 1, 3, 5, 7... default 5

if ~exist('n','var')||isempty(n)
    n = 5;
end

Aout = [];
avg_C = [];
handle = findobj(gca,'type','image');
img = get(handle,'CData');

[xi,yi] = getline(gcf);

if length(xi)== 2
    slope = (yi(1)-yi(2))/(xi(1)-xi(2));
    angle = atand(slope);
    j = 0;
    len = sqrt(diff(xi)^2+diff(yi)^2);
    N = round(len);
    for i = [1:n]-mean(1:n)
        j = j+1;
        Aout(j).x = i*cosd(angle+90)+xi;
        Aout(j).y = i*sind(angle+90)+yi;
        Aout(j).C = improfile(img,Aout(j).x,Aout(j).y,N);
    end
    avg_C = squeeze(mean(cat(2,Aout.C),2));
    figure(332);
    line_color = {'r', 'g', 'b'};
    if size(avg_C,1)==1
        plot(avg_C, [line_color{3}, '-']);
    else
        for i=1:size(avg_C, 2)
            plot(avg_C(:,i), [line_color{i}, '-']);
            if i==1
                hold on % hold on here allow erasing earlier traces since we now always use the same window.
            end
        end
        hold off
    end
end
