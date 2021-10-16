using ImageNoise
using ImageCore, ImageTransformations, ImageQualityIndexes
using Test, ReferenceTests, TestImages, Random

include("testutils.jl")

@testset "ImageNoise" begin

@testset "ApplyNoise" begin
    include("ApplyNoise/AdditiveWhiteGaussianNoise.jl")
end

@testset "ReduceNoise" begin
    include("ReduceNoise/NonlocalMean.jl")
    include("ReduceNoise/BM3DDenoise.jl")
end

end
nothing
