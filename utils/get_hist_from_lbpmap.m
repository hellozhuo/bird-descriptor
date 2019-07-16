
function his = get_hist_from_lbpmap(pdv, map)

pdv_de = bi2de(pdv);
num_points = length(pdv_de);

if size(pdv, 2) <= 16
    assert(isstruct(map));
    num_bin = map.num;
    for i = 1: num_points
        pdv_de(i) = map.table(pdv_de(i) + 1);
    end
else
    assert(size(map, 1) == 1 || size(map, 2) == 1)
    [~, ind] = ismember(pdv_de, map);
    num_bin = length(map) + 1;
    pdv_de = ind;
end

his = hist(pdv_de, 0: num_bin - 1);
his = his ./ sum(his);
his = sqrt(his);
