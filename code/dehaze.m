function [radiance] = dehaze( image, omega, w_size ) 
%Generalized method to get haze
%inputs:
%   - image: original image
%   - omega: application variable
%   - w_size: window size

if ~exist('omega', 'var')       %set omega initial value as 0.95
    omega = 0.95;
end

if ~exist('w_size', 'var')      %set window size initial value as 1 
    w_size = 1;
end

[m, n, ~] = size(image);

dark_channel = get_dark_channel(image, w_size);     %Step1: get dark channel

atmosphere = get_atmosphere(image, dark_channel);   %Step1.5: get the atmosphere

depth_est = get_depth_estimate(image, atmosphere, omega, w_size);   %Step 2: estimate depth level

x = guided_filter(rgb2gray(image), depth_est, 15, 0.001);   %Step 3: Implemeting guided filter

depth = reshape(x, m, n);

radiance = get_radiance(image, depth, atmosphere);  %Last step: get radiance

end

