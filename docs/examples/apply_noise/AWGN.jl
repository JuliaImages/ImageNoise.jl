# ---
# title: White Additive Gaussian Noise
# id: wagn-demo
# cover: assets/awgn_cover.png
# description: Add white additive gaussian noise to an image
# date: 2019-12-22
# author: Johnny Chen
# ---

# Mathematically, adding a white additive gaussian noise to an image is as simple
# as $Y = X + N$ where $N \sim \mathcal{N}(\mu,\,\sigma^{2})\,.$

using ImageNoise
using TestImages, ImageShow, ImageCore, ImageQualityIndexes, ImageTransformations
using FileIO, Random #src

# Let's add noise to gray image first

gray_img = float.(imresize(testimage("cameraman"), ratio=0.5))
noise = AdditiveWhiteGaussianNoise(0.1)
Random.seed!(0) #src
gray_noisy_img = apply_noise(gray_img, noise)

# For RGB image, noise aren't added to it channel by channel, instead, we generate
# a $3\times M\times N$ gaussian noise and directly added to its channelview result.
# Adding noise channel by channel would indeed get a different distribution (but
# still a gaussian noise).

rgb_img = float.(imresize(testimage("mandrill"), ratio=0.5))
Random.seed!(0) #src
rgb_noisy_img = apply_noise(rgb_img, noise)

# Colorful images of other formats are converted to RGB first since RGB color 
# space is considered "linear".

hsv_img = HSV.(rgb_img)
Random.seed!(0) #src
hsv_noisy_img = apply_noise(hsv_img, noise)
incorrect_hsv_noisy_img = colorview(HSV, apply_noise(channelview(hsv_img), noise))

## If we compare their psnr, the second one is significantly lower than the first one
[assess_psnr(rgb_noisy_img, RGB.(hsv_noisy_img))
assess_psnr(rgb_noisy_img, RGB.(incorrect_hsv_noisy_img))]

mkpath("assets") #src
save("assets/awgn_cover.png", rgb_noisy_img) #src
