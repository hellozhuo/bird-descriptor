% author: zhuo.su@oulu.fi
% date: 11.04.2019
% function: get histogram of lbp full
%
% [In]
% pdv: N x pdv_dim -- value with 0 or 1, double


function his = get_hist_of_full(pdv)

pdv_dim = size(pdv, 2);

if pdv_dim > 16
    assert('the dimension of pdv (%d) is too big to construct a full codebook\n', pdv_dim);
end

pdv_de = bi2de(pdv);

upper = 2^pdv_dim - 1;
his = hist(pdv_de, 0: upper);
his = his ./ sum(his);
his = sqrt(his);
