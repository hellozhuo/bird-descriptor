function sampleIn = samp_prepro(sampleIn)
% sample preprocessing
sampleIn = double(sampleIn);
sampleIn = sampleIn - mean(sampleIn(:));
% sampleIn = sampleIn / sqrt(mean(mean(sampleIn .^ 2)));
sampleIn = sampleIn / std(sampleIn(:));



