function [W] = pca_learn(X, binsize)
% Find a projection matrix using CBFD algorithm 
% Input: 
%       X: N*d PDV Matrix
%       binsize: binary code length
% Output:
%       W: d*K Projection matrix 


%--- Initialize
[nSmp, ~] = size(X);
M = mean(X,1);
X = (X - repmat(M,nSmp,1));
[eigvec, eigval] = eig(X'*X);
[~,I] = sort(diag(eigval),'descend');
W = eigvec(:,I(1:binsize));