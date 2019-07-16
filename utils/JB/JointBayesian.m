function [A, G] = JointBayesian(X, labels)


    m = length(labels);
    n = size(X,2);
	
	% Make sure labels are nice
	[classes, ~, labels] = unique(labels);
    nc = length(classes);
    
    cur = cell(nc, 1);
    withinCount = 0;
    numberBuff = false(m,1);
    maxNumberInOneClass = 0;
    for i=1:nc
        % Get all instances with class i
        cur{i} = X(labels == i,:);
        if size(cur{i},1)>1
            withinCount = withinCount + size(cur{i},1);
        end
        if numberBuff(size(cur{i},1)) == false
            numberBuff(size(cur{i},1)) = true;
            maxNumberInOneClass = max(maxNumberInOneClass, size(cur{i}, 1));
        end
    end
    numberBuff = numberBuff(1: maxNumberInOneClass);

    tic;
    u = zeros(n,nc);
    ep = zeros(n,withinCount);
    nowp = 1;
	% Sum over classes
    for i = 1: nc
        % Update within-class scatter
        u(:,i) = mean(cur{i},1)';
        if size(cur{i},1)>1
            ep(:,nowp:nowp+ size(cur{i}, 1)-1) = bsxfun(@minus,cur{i}',u(:,i));
            nowp = nowp + size(cur{i}, 1);
        end
    end
    
    Su = cov(u');
    Sw = cov(ep');
    toc;
    
    oldSw = Sw;
    SuFG = cell(maxNumberInOneClass,1);
    SwG = cell(maxNumberInOneClass,1);
    
    for l=1:500
%         tic;
        F = inv(Sw);
        ep =zeros(n,m);
        nowp = 1;
        for g = 1: maxNumberInOneClass
            if numberBuff(g)==1
                G = -1 .* (g .* Su + Sw) \ Su / Sw;
                SuFG{g} = Su * (F + g.*G);
                SwG{g} = Sw*G;
            end
        end
        for i=1:nc
            nnc = size(cur{i}, 1);
            u(:,i) = sum(SuFG{nnc} * cur{i}',2);
            ep(:,nowp:nowp+ size(cur{i}, 1)-1) = bsxfun(@plus,cur{i}',sum(SwG{nnc}*cur{i}',2));
            nowp = nowp+ nnc;
        end
        Su = cov(u');
        Sw = cov(ep');

        convergence = norm(Sw - oldSw)/norm(Sw);
        fprintf('%d %f\n',l, convergence);
%         toc;
        if convergence<1e-6
            break;
        end
        oldSw = Sw;
    end
    F = inv(Sw);
    G = -1 .* (2 * Su + Sw) \ Su / Sw;
    A = inv(Su + Sw) - (F + G);
    
%     mapping.Sw = Sw;
%     mapping.Su = Su;
%     mapping.c = zeros(m,1);
%     for i = 1:m
%         mapping.c(i) = X(i,:) * mapping.A * X(i,:)';
%     end
%     mappedX = X;
   