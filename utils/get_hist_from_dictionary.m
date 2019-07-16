% Tmp: raw features
% B: dictionary derived from k-means

% block_fae: histogram of raw features on B

function block_fea = get_hist_from_dictionary(Tmp,B, method)

if nargin < 3
    method = 'kmeans';
end

if strcmp(method, 'dominance')
    dict_size = size(B,1);
    dist_mat = sp_dist2(Tmp, B);
    [min_value, min_ind] = min(dist_mat, [], 2);
    min_ind(min_value > 1e-6) = dict_size + 1;
    block_fea = hist(min_ind, 1: dict_size + 1);    
else
    dict_size = size(B,1);
    dist_mat = sp_dist2(Tmp, B);
%     dist_mat = pdist2(Tmp, B, 'hamming');    
    [~, min_ind] = min(dist_mat, [], 2);
%     [~, min_ind] = pdist2(B, Tmp, 'hamming', 'Smallest', 1);
    block_fea = hist(min_ind, 1:dict_size); 
end

if(sum(block_fea)~=0)
    block_fea = block_fea ./ sum(block_fea);
    % why give this sqrt?
%     block_fea = nthroot(block_fea, 3);
    block_fea = sqrt(block_fea);
end 

end

