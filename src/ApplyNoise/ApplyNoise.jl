module ApplyNoise

using Random
using MappedArrays
using ImageCore
using ImageCore: NumberLike, GenericGrayImage, GenericImage
using ColorVectorSpace
using PoissonRandom

import ..NoiseAPI: AbstractImageNoise, apply_noise, apply_noise!
import Base: show

# avoid InexactError for Bool array input by promoting it to float
apply_noise(img::AbstractArray{T},
            n::AbstractImageNoise,
            args...; kargs...) where T<:Union{Bool, Gray{Bool}} =
    apply_noise(of_eltype(floattype(eltype(img)), img), n, args...; kargs...)

include("AdditiveWhiteGaussianNoise.jl")
include("PoissonNoise.jl")

export
    apply_noise, apply_noise!,
    AdditiveWhiteGaussianNoise,
    PoissonNoise
end # end module
