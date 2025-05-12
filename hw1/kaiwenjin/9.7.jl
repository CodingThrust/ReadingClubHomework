using Test,Random
function pp_dp(w::Vector{Int}, v::Vector{Int}, V::Int)
    @assert findmin(w)[1] >= 0 && findmin(v)[1] >= 0 && V >= 0
    @assert length(w) == length(v) 
    n = length(w)
    dp = zeros(Int, n+1, V+1) 
    for i in 1:n
        for j in 0:V
            if j < w[i]
                dp[i+1, j+1] = dp[i, j+1]
            else
                dp[i+1, j+1] = max(dp[i, j+1], dp[i, j - w[i] + 1] + v[i])
            end
        end
    end
    return dp[n+1, V+1]
end

function pp(w::Vector{Int}, v::Vector{Int}, V::Int)
    @assert length(w) == length(v)
    @assert findmin(w)[1] >= 0 && findmin(v)[1] >= 0 && V >= 0
    n = length(w)
    res2 = -1
    for k = 0:2^n-1
        chosen = []
        for i in 1:n
            push!(chosen, 1&k)
            k >>= 1
        end
        val = sum(chosen .* v)
        if val > res2 && sum(chosen .* w) <= V
            res2 = val
        end
    end
    return res2
end

function pp_fptas(w::Vector{Int}, v::Vector{Int}, V::Int, ε::Float64)
    @assert findmin(w)[1] >= 0 && findmin(v)[1] >= 0 && V >= 0 && 0 < ε < 1
    @assert length(w) == length(v)
    n = length(w)
    v_max = maximum(v)
    c = ε * v_max / n
    w_scaled = floor.(Int, w ./ c)
    v_scaled = floor.(Int, v ./ c)
    V_scaled = floor(Int, V / c)
    return pp_dp(w_scaled, v_scaled, V_scaled) * c
end

@testset "pp_fptas" begin
    Random.seed!(6)
    N = 20
    M = 100
    w = rand(collect(1:M), N)
    v = rand(collect(1:M), N)
    V = sum((M÷2)*(N÷2))
    ε = 0.1
    res0 = pp(w, v, V)
    res1 = pp_fptas(w, v, V, ε)
    @test abs(res1 - res0) <= ε * res0
end