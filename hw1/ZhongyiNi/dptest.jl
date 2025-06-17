using Test
include("dp.jl")

@testset "testdp" begin
    kp = Knapsack(10,[1,2,3,4,5],[2,3,4,5,6])
    w,set,optv = dp(kp)
    @test w == 10
    @test set == [1,2,3,4]
    @test optv == 14
end

@testset "rescale_kp" begin
    kp = Knapsack(10,[1,2,3,4,5],[23,34,47,58,69])
    K = 10
    kp2 = rescale_kp(kp,K)
    @test kp2.v == [2,3,4,5,6]
end

@testset "rescale_dp" begin
    kp = Knapsack(10,[1,2,3,4,5],[23,34,47,58,69])
    K = 10
    w,set,optv = _rescale_dp(kp,K)
    @test w == 10
    @test set == [1,2,3,4]
    @test optv == 162
end
