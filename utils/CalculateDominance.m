% date: 11.11.2018

function [dom_patterns, num_patterns] = CalculateDominance(pdv, thres)

pdv_value = bi2de(pdv);

points = size(pdv, 2);

distribute = hist(pdv_value, 0: (2 ^ points - 1));
[distribute, index] = sort(distribute, 'descend');

thres = sum(distribute) * thres;
percentage = 0;
for i = 1: length(index)
    percentage = percentage + distribute(i);
    if percentage > thres
        num_patterns = i;
        break;
    end
end

dom_patterns = distribute(1: num_patterns);
dom_patterns = de2bi(dom_patterns, points);


