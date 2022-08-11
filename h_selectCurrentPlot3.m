function h_selectCurrentPlot3

h = findobj('Tag','h_imstack3Plot');
set(h,'Selected','off');
set(gcf,'Selected','on');