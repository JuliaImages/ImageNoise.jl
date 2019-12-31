using ImageNoise, TestImages, ImageShow, ImageCore, ImageQualityIndexes

gray_img = testimage("cameraman") .|> float32
noise = AdditiveWhiteGaussianNoise(0.1)
gray_noisy_img = apply_noise(gray_img, noise)

rgb_img = testimage("mandrill") .|> float32
rgb_noisy_img = apply_noise(rgb_img, noise)

hsv_img = HSV.(rgb_img)
hsv_noisy_img = apply_noise(hsv_img, noise)
incorrect_hsv_noisy_img = colorview(HSV, apply_noise(channelview(hsv_img), noise))

# If we compare their psnr, the second one is significantly lower than the first one
[psnr(rgb_noisy_img, RGB.(hsv_noisy_img))
psnr(rgb_noisy_img, RGB.(incorrect_hsv_noisy_img))]

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

