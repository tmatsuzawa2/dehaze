## Image Dehazing

Images obtained under adverse weather conditions, such as haze or fog, typically exhibit low contrast and faded colors, which may severely limit the visibility within the scene. 

Unveiling the image structure under the haze layer and recovering vivid colors out of a single image remains a challenging task, since the degradation is depth-dependent and conventional methods are unable to overcome this problem.

In this project, we will be trying haze removal so that more information can be restored and displayed. The feature is mainly used to remove fog and haze from the original and produce the actual clear images. Instead of using contrast slider, dehaze slider functions by targeting the lower-contrast areas of the scene and applying the bulk of its effects there. Therefore, low contrast areas of the scene get more of the effect than high contrast areas. 

### Importance

Dehazing techniques are commonly used in varieties of practical situations. It is one of the secret weapons used by night photographers to illustrate a better night scene; it can be used to detect dust spots in the picture, and it is also used to make scenes of milky way more three-dimensional. Furthermore, after dehazing some of the pictures that are either naturally or artificially obfuscated, photographers have noticed that the layerings and balances in color are improved significantly, and the entire scene is more appreciable. 

### State-of-the-art

The most popular dehaze tool currently is Adobe Lightroom. Adobe Lightroom is an image manipulation software developed by Adobe system for Windows and macOS which allows viewing, organizing and editing a large number of images and the operations are not destructive.

Now we use an hazed image as example:

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/dehaze_01.jpg?raw=true" class="center" width="400px"/>

This is the dehazed image using Adobe Lightroom

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/Adobelightroom.JPG?raw=true" class="center" width="400px"/>

Another common way that can be used to dehaze is MATLAB, the resulted image using function imreducehaze() with 60 percent of dehazing is shown below:

<img src = "https://github.com/tmatsuzawa2/dehaze/blob/master/matlab.JPG?raw=true" class="center" width="400px"/>

Comparing two different methods, the image in Lightroom has more favorable but artificial color illustrations, while the image in MATLAB has a more clear illustration that nearer from the lens (buildings in this example). However, both tools have disadvantages: Lightroom is less likely to detect depth and apply them to the dehaze slider, while MATLAB has some difficulties in detecting and erasing noises collected by the sensor.

### Re-implemeting existing solution or using new approaches?

We decided to re-implement the existing algorithm and try to refine it better.  The current MATLAB function is effective and convenient, but it might not apply to all circumstances. Perhaps we could build an interactive program that takes input from the user to generate better results. For example, users could specify the color of the haze for a more accurate result.

### Reasons for change

As shown in the image above, the existing solution which is rendering image through Adobe Lightroom creates some unnatural artifacts in the sky. Adobe Lightroom seems to be generating the incorrect information to compensate for the lost detail in the haze. We are working on an alternative solution to either better reserve the original information or find a better way to fill in the missing pieces. We speculate that the image would look better if we remove the noises in the sky using something like a Gaussian filter.

Furthermore, if you look closely at the buildings in the picture, there is clearly remaining haze. It appears that Adobe Lightroom applies the same intensity of dehaze filter to every area of the picture. This method overlooked the fact that areas with different depths generate different amount of haze. 

To determine the intensity of the haze, there is a popular method called “dark channel prior.” This method uses a certain supposedly low-intensity channel to detect the intensity of haze. If the intensity of the channel is abnormally high, chances are this pixel is affected by haze.

After we estimated the depth of each pixel, a simple formula should give us the estimation of haze in each pixel. Restoring the original image should be as easy as readjusting the RGB value. Adjust more for further pixels and less for nearer pixels.

                                                 
```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/tmatsuzawa2/dehaze/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://help.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.
