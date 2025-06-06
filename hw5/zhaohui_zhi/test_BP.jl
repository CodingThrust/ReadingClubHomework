include("BP.jl")
using Test
using TensorInference

function is_tree(g::AbstractGraph)
    n = nv(g)  # 顶点数
    e = ne(g)  # 边数

    # 边数不等于 n-1 直接返回 false
    e != n - 1 && return false

    # 检查连通性（空图或单顶点图直接视为连通）
    n ≤ 1 && return true

    # 使用 BFS/DFS 判断连通性（避免依赖特定包的实现）
    visited = falses(n)
    queue = [1]  # 从第一个顶点开始遍历
    visited[1] = true
    count = 1

    while !isempty(queue)
        v = popfirst!(queue)
        for u in neighbors(g, v)
            if !visited[u]
                visited[u] = true
                push!(queue, u)
                count += 1
            end
        end
    end

    # 所有顶点都被访问过则为连通
    return count == n
end

clauses1 = SATformula([[-2, -3, -4, 5], [-1, -5, 6], [-5, 7], [-1, -6, -7], [-1, -2, 5], [-1, -3, 5], [-1, -4, 5], [-1, 2, 3, 4, 5, -6]])
FG = FactorGraph(clauses1)




@testset "FactorGraph" begin
    clauses2 = SATformula([[1, -2], [-1, 2, 3], [3, 4, -5], [1]])
    FG=FactorGraph(clauses2)
    # 1 -> 5 var index, 6->9 clause idx, or a, b, c, d
    g = FG.g
    @test g == SimpleGraph{Int64}(9, [[6, 7, 9], [6, 7], [7, 8], [8], [8], [1, 2], [1, 2, 3], [3, 4, 5], [1]])
    @test FG.num_vars == 5
end

@testset "BP_update" begin
    clauses2 = SATformula([[1, -2], [-1, 2, -3], [3, 4, -5], [1]])
    FG=FactorGraph(clauses2)
    # 1 -> 5 var index, 6->9 clause idx, or a, b, c, d
    g = FG.g
    edge_types = FG.edge_types
    @test g == SimpleGraph{Int64}(9, [[6, 7, 9], [6, 7], [7, 8], [8], [8], [1, 2], [1, 2, 3], [3, 4, 5], [1]])
    @test edge_types == Dict((4, 8) => -1, (3, 7) => 1, (1, 7) => 1, (1, 6) => -1, (1, 9) => -1, (2, 7) => -1, (3, 8) => -1, (2, 6) => 1, (5, 8) => 1)
    @test FG.num_vars == 5
    messages = Set_messages(FG)
    @test messages == Dict((3, 7) => 0.5, (8, 3) => 0.5, (6, 2) => 0.5, (8, 4) => 0.5, (7, 1) => 0.5, (3, 8) => 0.5, (2, 6) => 0.5, (7, 2) => 0.5, (1, 9) => 0.5, (2, 7) => 0.5, (7, 3) => 0.5, (8, 5) => 0.5, (4, 8) => 0.5, (1, 6) => 0.5, (5, 8) => 0.5, (1, 7) => 0.5, (6, 1) => 0.5, (9, 1) => 0.5)
    
    messages_v2f, messages_f2v = seperate_messages(messages, FG.num_vars)
    @test  messages_v2f== Dict((4, 8) => 0.5, (3, 7) => 0.5, (1, 7) => 0.5, (1, 6) => 0.5, (1, 9) => 0.5, (2, 7) => 0.5, (3, 8) => 0.5, (2, 6) => 0.5, (5, 8) => 0.5)
    @test messages_f2v == Dict((8, 3) => 0.5, (6, 2) => 0.5, (7, 2) => 0.5, (8, 4) => 0.5, (7, 1) => 0.5, (6, 1) => 0.5, (8, 5) => 0.5, (7, 3) => 0.5, (9, 1) => 0.5)
    a = 7
    i = 1
    neighbors_ja = [j for (a_prime, j) in keys(messages) if a_prime == a && j != i]
          
           

            
    @test neighbors_ja == [2, 3]
    
     neighbors_bj = [(k,b) 
            for k in neighbors_ja 
            for b in FG.num_vars:ne(g)
            if k != b && b!=a && haskey(messages, (k, b)) ]

    @test neighbors_bj == [(2, 6), (3, 8)]
    input_message = Dict(
                (k, b) => messages[(k, b)] 
                for (k,b) in neighbors_bj
            )

    @test input_message == Dict((2, 6) => 0.5, (3, 8) => 0.5)
    new_messages = BP_update!(input_message, neighbors_ja, neighbors_bj, FG.num_vars, a, edge_types)

    @test new_messages ≈ 0.25 # 根据具体的计算结果进行调整

    a=8;i=3
    neighbors_ja = [j for (a_prime, j) in keys(messages) if a_prime == a && j != i]
    @test neighbors_ja == [4, 5]
    neighbors_bj = [(k,b) 
            for k in neighbors_ja 
            for b in FG.num_vars:ne(g)
            if k != b && b!=a && haskey(messages, (k, b)) ]
end

@testset "BP" begin
    clauses2 = SATformula([[1, -2], [-1, 2, -3], [3, 4, -5], [1]])
    FG=FactorGraph(clauses2)
    # 1 -> 5 var index, 6->9 clause idx, or a, b, c, d
    g = FG.g
    edge_types = FG.edge_types
    @test BP(FG) == Dict((8, 3) => 0.5, (6, 2) => 0.0, (7, 2) => 0.9999999999999996, (8, 4) => 0.25, (7, 1) => 0.22222222222222213, (6, 1) => 0.9999999999999993, (8, 5) => 0.25, (7, 3) => 0.0, (9, 1) => 1.0)
end