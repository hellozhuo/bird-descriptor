function [W, mu] = ldafaces(X,y,k)
  % number of samples
  % number of classes
  labels = unique(y);
  c = length(labels);
  if(nargin < 3)
    k = c-1;
  end
  k = min(k,(c-1));
  % get (N-c) principal components
  [W, mu] = lda(X, y, k);
end
