%% produce pixel difference vector for radius difference lbp
% author: zhuo.su@oulu.fi
% date: 25.10.2018
%
% [IN]
% image: a gray scale image
%
% para: a list of [radius, neighbors] parameters, e.g., [1, 8; 2, 16]
%
% split: =[rows_split, cols_split], indicates spliting the image into 
% rows_split * cols_split regions
%
% 'sort': sort the pdv
%
% 'binary': extract binary pdv
%
% [OUT]
% a cell of pixel difference vector pdv w.r.t. the para, where pdv{i, j}
% indicates the pixel difference vector extracted from the (i,j)th region
%%

function pdv = produce_pdv_ad(image, paras, image_lm)

pa = extract_pa(paras, 1);
if pa.mark < 1
    if nargin > 2
        pdv_tmp = ADLBP_S(image, pa, image_lm);
    else
        pdv_tmp = ADLBP_S(image, pa);
    end
else
    if nargin > 2
        pdv_tmp = ADLBP_M(image, pa, image_lm);
    else
        pdv_tmp = ADLBP_M(image, pa);
    end
end

scale_num = size(paras.ad, 1);
if scale_num == 1
    pdv = pdv_tmp;
else
    [num_points, dim] = size(pdv_tmp{1, 1});
    pdv = cell(paras.div(1), paras.div(2));
    for i = 1: paras.div(1)
        for j = 1: paras.div(2)
            pdv{i, j} = zeros(num_points, sum(paras.ad(:, 5)));
            pdv{i, j}(:, 1: dim) = pdv_tmp{i, j};
        end
    end
    count = dim;
    for sca_i = 2: scale_num
        pa = extract_pa(paras, sca_i);
        if pa.mark < 1
            if nargin > 2
                pdv_tmp = ADLBP_S(image, pa, image_lm);
            else
                pdv_tmp = ADLBP_S(image, pa);
            end
        else
            if nargin > 2
                pdv_tmp = ADLBP_M(image, pa, image_lm);
            else
                pdv_tmp = ADLBP_M(image, pa);
            end
        end
        for i = 1: paras.div(1)
            for j = 1: paras.div(2)
                pdv{i, j}(:, count + 1: count + size(pdv_tmp{1, 1}, 2)) = pdv_tmp{i, j};
            end
        end
        count = count + size(pdv_tmp{1, 1}, 2);
    end
end

end

function pa = extract_pa(paras, index)

% lbp: [S_or_M, r, delta, q, bit]
% S_or_M: 0 -- calculating RDLBP_S, 1 -- calculating RDLBP_M
info = paras.ad(index, :);
pa.mark = info(1);
pa.r = info(2);
pa.delta = info(3);
pa.q = info(4);
pa.bit = info(5);
pa.div = paras.div;
pa.max_r = paras.max_r;
pa.binary = paras.binary;
pa.sort = paras.sort;
pa.step = paras.step;

end

    