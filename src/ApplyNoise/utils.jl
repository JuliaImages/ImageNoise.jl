# This is useful to support Normed type that we have prior information on its
# range. Otherwise, it will just throw ArgumentError if calling, e.g., `N0f8(1.3)`.
@inline project_to(::Type, x) = x
@inline project_to(::Type{T}, x::T) where T = x
@inline project_to(::Type{T}, x) where T<:Union{Normed,Color{<:Normed}} = clamp01(x)
