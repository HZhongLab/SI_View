function esoin_batchGroupOpen(varargin)

global h_img3;

[fn,pn] = uigetfile('*.grp');
path_to_file = [pn fn];

grp = load(path_to_file,'-mat');
grp = grp.groupFiles;

num_imgs_in_group = length(grp);
jbmstack3(num_imgs_in_group); 
instances = fieldnames(h_img3);

temp = find(strcmp(instances,'common'));
if exist(temp)
    instances(temp) = []
else
end

for i = 1:length(instances)
    currentInstance = instances{i};
    h_openFile3(h_img3.(currentInstance).gh.currentHandles,grp(i).name);
end


