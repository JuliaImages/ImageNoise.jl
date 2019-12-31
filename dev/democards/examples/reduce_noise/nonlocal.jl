using ImageNoise, TestImages, ImageShow, ImageCore, ImageQualityIndexes


gray_img = testimage("cameraman") .|> float32
n = AdditiveWhiteGaussianNoise(0.1)
noisy_img = apply_noise(gray_img, n)

f_nlmean = NonlocalMean(0.1)
denoised_img = reduce_noise(noisy_img, f_nlmean)

[gray_img noisy_img denoised_img]

psnr(gray_img, denoised_img)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

