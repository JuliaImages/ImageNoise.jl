"""
    AdditiveWhiteGaussianNoise <: AbstractImageNoise
    AdditiveWhiteGaussianNoise([μ=0.0], σ)

Apply additive white gaussian noise to image.

For gray image, it uses the following formula:

    out = in .+ σ .* randn(size(in)) .+ μ

Noise for RGB images are generated per channel.

# Examples

```julia
img = testimage("lena_gray_256")
n = AdditiveWhiteGaussianNoise(0.1)
out = apply_noise(img, n)
```

See also: [`apply_noise`](@ref), [`apply_noise!`](@ref)

# References
[1] Wikipedia contributors. (2019, March 8). Additive white Gaussian noise. In _Wikipedia, The Free Encyclopedia_. Retrieved 14:32, June 9, 2019, from https://en.wikipedia.org/w/index.php?title=Additive_white_Gaussian_noise&oldid=886818982
"""
struct AdditiveWhiteGaussianNoise <: AbstractImageNoise
    """mean"""
    μ::Float64
    """standard deviation"""
    σ::Float64

    function AdditiveWhiteGaussianNoise(μ, σ)
        σ >= zero(σ) || throw(ArgumentError("std σ should be non-negative"))
        new(μ, σ)
    end
end
const AWGN = AdditiveWhiteGaussianNoise # This short form is only for internal usage
AWGN(σ::Real) = AWGN(zero(σ), σ)

show(io::IO, n::AWGN) = println(io, "AdditiveWhiteGaussianNoise(μ=", n.μ, ", σ=", n.σ, ")")

(n::AWGN)(out::AbstractArray, rng::AbstractRNG) = n(out, out, rng)
function (n::AWGN)(out::AbstractArray{T}, in::AbstractArray, rng::AbstractRNG) where T<:Number
    FT = floattype(T)
    σ = convert(FT, n.σ)
    μ = convert(FT, n.μ)
    σ ≈ 0 && μ ≈ 0 && return out

    axes(out) == axes(in) || throw(DimensionMismatch("Axes of input $(axes(in)) does not match axes of output $(axes(out))"))
    noise = randn(rng, FT, size(out))
    noise = OffsetArrays.OffsetArray(noise, OffsetArrays.Origin(first.(axes(out))))
    @. out = project_to(T, in + σ * noise + μ)
    return out
end

function (n::AWGN)(out::AbstractArray{CT}, in::AbstractArray, rng::AbstractRNG) where CT<:Union{AbstractGray, AbstractRGB}
    FT = floattype(eltype(CT))
    σ = convert(FT, n.σ)
    μ = convert(FT, n.μ) * oneunit(base_color_type(FT))
    σ ≈ 0 && μ ≈ 0 && return out

    axes(out) == axes(in) || throw(DimensionMismatch("Axes of input $(axes(in)) does not match axes of output $(axes(out))"))
    noise = ntuple(Val(length(CT))) do _ # use Val to assist type inference
        # For RGB image, the noise is generated per channel
        randn(rng, FT, size(out))
    end
    noise = colorview(base_color_type(CT), noise...)
    @. out = project_to(CT, in + σ * noise + μ)
    return out
end
