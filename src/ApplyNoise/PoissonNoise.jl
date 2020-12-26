"""
    PoissonNoise

Apply Poisson noise (also called shot noise) to an image.
For each pixel it samples independently a Poisson random distribution. 
Since Image values are often in the range [0, 1] a scaling value can be specified.
If this value is specified, the maximum pixel value of the image will be scaled
to that value, poisson noise will be applied, and the image will be scaled back
by the same value.

For example, this allows to specify a certain photon (event) number representing
the intensity value
"""
struct PoissonNoise <: AbstractImageNoise
    scaling::Union{Float64, Nothing}

    function PoissonNoise(scaling)
        new(scaling)
    end

    function PoissonNoise()
        new(nothing)
    end
end

const PN = PoissonNoise
show(io::IO, n::PN) = println(io, "PoissonNoise(scaling=", n.scaling, ")")


function (n::PN)(out::AbstractArray{T}, 
                 img::GenericGrayImage;
                 rng::Union{AbstractRNG, Nothing} = nothing
                ) where T <: Number
    if isnothing(rng)
        _rand = pois_rand
    else
        _rand = x -> pois_rand(rng, x)
    end
    m = maximum(img)
    if isnothing(n.scaling)
        scaling = m
    else
        scaling = n.scaling
    end
    out .= clamp01.(_rand.(img ./ m .* scaling) ./ scaling .* m)
end

for T in (AbstractGray, AbstractRGB)
    @eval function (n::PN)(out::AbstractArray{<:$T},
                             in::GenericImage;
                             rng::Union{AbstractRNG, Nothing} = nothing)
        n(channelview(out), channelview(in); rng=rng)
    end
end

# Since generic Color3 aren't vector space, they are converted to RGB images
(n::PN)(out::AbstractArray{<:Color3},
         in::GenericImage;
         rng::Union{AbstractRNG, Nothing} = nothing) =
    n(channelview(of_eltype(RGB, out)),
      channelview(of_eltype(RGB, in));
      rng=rng)
