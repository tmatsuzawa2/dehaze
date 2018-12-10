function q = guided_filter(guide, target, radius, eps)

% Algorithm used from "Fast Guided Filter" (Algorithm 1)
% Cited: arXiv:1505.00996v1 [cs.CV] 
%   - guidance image: guide (should be a gray-scale image)
%   - filtering input image: target (should be a gray-scale image)
%   - window radius: radius
%   - regularization parameter: eps

[h, w] = size(guide);

avg = window_sum_filter(ones(h, w), radius);

mean_g = window_sum_filter(guide, radius) ./ avg;
mean_t = window_sum_filter(target, radius) ./ avg;

corr_gg = window_sum_filter(guide .* guide, radius) ./ avg;
corr_gt = window_sum_filter(guide .* target, radius) ./ avg;

var_g = corr_gg - mean_g .* mean_g;
cov_gt = corr_gt - mean_g .* mean_t;

a = cov_gt ./ (var_g + eps);
b = mean_t - a .* mean_g;

mean_a = window_sum_filter(a, radius) ./ avg;
mean_b = window_sum_filter(b, radius) ./ avg;

q = mean_a .* guide + mean_b;

end