function [FWHM, pos] = h_findFWHM(ydata, thresh)

if ~exist('thresh','var')||isempty(thresh)
    thresh = 0.5;
end

[maxY,I] = max(ydata);
labelY = bwlabel(ydata>thresh*maxY);
peak_ind = find(labelY==labelY(I));
% pos(1) = sum(ydata(peak_ind(1)-1:peak_ind(1)) .* [peak_ind(1)-1:peak_ind(1)]') / sum(ydata(peak_ind(1)-1:peak_ind(1)));
% pos(2) = sum(ydata(peak_ind(end):peak_ind(end)+1) .* [peak_ind(end):peak_ind(end)+1]') / sum(ydata(peak_ind(end):peak_ind(end)+1));
pos(1) = 1/diff(ydata(peak_ind(1)-1:peak_ind(1)))*(thresh*maxY-ydata(peak_ind(1)-1))+ peak_ind(1)-1;
pos(2) = 1/diff(ydata(peak_ind(end):peak_ind(end)+1))*(thresh*maxY-ydata(peak_ind(end)))+ peak_ind(end);
FWHM = diff(pos);


