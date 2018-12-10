# Image Dehazing

Images obtained under adverse weather conditions, such as haze or fog, typically exhibit low contrast and faded colors, which may severely limit the visibility within the scene. 

Unveiling the image structure under the haze layer and recovering vivid colors out of a single image remains a challenging task, since the degradation is depth-dependent and conventional methods are unable to overcome this problem.

In this project, we will be trying haze removal so that more information can be restored and displayed. The feature is mainly used to remove fog and haze from the original and produce the actual clear images. Instead of using contrast slider, dehaze slider functions by targeting the lower-contrast areas of the scene and applying the bulk of its effects there. Therefore, low contrast areas of the scene get more of the effect than high contrast areas. 

## Motivation

### 1. Importance

Dehazing techniques are commonly used in varieties of practical situations. It is one of the secret weapons used by night photographers to illustrate a better night scene; it can be used to detect dust spots in the picture, and it is also used to make scenes of milky way more three-dimensional. Furthermore, after dehazing some of the pictures that are either naturally or artificially obfuscated, photographers have noticed that the layerings and balances in color are improved significantly, and the entire scene is more appreciable. 

### 2. State-of-the-art

The most popular dehaze tool currently is Adobe Lightroom. Adobe Lightroom is an image manipulation software developed by Adobe system for Windows and macOS which allows viewing, organizing and editing a large number of images and the operations are not destructive.

Now we use an hazed image as example:

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/dehaze_01.jpg?raw=true" class="center" width="400px"/>

This is the dehazed image using Adobe Lightroom

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/Adobelightroom.JPG?raw=true" class="center" width="400px"/>

Another common way that can be used to dehaze is MATLAB, the resulted image using function imreducehaze() with 60 percent of dehazing is shown below:

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/matlab.JPG?raw=true" class="center" width="400px"/>

Comparing two different methods, the image in Lightroom has more favorable but artificial color illustrations, while the image in MATLAB has a more clear illustration that nearer from the lens (buildings in this example). However, both tools have disadvantages: Lightroom is less likely to detect depth and apply them to the dehaze slider, while MATLAB has some difficulties in detecting and erasing noises collected by the sensor.

## Approach

### 1. Re-implemeting existing solution or using new approaches?

We decided to re-implement the existing algorithm and try to refine it better.  The current MATLAB function is effective and convenient, but it might not apply to all circumstances. Perhaps we could build an interactive program that takes input from the user to generate better results. For example, users could specify the color of the haze for a more accurate result.

### 2. Reasons for change

As shown in the image above, the existing solution which is rendering image through Adobe Lightroom creates some unnatural artifacts in the sky. Adobe Lightroom seems to be generating the incorrect information to compensate for the lost detail in the haze. We are working on an alternative solution to either better reserve the original information or find a better way to fill in the missing pieces. We speculate that the image would look better if we remove the noises in the sky using something like a Gaussian filter.

Furthermore, if you look closely at the buildings in the picture, there is clearly remaining haze. It appears that Adobe Lightroom applies the same intensity of dehaze filter to every area of the picture. This method overlooked the fact that areas with different depths generate different amount of haze. 

To determine the intensity of the haze, there is a popular method called “dark channel prior.” This method uses a certain supposedly low-intensity channel to detect the intensity of haze. If the intensity of the channel is abnormally high, chances are this pixel is affected by haze.

After we estimated the depth of each pixel, a simple formula should give us the estimation of haze in each pixel. Restoring the original image should be as easy as readjusting the RGB value. Adjust more for further pixels and less for nearer pixels.

## Implementation

### Step 1: Dark Channel
                                                 
```markdown
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

```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Step 1.5: Atmosphere

Atmosphere here is defined by the amounts of atmospheric light reflected/existed in each pixel of an image. The reason of the method get_atmosphere is to use in later step when we are estimating depth levels.

```markdown
function atmosphere = get_atmosphere(image, dark_channel)
%inputs: original image and window size, image of the dark channel 
%outputs: image of the atmosphere using dark channel

[m, n, ~] = size(image);    
n_pixels = m * n;           

n_search_pixels = floor(n_pixels * 0.01);   

dark_vec = reshape(dark_channel, n_pixels, 1);

image_vec = reshape(image, n_pixels, 3);

[~, indices] = sort(dark_vec, 'descend');

accumulator = zeros(1, 3);                     

for k = 1 : n_search_pixels
    accumulator = accumulator + image_vec(indices(k),:);
end

atmosphere = accumulator / n_search_pixels;

end

```
As the code implemented above, we basically sorted the dark channels in descending order and use them as indices of the image. And atmosphere at a certain pixel can be defined as image[new dark_channel] 

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
