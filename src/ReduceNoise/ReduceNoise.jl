module ReduceNoise

using Base.Iterators
using ImageCore
using ImageCore.MappedArrays
using ImageCore.OffsetArrays
using ImageCore.PaddedViews
using ImageCore: NumberLike, GenericGrayImage, GenericImage
import ..NoiseAPI: AbstractImageDenoiseAlgorithm, reduce_noise, reduce_noise!

# Introduced in ColorVectorSpace v0.9.3
# https://github.com/JuliaGraphics/ColorVectorSpace.jl/pull/172
using ImageCore.ColorVectorSpace.Future: abs2

include("compat.jl")
include("BM3DDenoise.jl")
include("NonlocalMean.jl")

export
    reduce_noise, reduce_noise!,

    # BM3D
    BM3D,
    # Non-local mean filter for gaussian noise
    NonlocalMean, get_NonlocalMean_rp

end # module
