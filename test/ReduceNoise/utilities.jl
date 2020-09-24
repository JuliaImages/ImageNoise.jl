using ImageNoise.ReduceNoise: soft_threshold
@testset "soft_threshold" begin
    @test soft_threshold(1, 0.2) == 0.8
    @test soft_threshold(2.0, 1) == 1
    @test soft_threshold(1, [0.1, 0.2]) == [0.9, 0.8]
    @test soft_threshold([1, 2], 0.1) == [0.9, 1.9]
    @test soft_threshold([1, 2], [0.1, 0.2]) == [0.9, 1.8]
    @test_throws DimensionMismatch soft_threshold(rand(3), rand(4))

    @test soft_threshold(-0.5:0.1:0.5, 0.2) ≈ soft_threshold.(-0.5:0.1:0.5, 0.2) ≈ [-0.3, -0.2, -0.1, -0.0, -0.0,  0.0,  0.0,  0.0,  0.1,  0.2,  0.3]
    @test soft_threshold([1, 2, 3], [0.1, 0.2, 0.3]) ≈ soft_threshold.([1, 2, 3], [0.1, 0.2, 0.3]) == [0.9, 1.8, 2.7]
end


