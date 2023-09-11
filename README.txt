To perform a guassian smoothing effect I begin by converting the image to grey-scale. Then I define the size of the kernal and sigma.
After that I define the guassian smoothing equation and begin applying it all the pixel locations that allow the kernel to be applied.
Once I perform the convulution on the grey-scale image the smoothing effect has been applied.

To get the respective gradient images I defined the respective y([0 -0.5 0; 0 0 0; 0 0.5 0]) and x([0 0 0; -0.5 0 0.5; 0 0 0]) kernels.
I then perform a convulution with a 3x3 kernel using each kernel seperately to get the X and Y gradients. To get the gradient magnitude
I add both the X and Y gradients together.

To then get to the non-maximum suppression, for each pixel I evaluate the gradient's angle and magnitude. Depending on the angle of the gradient,
I check those neighboring pixels gradient magnitude and apply the highest gradient for that pixel.

To finally perform a hysterisis first define high and low thresholds to be applied to each pixel in the image. When looping through each pixel I 
check if it is >= the high threshold or if its < the low threshold. If the pixel is > the high threshold we set that pixel value to white. If 
its lower it will automatically a black pixel value. If it is > the low threshold but < high threshold. We check neighboring pixels and see if
any of those pixels are greater than the high threshold. If so that will also be an edge.