function radiance = get_radiance(image, depth, atmosphere)
%inputs: improved image, depth level and atmosphere
%output: radiance of the image

[m, n, ~] = size(image);

rep_atmosphere = repmat(reshape(atmosphere, [1, 1, 3]), m, n);

max_transmission = repmat(max(depth, 0.1), [1, 1, 3]);

radiance = ((image - rep_atmosphere) ./ max_transmission) + rep_atmosphere;

end
