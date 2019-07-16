% author: zhuo.su@oulu.fi
% date: 6.11.2018
% function: get original extended pdv (for lbp, ad, rd) according to paras
%
% [IN]
% paras: parameters to extract original extended pdv, specifically,
%       paras.lbp --> extract basic pdv, with parameter form [type, radius, [q], bit]
%       paras.rd --> extract rd pdv, with parameter form [type, radius, q, bit]
%       paras.ad --> extract ad pdv, with parameter form [type, radius, q, bit]
%
% image: a gray scale image
%
% [OUT]
% pdv: the extracted pdv

function pdv = get_concat_pdv(paras, image)

if ~isstruct(paras)
    error('please input a struct');
end

if(isfield(paras, 'pairs'))
    pdv = get_brief_pdv(image, paras.pairs);
    return;
end

%% step1: extract pdv using the max_radius
if(isfield(paras, 'lbp'))
    % extract pdv for lbp
    if nargin > 2
        pdv_single.lbp = produce_pdv_lbp(image, paras, image_lm);  
    else
        pdv_single.lbp = produce_pdv_lbp(image, paras);  
    end
end
if(isfield(paras, 'rd'))
    % extract pdv for rd
    if nargin > 2
        pdv_single.rd = produce_pdv_rd(image, paras, image_lm);  
    else
        pdv_single.rd = produce_pdv_rd(image, paras);  
    end
end
if(isfield(paras, 'ad'))
    % extract pdv for ad
    if nargin > 2
        pdv_single.ad = produce_pdv_ad(image, paras, image_lm);
    else
        pdv_single.ad = produce_pdv_ad(image, paras);
    end
end

%% step2, concatenate pdv from 'lbp', 'rd' and 'ad'
pdv_types = fieldnames(pdv_single);
pdv_num = numel(pdv_types);
pdv = cell(0);
if(pdv_num == 1)
    pdv = pdv_single.(pdv_types{1});
end
if(pdv_num == 2)
    [M, N] = size(pdv_single.(pdv_types{1}));
    pdv = cell(M, N);
    for row = 1: M
        for col = 1: N
            pdv{row, col} = cat(2, pdv_single.(pdv_types{1}){row, col},...
                pdv_single.(pdv_types{2}){row, col});
        end
    end
end
if(pdv_num == 3)
    [M, N] = size(pdv_single.(pdv_types{1}));
    pdv = cell(M, N);
    for row = 1: M
        for col = 1: N
            pdv{row, col} = cat(2, pdv_single.(pdv_types{1}){row, col},...
                pdv_single.(pdv_types{2}){row, col},...
                pdv_single.(pdv_types{3}){row, col});
        end
    end
end

[M, N] = size(pdv);
if M * N < 2
    pdv = pdv{1};
end




    


