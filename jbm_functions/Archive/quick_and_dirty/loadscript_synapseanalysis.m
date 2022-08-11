
sad = synapseAnalysisData

day = 1

data = sad.dataMatrix
xco = sad.xCoordinates(:,day)
yco = sad.yCoordinates(:,day)


global h_img3
caxes = h_img3.I1.gh.currentHandles.imageAxes;

for i = 1:length(text)
    viscircles(caxes,[xco(i) yco(i)],2,'EdgeColor','b');
end
