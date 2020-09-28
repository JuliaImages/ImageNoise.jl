module ReduceNoise

using Base.Iterators
using LinearAlgebra
using MappedArrays
using OffsetArrays
using ImageCore
using ImageCore: NumberLike, GenericGrayImage, GenericImage
using ImageFiltering
using ColorVectorSpace
using ImageDistances
using Statistics
using LowRankApprox

using ImageQualityIndexes # TODO: remove this
using ProgressMeter # TODO: remove this

import ..NoiseAPI: AbstractImageDenoiseAlgorithm, reduce_noise, reduce_noise!

include("compat.jl")
include("utilities.jl")
include("NonlocalMean.jl")
include("WNNM.jl") # Weighted Nuclear Norm Minimization

export reduce_noise, reduce_noise!,
    # Non-local mean filter for gaussian noise
    NonlocalMean,

    # Weighted Nuclear Norm Minimization
    WNNM

end # module
