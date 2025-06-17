def knapsack_value_dp(weights, values, capacity):
    l = len(weights)
    Vmax = max(values)
    total_value = sum(values)

    # Initialize DP table with infinity
    INF = float('inf')
    dp = [[INF] * (total_value + 1) for _ in range(l + 2)]
    
    # Base case: 0 value requires 0 weight
    dp[l + 1][0] = 0

    # Build table from item l down to 1
    for j in range(l, 0, -1):
        for v in range(total_value + 1):
            # Option 1: exclude item j-1
            dp[j][v] = dp[j + 1][v]
            # Option 2: include item j-1, if value allows
            if v >= values[j - 1]:
                dp[j][v] = min(dp[j][v], weights[j - 1] + dp[j + 1][v - values[j - 1]])

    # Find the maximum value v such that dp[1][v] <= capacity
    for v in range(total_value, -1, -1):
        if dp[1][v] <= capacity:
            return v  # maximum value achievable within capacity

    return 0  # no items can be included

# Example usage
weights = [2, 3, 4, 5]
values = [3, 4, 5, 6]
capacity = 7

result = knapsack_value_dp(weights, values, capacity)
print("Maximum value within capacity:", result)


#If P = NP, the NP problem will be solved in polynomial time,
#O(l^2 * v_max) where v_max is a constant, so bits required for v_max is log2(v_max), which is not a polynomial
#P != NP