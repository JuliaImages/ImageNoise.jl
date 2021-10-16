@testset "AdditiveWhiteGaussianNoise" begin
    @info "Test: AdditiveWhiteGaussianNoise"

    @testset "API" begin
        @test_throws MethodError AdditiveWhiteGaussianNoise()
        @test_throws ArgumentError AdditiveWhiteGaussianNoise(0.0, -0.1)
        @test AdditiveWhiteGaussianNoise(0.1) == AdditiveWhiteGaussianNoise(0.0, 0.1)

        n = AdditiveWhiteGaussianNoise(0.1)
        A = rand(Gray, 255, 255)
        B1 = similar(A)
        B2 = copy(A)
        out_B1 = apply_noise!(B1, n, A)
        out_B2 = apply_noise!(B2, n)
        # issue #7
        @test out_B2 == B2
        @test out_B1 == B1

        B3 = apply_noise(n, A)

        B1 = similar(A)
        B2 = copy(A)
        apply_noise!(B1, n, A, MersenneTwister(0))
        apply_noise!(B2, n, MersenneTwister(0))
        B3 = apply_noise(n, A, MersenneTwister(0))
        B4 = apply_noise(Float64, n, A, MersenneTwister(0))
        @test B1 == B2 == B3 == B4
    end

    @testset "types" begin
        n = AdditiveWhiteGaussianNoise(0.1)

        # Gray
        type_list = generate_test_types([Bool, Float32, N0f8], [Gray])
        A = [1.0 1.0 1.0; 1.0 1.0 1.0; 0.0 0.0 0.0]
        for T in type_list
            a = T.(A)
            @test @inferred apply_noise(n, a) == apply_noise(n, a, Random.GLOBAL_RNG)

            eltype(T) == Bool && continue

            b1 = similar(a, floattype(eltype(a)))
            b2 = copy(a)
            @inferred apply_noise!(b1, n, a, MersenneTwister(0))
            @inferred apply_noise!(b2, n, MersenneTwister(0))
            b3 = @inferred apply_noise(n, a, MersenneTwister(0))
            b4 = @inferred apply_noise(floattype(eltype(a)), n, a, MersenneTwister(0))
            @test b2 == b3
            @test b1 == b4
            @test norm(clamp01.(b1) - clamp01.(b2)) < 0.003
        end

        # RGB
        type_list = generate_test_types([Float32, N0f8], [RGB])
        A = [RGB(0.0, 0.0, 0.0) RGB(0.0, 1.0, 0.0) RGB(0.0, 1.0, 1.0)
            RGB(0.0, 0.0, 1.0) RGB(1.0, 0.0, 0.0) RGB(1.0, 1.0, 0.0)
            RGB(1.0, 1.0, 1.0) RGB(1.0, 0.0, 1.0) RGB(0.0, 0.0, 0.0)]
        for T in type_list
            a = T.(A)
            @test @inferred apply_noise(n, a) == apply_noise(n, a, Random.GLOBAL_RNG)

            b1 = similar(a, floattype(eltype(a)))
            b2 = copy(a)
            @inferred apply_noise!(b1, n, a, MersenneTwister(0))
            @inferred apply_noise!(b2, n, MersenneTwister(0))
            b3 = @inferred apply_noise(n, a, MersenneTwister(0))
            b4 = @inferred apply_noise(floattype(eltype(A)), n, a, MersenneTwister(0))
            @test b1 ≈ b4
            @test b2 ≈ b3
            @test norm(clamp01.(channelview(b1)) - clamp01.(channelview(b2))) < 0.004
        end
    end
end
