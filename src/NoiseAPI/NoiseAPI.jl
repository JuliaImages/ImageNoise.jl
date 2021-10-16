# This is a temporary module to validate the ideas in
# https://github.com/JuliaImages/ImagesAPI.jl/pull/3
module NoiseAPI

using Random
using ImageCore

"""
    AbstractImageAlgorithm

The root of image algorithms type system
"""
abstract type AbstractImageAlgorithm end

"""
    AbstractImageFilter <: AbstractImageAlgorithm

Filters are image algorithms whose input and output are both images
"""
abstract type AbstractImageFilter <: AbstractImageAlgorithm end

include("utils.jl")
include("ImageNoise.jl")

abstract type AbstractImageNoise <: AbstractImageFilter end

"""
    apply_noise([::Type{T}], n::AbstractImageNoise, img, rng=GLOBAL_RNG)

Apply random noise `n` to image `img`.

# Arguments

- `T`: the element type of output array. By default it is `eltype(img)`.
- `rng`: random number generator that is used to generate the noise.

# Examples

```julia
n = AdditiveWhiteGaussianNoise(0.1)
img = testimage("lena_gray_256")

# This spells as "apply noise `n` to image `img`"
apply_noise(n, img)

# One can also pass a random number generator to
# get a reproducible result
apply_noise(img, n,  MersenneTwister(0))
```

See also [`apply_noise!`](@ref apply_noise!) for the in-place version.
"""
apply_noise

"""
    apply_noise!([out], img, n::AbstractImageNoise, rng=GLOBAL_RNG)

Apply random noise `n` to image `img`. This function is the in-place version of
[`apply_noise`](@ref).


# Examples

```julia
n = AdditiveWhiteGaussianNoise(0.1)
img = testimage("lena_gray_256")

# `img` will be changed
apply_noise!(img, n)

# `img` will not be changed
out = similar(img)
apply_noise!(out, n, img)
```
"""
apply_noise!


function apply_noise(f::AbstractImageNoise, img::AbstractArray, args...)
    apply_noise(eltype(img), f, img, args...)
end
function apply_noise(::Type{T}, f::AbstractImageNoise, img::AbstractArray, args...) where T
    out = similar(img, T)
    apply_noise!(out, f, img, args...)
    return out
end

# avoid InexactError for Bool array input by promoting it to float
function apply_noise(f::AbstractImageNoise, img::AbstractArray{T}, args...) where T<:Union{Bool, Gray{Bool}}
    apply_noise(floattype(T), f, img, args...)
end

function apply_noise!(
        out::AbstractArray,
        f::AbstractImageNoise,
        img::AbstractArray,
        rng::AbstractRNG=Random.GLOBAL_RNG)
    f(out, img, rng)
end
apply_noise!(img, f::AbstractImageNoise, rng::AbstractRNG=Random.GLOBAL_RNG) = f(img, rng)


end
