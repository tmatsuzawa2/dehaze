#### Group Member: 
Xuetong Du | xdu49@wisc.edu | xdu49

Kevin Lin | klin55@wisc.edu | klin55

Takashi Matsuzawa | tmatsuzawa@wisc.edu | tmatsuzawa

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

Dark channel, the first but central part of the approaches, is a group of the dark pixels which have very low intensity in at least one color (rgb) channel. In the haze image, the intensity of these dark pixels in that channel is mainly contributed by the airlight(atmosphere). Therefore, these dark pixels can directly provide accurate estimation of the haze's transmission.
                                                 
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

As the code shown above, for finding the dark pixels, we simply just find the darkest point within the certian area of padded image. The reason that we want the image to be padded to the window size is for preventing the error around the corner, After we get the information we need, we will be able to adjust the depth estimation.

### Step 2: Atmosphere

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
As the code implemented above, we basically sorted the dark channels in descending order and use them as indices of the image. And the value of atmosphere at a certain pixel can be defined as image[new dark_channel].

### Step 3: Depth/Transmission estimation

Depth estimation is used to find out the amounts of haze in different depth levels so that pictures can be dehazed more naturally in human perception.

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/formula2.png?raw=true" class="center" width="600px"/>

Here I represents the intensity of image, and A represents the atmosphere of the image. 
ω here is an application variable between 0 and 1.

Since there is no object in the world that is completlely free of particle, human can not sense depth levels without any haze available. Therefore, it is better to choose ω less than 1 (suggested 0.95 at most).

```markdown
function depth_est = get_depth_estimate(image, atmosphere, omega, w_size)
%   - original image: image
%   - result get from get_atmosphere: atmosphere
%   - software variable: omega
%   - window size: w_size

[m, n, ~] = size(image);

rep_atmosphere = repmat(reshape(atmosphere, [1, 1, 3]), m, n);

depth_est = 1 - omega * get_dark_channel( image ./ rep_atmosphere, w_size);

end
```
### Problem: Unexpected figures

Random dark pixels in the image could create significant noise in the depth estimation image since the padded method greatly intensifies its presence.

Here is the dark channel image (padded size = 1):

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/pad1.JPG?raw=true" class="center" width="400px"/>

And here is the dark channel image (padded size = 10):

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/pad10.JPG?raw=true" class="center" width="400px"/>

Comparing two graphs and we can find out that as the padded size grew larger, unexpected figures in the original image are also enlarged and can not be ingored. Thus we are now introducing the solution: guided filter.

### Step 4: Applying filter

Here we are using an algorithm 1 refered to "Fast guided filter" by Kaiming He and Juan Sun. The main computation is a series of box filter.

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/algorithm.JPG?raw=true" class="center" width="400px"/>

Image above shows the pseudo-code of the algorithm, fmean(·, r) denotes a mean filter with a radius r.

### Step 5: Recover Radiance

The last step is to recover the radiance using atmosphere and max transmission. Here is the formula to find out the final scence radiance J(x)

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/formula3.JPG?raw=true" class="center" width="600px"/>

Where I(x) is the intensity of image, A is the atmosphere, and t(x) is the transmissions (t0 is the lower bound of t(x)).

```markdown
function radiance = get_radiance(image, depth, atmosphere)
%inputs: improved image, depth level and atmosphere
%output: radiance of the image

[m, n, ~] = size(image);

rep_atmosphere = repmat(reshape(atmosphere, [1, 1, 3]), m, n);

max_transmission = repmat(max(depth, 0.1), [1, 1, 3]);

radiance = ((image - rep_atmosphere) ./ max_transmission) + rep_atmosphere;

end
```


## Result

### Original Image

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/dehaze_01.jpg?raw=true" width="400px"/>

### Dark Channel Image

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/dark_channel.JPG?raw=true" width="400px"/>

### Depth Transmission Image

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/depth.JPG?raw=true" width="400px"/>

### Results without filter

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/withoutfilter.jpg?raw=true" width="400px"/>

The red circle circled the unexpected point presented in the image.
Here we take a closer look:

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/withoutfilter2.jpg?raw=true" width="400px"/>
Unexpected figures are relatively obvious.

### Results with filter

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/withfilter2.JPG?raw=true" width="400px"/>

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/withfilter.JPG?raw=true" width="400px"/>

### Final result

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/dehaze%201.gif?raw=true" width="600px"/>

ω used: 0.2, 0.4, 0.6, 0.8, 0.95


## Discussion

### Deficiencies

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/discussion.jpg?raw=true" width="600px"/>

The three pairs of images representing different intensities of image dehazing. The histogram of the top, which is the original image shows three peaks. Each representing a level of depth. As the intensity of dehazing increases, the three peaks shifts left and merges into 1. Also note that there are little colored information in the original image and dehazing magnifies the information. So inevitably, some details will be lost.

### Conclusion

In addition to the decent quality of resulted images, most of the noices and unexpected noises can be erased by dark channel and guilded filter. However, there will be around the same amounts of details lost using this approach.



## Links

**[Implementations](https://github.com/tmatsuzawa2/dehaze/tree/master/code) and [presentation slides](https://github.com/tmatsuzawa2/dehaze/tree/master/slides) can be found in the github reprository.**

## Work Cited

- Image used from [here](https://www.smithsonianmag.com/smart-news/these-are-worst-cities-air-pollution-180968871/)
- [Single Image Haze Removal Using Dark Channel Prior.](http://kaiminghe.com/publications/cvpr09.pdf)
- Guided filter algorithm used from "Fast Guided Filter" (Algorithm 1); cited: arXiv:1505.00996v1 [cs.CV] 
