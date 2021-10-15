module ApplyNoise

using Random
using ImageCore
using ImageCore.OffsetArrays
using ImageCore.MappedArrays
using ImageCore: NumberLike, GenericGrayImage, GenericImage

import ..NoiseAPI: AbstractImageNoise, apply_noise, apply_noise!
import Base: show

include("AdditiveWhiteGaussianNoise.jl")
include("utils.jl")

export
    apply_noise, apply_noise!,

    AdditiveWhiteGaussianNoise

end # end module
