%% get raw pdv
% author: zhuo.su@oulu.fi
% date: 6.11.2018
%
% [IN]
% image: a gray scale image set
%
% paras: the pair (name, value) contructed in a struct, which can be the following 
%
% name(field)  value
%
% 'lbp'     [r, p]
% 
% 'rd'      [r1, r2, p]
%
% 'ad'      [r, p]
%
% 'concat'  'pdv-level': concatenate single pdvs into a whole pdv, 
%           'his-level': concatenate the histograms derived from single pdvs into a whole histogram,
%            default: 'pdv-level'
%            NOTE: now we only have the 'pdv-level' implementation
% 
% 'split'   [M, N]: split the image into M * N regions
%
%
% [OUT]
% dictionary
%
% paras: the modified paras
%%

function pdv = get_concat_lm_pdv(image, image_lm, paras)

if ~isstruct(paras)
    error('please input a struct');
end

% tic;
%% step1: extract concatenated pdv
% first, preprocess
if paras.preprocess
    image = preproc2(double(image),0.2,1,2,[],[],10);
end

% second, extract pdv using the max_radius
if(isfield(paras, 'lbp'))
    % extract pdv for lbp
    pdv_single.lbp = produce_pdv_lbp(image, paras, image_lm);  
end
if(isfield(paras, 'rd'))
    % extract pdv for rd
    pdv_single.rd = produce_pdv_rd(image, paras, image_lm);
end
if(isfield(paras, 'ad'))
    % extract pdv for ad
    pdv_single.ad = produce_pdv_ad(image, paras, image_lm);
end

% third, concatenate pdv from 'lbp', 'rd' and 'ad'
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




    


