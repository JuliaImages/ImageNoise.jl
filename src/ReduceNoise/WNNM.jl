"""

# References

[1] Gu, S., Zhang, L., Zuo, W., & Feng, X. (2014). Weighted nuclear norm minimization with application to image denoising. In _Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition_ (pp. 2862-2869).

"""
struct WNNM <: AbstractImageDenoiseAlgorithm
    "Estimated gaussian noise level"
    noise_level::Float64
    "Number of WNNM iterations"
    K::Int
    "step value for each WNNM iteration"
    δ::Float64
    "number of patches in each WNNM iteration"
    num_patches::Vector{Int}
    "patch size in each WNNM iteration"
    patch_size::Vector{Int}
    "patch stride in each WNNM iteration"
    patch_stride::Vector{Int}
    "weight constant used to estimate the remained noise level of each patch"
    λ::Float64
    "weight constant in WNNM solver"
    C::Float64
    "non-local search size in block matching"
    window_size::Int
end

function WNNM(noise_level;
              δ=0.1,
              C=2sqrt(2),
              window_size=60,
              patch_size=nothing,
              num_patches=nothing,
              K=nothing,
              λ=nothing,
              patch_stride=nothing)
    if noise_level <= 20
        isnothing(patch_size) && (patch_size = 6)
        isnothing(num_patches) && (num_patches = 70)
        isnothing(K) && (K = 8)
        isnothing(λ) && (λ = 0.56)
    elseif noise_level <= 40
        isnothing(patch_size) && (patch_size = 7)
        isnothing(num_patches) && (num_patches = 90)
        isnothing(K) && (K = 12)
        isnothing(λ) && (λ = 0.56)
    elseif noise_level <= 60
        isnothing(patch_size) && (patch_size = 8)
        isnothing(num_patches) && (num_patches = 120)
        isnothing(K) && (K = 14)
        isnothing(λ) && (λ = 0.58)
    else
        isnothing(patch_size) && (patch_size = 9)
        isnothing(num_patches) && (num_patches = 140)
        isnothing(K) && (K = 14)
        isnothing(λ) && (λ = 0.58)
    end

    patch_size isa Number && (patch_size = fill(patch_size, K))
    isnothing(patch_stride) && (patch_stride = @. max(1, patch_size ÷ 2 - 1))
    patch_stride isa Number && (patch_stride = fill(patch_stride, K))

    num_patches = fill(num_patches - 10, K)
    drop_freq = 2
    for k in 2:K
        # drop by 10 for every 2 iteration
        num_patches[k] = (k - 1) % drop_freq == 0 ? num_patches[k - 1] - 10 : num_patches[k - 1]
    end

    WNNM(noise_level, K, δ, num_patches, patch_size, patch_stride, λ, C, window_size)
end

## Implementation

function (f::WNNM)(imgₑₛₜ, imgₙ; clean_img=nothing)
    if imgₑₛₜ === imgₙ
        imgₑₛₜ = copy(imgₙ)
    else
        copyto!(imgₑₛₜ, imgₙ)
    end

    for iter in 1:f.K
        @. imgₑₛₜ = imgₑₛₜ + f.δ * (imgₙ - imgₑₛₜ)

        # The noise level for the first iteration is known (whether it is estimated outside or a
        # white noise). The noise is removed in each iteration, so we have to estimate a noise level
        # at a patch level; the denoising performance on each patch can be different, which means a
        # global noise level can be misleading.
        σₚ = iter == 1 ? f.noise_level : nothing

        imgₑₛₜ .= _estimate_img(imgₑₛₜ, imgₙ;
            noise_level=f.noise_level,
            patch_size=f.patch_size[iter],
            patch_stride=f.patch_stride[iter],
            num_patches=f.num_patches[iter],
            window_size=f.window_size,
            λ=f.λ,
            C=f.C,
            σₚ=σₚ,
        )

        # TODO: remove this logging part when it is ready
        if !isnothing(clean_img)
            @info "Result" iter psnr = assess_psnr(clean_img, imgₑₛₜ, 255) num_patches = f.num_patches[iter]
            display(Gray.(imgₑₛₜ ./ 255))
            sleep(0.1)
        end
    end
    return imgₑₛₜ
end

function _estimate_img(imgₑₛₜ, imgₙ; patch_size, patch_stride, kwargs...)
    patch_size = ntuple(_ -> patch_size, ndims(imgₑₛₜ))
    r = CartesianIndex(patch_size .÷ 2)
    R = CartesianIndices(imgₑₛₜ)
    R = R[first(R) + r:last(R) - r]

    imgₑₛₜ⁺ = zeros(eltype(imgₑₛₜ), axes(imgₑₛₜ)) # TODO: preallocate this
    W = zeros(Int, axes(imgₑₛₜ))
    @showprogress for p in R[1:patch_stride:end]
        out, patch_q_indices = _estimate_patch(imgₑₛₜ, imgₙ, p; patch_size=patch_size, kwargs...)

        view(W, patch_q_indices) .+= 1
        view(imgₑₛₜ⁺, patch_q_indices) .+= out
    end

    return imgₑₛₜ⁺ ./ max.(W, 1)
end

function _estimate_patch(imgₑₛₜ, imgₙ, p;
                         noise_level,
                         patch_size::Tuple,
                         num_patches::Integer,
                         window_size,
                         λ,
                         C,
                         σₚ=nothing)
    rₚ = CartesianIndex(patch_size .÷ 2)
    p_indices = p - rₚ:p + rₚ

    patch_q_indices = block_matching(imgₑₛₜ, p;
        num_patches=num_patches,
        patch_size=patch_size,
        search_window_size=window_size,
        patch_stride=1
    )
    patch_q_indices = hcat([indices[:] for indices in patch_q_indices]...)
    m = mean(imgₑₛₜ[patch_q_indices]; dims=2)

    if isnothing(σₚ)
        # Try: use the mean estimated σₚ of each patch
        σₚ = _estimate_noise_level(view(imgₑₛₜ, p_indices), view(imgₙ, p_indices), noise_level; λ=λ)
    end
    out = WNNM_optimizer(imgₑₛₜ[patch_q_indices] .- m, σₚ; C=C) .+ m

    return out, patch_q_indices
end


@doc raw"""
    WNNM_optimizer(Y, σₚ, C=2sqrt(2), fixed_point_num_iters=3)

Optimizes the weighted nuclear norm minimization problem with a fixed point estimation

```math
    \min_X \lVert Y - X \rVert^2_{F} + \lVert X \rVert_{w, *}
```

The weight `w` is specially chosen so that it satisfies the condition of Corollary 1 in [1].

# References

[1] Gu, S., Zhang, L., Zuo, W., & Feng, X. (2014). Weighted nuclear norm minimization with application to image denoising. In _Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition_ (pp. 2862-2869).

"""
function WNNM_optimizer(Y, σₚ; C=2sqrt(2), fixed_point_num_iters=3)
    # Apply Corollary 1 in [1] for image denoise purpose
    # Note: this solver is reserved to the denoising method and is not supposed to be used in other
    #       applications; it simply isn't designed so.

    U, ΣY, V = svd(Y)
    n = size(Y, 2)

    # For image denoising problems, it is natural to shrink large singular value less, i.e., to set
    # smaller weight to large singular value. For this reason, it uses `w = (C * sqrt(n))/(ΣX + eps())`
    # as the weights; inversely propotional to ΣX. With singular values ΣX sorted ascendingly, the
    # condition for Corollary 1 holds, and thus we could directly get the desired solution in a single
    # step.

    # Here we iterate more than once because we don't know what ΣX is; we have to iterate it a while 
    # from ΣY to get an relatively good estimation of it.
    # TODO: could we set default σₚ as 0?
    # TODO: is this the best initialization we can get?
    ΣX = @. sqrt(max(ΣY^2 - n * σₚ^2, 0))
    for _ in 1:fixed_point_num_iters
        # the iterative algorithm proposed in section 2.2.2 in [1]
        # Step 1 in the iterative algorithm becomes trivial and a no-op

        # Step 2 degenerates to a soft thresholding; both P and Q are identity matrix.
        # all in one line to avoid unnecessary allocation for temporarily variable w
        @. ΣX = soft_threshold(ΣY, (C * sqrt(n) * σₚ^2) / (ΣX + eps()))
    end

    return U * Diagonal(ΣX) * V'
end


function _estimate_noise_level(patchₑₛₜ, patchₙ, σₙ; λ=0.56)
    # Estimate the noise level of given patch during the WNNM iteration
    # we still need to know the input noisy level σₙ to give an estimation
    λ * sqrt(abs(σₙ^2 - mse(patchₑₛₜ, patchₙ)))
end
