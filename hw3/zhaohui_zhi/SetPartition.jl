function balanced_partition_possible(S)
    total = sum(S)
    target = total ÷ 2  # 整除操作
    dp = falses(target + 1)  # 初始化布尔数组（默认false）
    dp[1] = true  # dp[1]表示和为0（索引1对应和0）

    for num in S
        # 反向遍历，避免重复计算
        for i in target:-1:num
            if dp[i - num + 1]  # 检查是否可以通过i-num的和得到当前和i
                dp[i + 1] = true
            end
        end
    end

    # 寻找最大的可达和
    for i in target:-1:0
        if dp[i + 1]
            return abs(total - 2i) ≤ 1
        end
    end
    return false
end

# 测试样例
println(balanced_partition_possible([1, 2, 3]))   # true（差0）
println(balanced_partition_possible([1, 3, 5]))   # true（差1）
println(balanced_partition_possible([2, 4, 6]))   # true（差0）
println(balanced_partition_possible([10]))        # false（无法分割）