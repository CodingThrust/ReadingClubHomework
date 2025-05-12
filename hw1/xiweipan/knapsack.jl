function knapsack_dp(weights::Vector{Int}, values::Vector{Int}, W::Int)
    l = length(weights)
    vmax = maximum(values)  
    V = l * vmax
    INF = typemax(Int)  # mark the impossible case

    # dp is a (l+1) x (V+1) matrix
    # dp[i, j] is the minimum weight of the knapsack with value j-1 using the last i to l items
    dp = fill(INF, l + 1, V + 1)
    # i = l+1: no available item, only value 0 is possible with weight 0
    dp[l + 1, 1] = 0
    # j = 1: max value is 0
    for i in 1:l
        dp[i, 1] = 0
    end

    for i in l:-1:1
        w, v = weights[i], values[i]
        for val in 0:V
            # without the i-th item
            without = dp[i + 1, val + 1]
            # with the i-th item
            with = INF
            if val >= v && dp[i + 1, val - v + 1] != INF
                with = w + dp[i + 1, val - v + 1]
            end
            dp[i, val + 1] = min(without, with)
        end
    end

    result = 0
    for val in 0:V
        if dp[1, val + 1] <= W
            result = val
        end
    end

    return result
end

# test
weights = [2, 3, 4, 5]
values = [3, 4, 5, 6]
W = 5
println(knapsack_dp(weights, values, W))
