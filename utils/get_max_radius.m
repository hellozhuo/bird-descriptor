
% date: 11.11.2018

function max_radius = get_max_radius(paras)

if strcmp(paras.method, 'brief')
    max_radius = 5;
    return;
end

max_radius = 0;
if(isfield(paras, 'lbp'))
    max_radius_tmp = max(paras.lbp(:, 2));
    if(max_radius_tmp > max_radius)
        max_radius = max_radius_tmp;
    end 
end
if(isfield(paras, 'rd'))
    max_radius_tmp = max(paras.rd(:, 2));
    if(max_radius_tmp > max_radius)
        max_radius = max_radius_tmp;
    end 
end
if(isfield(paras, 'ad'))
    max_radius_tmp = max(paras.ad(:, 2));
    if(max_radius_tmp > max_radius)
        max_radius = max_radius_tmp;
    end 
end