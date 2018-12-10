function sum_img = window_sum_filter(image, r)
%helper function used to creates and sum up filters

[h, w] = size(image);
sum_img = zeros(size(image));

% y axis
im_cum = cumsum(image, 1);

sum_img(1:r+1, :) = im_cum(1+r:2*r+1, :);
sum_img(r+2:h-r, :) = im_cum(2*r+2:h, :) - im_cum(1:h-2*r-1, :);
sum_img(h-r+1:h, :) = repmat(im_cum(h, :), [r, 1]) - im_cum(h-2*r:h-r-1, :);

% x axis
im_cum = cumsum(sum_img, 2);

sum_img(:, 1:r+1) = im_cum(:, 1+r:2*r+1);
sum_img(:, r+2:w-r) = im_cum(:, 2*r+2:w) - im_cum(:, 1:w-2*r-1);
sum_img(:, w-r+1:w) = repmat(im_cum(:, w), [1, r]) - im_cum(:, w-2*r:w-r-1);

end

