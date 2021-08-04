# ---
# title: Non-local Mean Filter
# id: nlmf-demo
# cover: assets/nlmean_cover.png
# date: 2019-12-22
# author: Johnny Chen
# description: Use Non-local Mean filter to reduce gaussian noise
# ---

using ImageNoise
using TestImages, ImageShow, ImageCore, ImageQualityIndexes, ImageTransformations
using FileIO, Random #src

# First, load an image and and add gaussian noise to it

gray_img = float.(imresize(testimage("cameraman"), ratio=0.5))
n = AdditiveWhiteGaussianNoise(0.1)
noisy_img = apply_noise(gray_img, n)

# Then calling the standard `reduce_noise` API

f_nlmean = NonlocalMean(0.1)
denoised_img = reduce_noise(noisy_img, f_nlmean)

mosaicview(gray_img, noisy_img, denoised_img; nrow=1)

# Get the PSNR using ImageQualityIndexes package:

assess_psnr(gray_img, denoised_img)

mkpath("assets") #src
save("assets/nlmean_cover.png", denoised_img) #src
