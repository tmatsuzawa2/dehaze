image = double(imread('dehaze_01.jpg'))/255;

image = imresize(image, 0.8);

result = dehaze(image, 0.95, 1);

figure, imshow(image)
figure, imshow(result)
