
function [list, list_part] = generate_list(array)

% array: 1 x N array 
n = length(array);
num = 0;
for i = 1: n
    num = num + nchoosek(n, i);
end
list = cell(1, num);
count = 1;
list_part = cell(1, n);

for i = 1: n
    c = nchoosek(array, i);
    list_part{i} = count: count + size(c, 1) - 1;
    for j = 1: size(c, 1)
        list{count} = c(j, :);
        count = count + 1;
    end
end