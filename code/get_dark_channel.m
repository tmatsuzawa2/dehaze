function dark_channel = get_dark_channel(image, w_size)
%inputs: original image and window size
%output: image of the dark channel 

[x, y, ~] = size(image);        %size of the image

pad_size = floor(w_size/2);     %pad size using value of window size

padded_image = padarray(image, [pad_size pad_size], Inf);   %pad the image according to pad size

dark_channel = zeros(x, y); 

%For every pixel(i,j) in the image, find out the darkest point within the
%range of (i ± window size, j ± window size)
for j = 1 : x
    for i = 1 : y
        patch = padded_image(j : j + (w_size-1), i : i + (w_size-1), :);
        dark_channel(j,i) = min(patch(:));
     end
end

end

