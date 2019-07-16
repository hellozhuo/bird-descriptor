% output objective value

function [W, objective] = cbfd_learn_o(X, binsize, n_iter,lambda1,lambda2)
% Find a projection matrix using CBFD algorithm 
% Input: 
%       X: N*d PDV Matrix
%       binsize: binary code length
%       n_iter: number of iterations
%       lambda1, lambda2: control parameters
% Output:
%       W: d*K Projection matrix 


%--- Initialize
[nSmp, ~] = size(X);
M = mean(X,1);
data = (X - repmat(M,nSmp,1));
[eigvec, eigval] = eig(data'*data);
[~,I] = sort(diag(eigval),'descend');
Wo = eigvec(:,I(1:binsize));

%--- 2-stage method
opts.record = 0;
opts.mxitr  = 1000;
opts.xtol = 1e-5;
opts.gtol = 1e-5;
opts.ftol = 1e-8;

W = Wo;
M = repmat(M,nSmp,1);
Xtmp = X'*ones(nSmp,1);
Q = (-X'*X - 2*X'*M + M'*M)/nSmp + lambda2*(Xtmp*Xtmp')/nSmp;
% n_del = 0;
objective = zeros(n_iter, 4);
for iter=1:n_iter
    % fix W. update B
    B = double(X*W >0) - 0.5;
    objective(iter, :) = get_objective(B, W, M, X, lambda1, lambda2);    
    
    % fix B. update W.
    F1 = Q + lambda1*(X'*X)/nSmp;
    F2 = -lambda1*2*X'*B/nSmp - lambda2*X'*ones(nSmp,1)*ones(1,binsize)/nSmp; 
    
    [W, ~]= OptStiefelGBB(W, @myfun,opts,F1,F2');
%     fprintf(repmat('\b', 1, n_del));
    msg = sprintf('learn CBFD iter %d\n',iter);
    fprintf(msg);
%     n_del = numel(msg);
end
end

function [F, G] = myfun(W,M,N)
    F = trace(W'*M*W) + trace(N*W);
    G = 2*M*W + N';
end

function ob = get_objective(B, W, M, X, lambda1, lambda2)
% M -- N x D
% W -- D x K 
% B -- N x K 
% X -- N x D
N = size(X, 1);
ob = zeros(1, 4);

U = M * W; % N x K
ob(1) = -trace((B - U)' * (B - U)) / N; % J1
ob(2) = ((norm((B - 0.5) - X * W, 'fro'))^2) / N; % J2
ob(3) = ((norm((B - 0.5)' * ones(N, 1), 'fro'))^2) / N; % J3

ob(4) = ob(1) + lambda1 * ob(2) + lambda2 * ob(3);
end