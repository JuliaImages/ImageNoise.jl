# ---
# title: The BM3D(sparse 3D transform-domain collaborative filtering) denoising algorithm.
# id: bm3d-demo
# cover: assets/bm3d_cover.png
# date: 2021-08-04
# author: "[Longhao Chen](https://github.com/Longhao-Chen)"
# description: Use the BM3D denoising algorithm to reduce gaussian noise
# ---

using ImageNoise
using TestImages, ImageShow, ImageCore, ImageQualityIndexes, ImageTransformations
using FileIO, Random #src

# First, load an image and and add gaussian noise to it

gray_img = float.(imresize(testimage("cameraman"), ratio=0.5))
n = AdditiveWhiteGaussianNoise(0.1)
noisy_img = apply_noise(gray_img, n)

# Then calling the standard `reduce_noise` API

f_bm3d = BM3D(0.1)
denoised_img = reduce_noise(noisy_img, f_bm3d)

mosaicview(gray_img, noisy_img, denoised_img; nrow=1)

# Get the PSNR using ImageQualityIndexes package:

assess_psnr(gray_img, denoised_img)

mkpath("assets") #src
save("assets/bm3d_cover.png", denoised_img) #src
