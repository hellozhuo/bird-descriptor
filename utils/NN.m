function [acc, d1] = NN(x_tr,labels, x_ts, testlabels,type)

%% Euclidean distance metric
ntest =  size(x_ts, 1);
% ntrain = size(x_tr, 1);

if type==1
    d1 = pdist2(x_ts, x_tr, 'euclidean');
else
    d1 = pdist2(x_ts,x_tr,'cosine');
end

[~, min_ind] = min(d1, [], 2);
gnd_pred = uint32(zeros(size(testlabels)));
labels = uint32(labels);
for i = 1: ntest
    gnd_pred(i) = labels(min_ind(i));
end

acc = sum(gnd_pred==testlabels)*100/ntest;
end