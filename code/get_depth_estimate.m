function depth_est = get_depth_estimate(image, atmosphere, omega, w_size)
%   - original image: image
%   - result get from get_atmosphere: atmosphere
%   - software variable: omega
%   - window size: w_size

[m, n, ~] = size(image);

rep_atmosphere = repmat(reshape(atmosphere, [1, 1, 3]), m, n);

depth_est = 1 - omega * get_dark_channel( image ./ rep_atmosphere, w_size);

end
