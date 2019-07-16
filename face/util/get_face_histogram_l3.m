% author: zhuo.su@oulu.fi
% date: 6.11.2018
% function: level 3, get the histogram for a single image
%
% [IN]
% paras: parameters used in model and for feature extraction
%
% image: the inputed image
%
% model: trained model for feature extraction
%
% [OUT]
% histogram: the extracted feature vector

function histogram = get_face_histogram_l3(paras, image, model)

%% step1: extract concatenated raw pdv
if strcmp(paras.method, 'brief')
    paras.pairs = model.pairs;
end
raw_pdv = get_concat_pdv(paras, image);

%% step2, get histgram
if ismember(paras.method, {'cbfd', 'pca', 'rp', 'kmeans', 'brief'})
    W = model.W{paras.region_index};
    dictionary = model.dictionary{paras.region_index};
    if strcmp(paras.kmeans_type, 'real-euc')
        projected_pdv = raw_pdv * W;
    else
        projected_pdv = double(raw_pdv * W > 0);
    end
    histogram = get_hist_from_dictionary(projected_pdv, dictionary);
elseif ismember(paras.method, {'lbp_riu2', 'lbp_u2'})
    dictionary = model.dictionary;
    if isfield(paras, 'lbp')
        bits = paras.lbp(:, end);
    elseif isfield(paras, 'rd')
        bits = paras.rd(:, end);
    elseif isfield(paras, 'ad')
        bits = paras.ad(:, end);
    end
    assert(sum(bits) == size(raw_pdv, 2), 'the dimension of pdv does not match paras\n');

    bias = 0;
    histogram = zeros(1, dictionary.his_dim);
    bias_his = 0;
    for j = 1: length(bits)
        bit = bits(j);
        pdv_bit = raw_pdv(:, bias + 1: bias + bit);
        pdv_bit = double(pdv_bit > 0);
        tmp = get_hist_from_lbpmap(pdv_bit, dictionary.maps{j});
        bias = bias + bit;
        histogram(bias_his + 1: bias_his + length(tmp)) = tmp;
        bias_his = bias_his + length(tmp);
    end
elseif strcmp(paras.method, 'full')
    if isfield(paras, 'lbp')
        bits = paras.lbp(:, end);
    elseif isfield(paras, 'rd')
        bits = paras.rd(:, end);
    elseif isfield(paras, 'ad')
        bits = paras.ad(:, end);
    end
    assert(sum(bits) == size(raw_pdv, 2), 'the dimension of pdv does not match paras\n');

    bias = 0;
    histogram = zeros(1, sum(2.^bits));
    bias_his = 0;
    for j = 1: length(bits)
        bit = bits(j);
        pdv_bit = raw_pdv(:, bias + 1: bias + bit);
        pdv_bit = double(pdv_bit > 0);
        tmp = get_hist_of_full(pdv_bit);
        bias = bias + bit;
        histogram(bias_his + 1: bias_his + length(tmp)) = tmp;
        bias_his = bias_his + length(tmp);
    end
end




    


