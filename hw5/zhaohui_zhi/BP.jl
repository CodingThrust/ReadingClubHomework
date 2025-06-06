using Random
using Statistics
using Graphs
using LinearAlgebra

struct SATformula
    clauses::Vector{Vector{Int}}
    num_vars::Int
    num_clauses::Int
end

struct SATsolution
    solutions::Vector{Symbol}
    num_vars::Int
    clauses::Vector{Vector{Int}}  # Store the clauses for reference
end

# function SATformula(clauses::Vector{Vector{Int}})::SATformula
#     num_vars = maximum(abs.(reduce(vcat, clauses)))
#     num_clauses = length(clauses)
#     return SATformula(clauses, num_vars, num_clauses)
# end

Base.:(==)(s1::SATformula, s2::SATformula) = s1.clauses == s2.clauses && s1.num_vars == s2.num_vars && s1.num_clauses== s2.num_clauses
Base.:(==)(s1::SATsolution, s2::SATsolution) = s1.solutions == s2.solutions && s1.num_vars == s2.num_vars && s1.clauses == s2.clauses

function SATformula(clauses::Vector{T})::SATformula where T 
    if isempty(clauses)
        return SATformula(clauses, 0, 0)
    end
    non_empty_clauses = filter(!isempty, clauses)
    if isempty(non_empty_clauses)
        num_vars = 0
    else
        num_vars = maximum(abs.(reduce(vcat, non_empty_clauses)))
    end
    num_clauses = length(clauses)
    return SATformula(clauses, num_vars, num_clauses)
end

function SATsolution(solutions::Vector{Symbol},formula::SATformula)::SATsolution
    if length(solutions) != formula.num_vars
        throw(ArgumentError("Solutions length must match number of variables."))
    end
    clauses = formula.clauses
    num_vars = formula.num_vars
    return SATsolution(solutions, num_vars, clauses)
end

# factor graph, the first num_vars are the variables (the indices), the rest are the factors (the tensors)
struct FactorGraph{T}
    g::SimpleGraph{T}
    num_vars::Int
    edge_types::Dict{Tuple{Int, Int}, Int}  # Edge types: -1 for original variable edges, 1 for negated variable edges
    function FactorGraph(g::SimpleGraph{T}, num_vars::Int, edge_types::Dict{Tuple{Int, Int},Int}) where T
        for e in edges(g)
            s, d = src(e), dst(e)
            # neighbor of a variable is a factor, and vice versa
            @assert ((s ≤ num_vars) && (d > num_vars)) || ((s > num_vars) && (d ≤ num_vars))
        end
        new{T}(g, num_vars, edge_types)
    end
end

Base.show(io::IO, fg::FactorGraph) = print(io, "FactorGraph{variables: $(fg.num_vars), factors: $(nv(fg.g) - fg.num_vars)}")
Base.copy(fg::FactorGraph) = FactorGraph(copy(fg.g), fg.num_vars, fg.edge_types)

Graphs.edges(fg::FactorGraph) = edges(fg.g)
Graphs.vertices(fg::FactorGraph) = vertices(fg.g)
Graphs.nv(fg::FactorGraph) = nv(fg.g)
Graphs.ne(fg::FactorGraph) = ne(fg.g)
Graphs.has_edge(fg::FactorGraph, s, d) = has_edge(fg.g, s, d)
Graphs.has_vertex(fg::FactorGraph, v) = has_vertex(fg.g, v)
Graphs.rem_edge!(fg::FactorGraph, s, d) = rem_edge!(fg.g, s, d)
Graphs.rem_vertex!(fg::FactorGraph, v) = rem_vertex!(fg.g, v)
Graphs.rem_vertices!(fg::FactorGraph, vs) = rem_vertices!(fg.g, vs)
Graphs.add_edge!(fg::FactorGraph, s, d) = add_edge!(fg.g, s, d)
Graphs.add_vertex!(fg::FactorGraph) = add_vertex!(fg.g)
Graphs.add_vertices!(fg::FactorGraph, n) = add_vertices!(fg.g, n)
Graphs.neighbors(fg::FactorGraph, v) = neighbors(fg.g, v)
is_factor(fg::FactorGraph, v) = v > fg.num_vars
is_variable(fg::FactorGraph, v) = v ≤ fg.num_vars

function FactorGraph(code::SATformula)::FactorGraph
    num_vars = code.num_vars
    num_clauses = code.num_clauses
    g = SimpleGraph(num_vars + num_clauses)
    edge_types = Dict{Tuple{Int, Int}, Int}()
    # Add edges between variables and clauses
    for (i, clause) in enumerate(code.clauses)
        clause_idx = num_vars + i  # Clause index in the graph
        for var in clause
            # Add edge from variable to clause
            add_edge!(g, abs(var), clause_idx)
            get!(edge_types, (abs(var), clause_idx), -sign(var))
        end
    end
    
    return FactorGraph(g, num_vars, edge_types)
end

function is_variable(v::Int, num_vars::Int)::Bool
    """
    Check if the vertex v is a variable (i.e., its index is less than or equal to num_vars).

    """
    return v<= num_vars
end

function Set_messages(FG::FactorGraph)
    # Set messages in the factor graph
    messages = Dict{Tuple{Int, Int}, Float64}()
    g = FG.g
    for e in edges(g)
        messages[(src(e), dst(e))] = 0.5  # Initialize messages to uniform distribution
        messages[(dst(e), src(e))] = 0.5  # Initialize messages in the opposite direction
    end
    
    return messages
end

function seperate_messages(messages::Dict{Tuple{Int, Int}, TA}, num_vars::Int64) where TA
    """
    Seperate messages into two dictionaries: one for variable to factor messages and one for factor to variable messages.
    """
    messages_v2f = Dict{Tuple{Int, Int}, TA}()
    messages_f2v = Dict{Tuple{Int, Int}, TA}()
    
    for (key, value) in messages
        if is_variable(key[1], num_vars)  # Variable to factor message
            messages_v2f[key] = value
        else  # Factor to variable message
            messages_f2v[key] = value
        end
    end
    
    return messages_v2f, messages_f2v
end

function BP_update!(input_messages::Dict{Tuple{Int, Int}, TA}, neighbors_ja::Vector{Int}, neighbors_bj::Vector{Tuple{Int64, Int64}}, num_vars::Int64, a::Int, edge_types::Dict{Tuple{Int, Int}, Int}, damping_factor::Float64=1.0, tolerance::Float64=1e-6) where {TA}
    # Input: Set of all input_messages arriving onto each variable node j ∈ V(a)\i, a is the function node, i is the variable node to which we are sending the message to.
    
    V_plus = Vector{Tuple{Int64, Int64}}()  # 变量j的原变量边 (a,j) where J=-1
    V_minus =  Vector{Tuple{Int64, Int64}}() # 变量j的否定边 (a,j) where J=1

    for (b, j) in neighbors_bj
        J = edge_types[(j, b)]
        if J == -1
            push!(V_plus, (b, j))
        elseif J == 1
            push!(V_minus, (b, j))
        end
    end
    γ_product = 1.0  # 初始化γ乘积
    # 对每个邻居j ∈ V(a)\i 计算γ_j→a
    for j in neighbors_ja
        # 获取边(a,j)的类型
        J_aj = edge_types[(j, a)]
        @assert J_aj in [1, -1] "Edge type for ($a, $j) must be 1 or -1"
        # 确定Vu(j→a)和Vs(j→a)的边集合
        if J_aj == -1
            # J_aj=-1: 原变量边，按公式Vu(j)=V_plus[j]\a，Vs=V_minus[j]\a
            Vu = V_minus
            Vs = V_plus
        else
            # J_aj=1: 否定边，按公式Vu(j)=V_minus[j]\a，Vs=V_plus[j]\a
            Vu = V_plus
            Vs = V_minus
        end
        # 计算Pu_j→a: ∏_{b ∈ Vu} (1 - δ_b→j)
        Pu = 1.0
        for (b, j) in Vu
            δ = input_messages[(b, j)]
            Pu *= (1 - δ)
        end
        Pu = isempty(Vu) ? 1.0 : Pu  # 处理空集
        # 计算Ps_j→a: ∏_{b ∈ Vs} (1 - δ_b→j)
        Ps = 1.0
        for (b, j) in Vs
            δ = input_messages[(b, j)]
            Ps *= (1 - δ)
        end
        Ps = isempty(Vs) ? 1.0 : Ps
        # 计算γ_j→a = Ps / (Pu + Ps)
        γ = Ps / (Pu + Ps + eps())  # 加eps()防止除零
        γ_product *= γ
    end
    
    
    # # 应用阻尼（可选）
    # if damping_factor < 1.0
    #     old_δ = messages[(a, i)]
    #     new_δ = damping_factor * new_δ + (1 - damping_factor) * old_δ
    # end
    # new_messages[(a, i)] = new_δ


    return γ_product
end

function BP_iterate(order, messages::Dict{Tuple{Int, Int}, Float64}, messages_init::Dict{Tuple{Int, Int}, Float64}, FG::FactorGraph, edge_types::Dict{Tuple{Int, Int}, Int})
    new_messages = Dict{Tuple{Int, Int}, Float64}()
    for (a, i) in order
        # 获取 V(a)\i：所有与a相连的变量节点，排除i
        neighbors_ja = [j for (a_prime, j) in keys(messages) if a_prime == a && j != i]
        if isempty(neighbors_ja)   # 跳过无邻居的情况
            new_messages[(a, i)] = 1.0  # 跳过无邻居的情况
        else
            neighbors_bj = [(b,k) 
            for k in neighbors_ja 
            for b in FG.num_vars:ne(g)
            if k != b && b!=a && haskey(messages, (b, k)) ]
            
            if isempty(neighbors_bj) 
                new_messages[(a, i)] = 0.5 # 跳过无邻居的情况
            else
                input_message = Dict(
                    (b, k) => messages_init[(b, k)] 
                    for (b, k) in neighbors_bj
                ) # b is the function node, k is the variable node
                output_message_ai = BP_update!(input_message, neighbors_ja, neighbors_bj, FG.num_vars, a, edge_types)
                new_messages[(a, i)] = output_message_ai
            end
        end
    end     
    
    return new_messages
end


function BP(FG::FactorGraph, max_iter::Int=1000, randomvalue::Bool=true,  tol::Float64=1e-6)
    """
    Belief Propagation algorithm for solving SAT problems represented as a FactorGraph.
    Parameters:
        g : FactorGraph representing the SAT problem
        max_iter : maximum number of iterations
        tol : tolerance for convergence
    Returns:
        "UN-CONVERGED" or all messages.
    """
    # Initialize messages
    messages = Set_messages(FG)
    edge_types = FG.edge_types  # Edge types: -1 for original variable edges, 1 for negated variable edges
    
    
    final_iter = 0
    messages_v2f, messages_f2v = seperate_messages(messages, FG.num_vars)
    t = collect(keys(messages_f2v))
    order = randomvalue ? t[sortperm(rand(length(t)))] : t

    prev_messages = deepcopy(messages_f2v)  # Store previous messages for convergence check
    new_messages = Dict{Tuple{Int, Int}, Float64}()
    for iter in 1:max_iter
        # Update messages from variables to clauses
        new_messages = BP_iterate(order, messages, prev_messages, FG, edge_types)
        
        max_delta = 0.0
        for key in keys(new_messages)
            delta = abs(new_messages[key] - get(prev_messages, key, 0.0))
            max_delta = max(max_delta, delta)
        end
            
        prev_messages = deepcopy(new_messages)

        # 判断是否收敛
        if max_delta < tol && iter > 1  # 确保至少有一次迭代
            final_iter = iter
            break
        end
        final_iter = iter  # 更新最终迭代次数
    end
    

    if final_iter == max_iter
        return "UN-CONVERGED"
    else
        return new_messages
    end
end

function marginal(messages_f2v::Dict{Tuple{Int, Int}, TT}) where TT

    marginals = Dict{Int, TT}()

    for (f, v) in keys(messages_f2v)
        haskey(marginals, v) ? marginals[v] *= messages_f2v[(f, v)] : marginals[v] = messages_f2v[(f, v)]
    end

    sum_p = sum(values(marginals))
    for v in keys(marginals)
        marginals[v] /= sum_p  # Normalize marginals
    end
    return marginals
end

# function compute_entropy(alpha; k=3, N=100_000, num_iter=100, num_samples=10_000)
#     """
#     BP algorithm for calculating entropy density in random 3-SAT
#     Parameters:
#         alpha : clause density
#         k     : SAT problem order (default 3-SAT)
#         N     : population size
#         num_iter : iterations for population dynamics
#         num_samples : Monte Carlo samples for entropy calculation
#     """
#     # Initialize populations with uniform distributions
#     rng = MersenneTwister()  # Separate RNG for thread safety
#     eta = rand(rng, N)
#     eta_s = rand(rng, N)
    
#     # Population dynamics iterations
#     for _ in 1:num_iter
#         # Update ηs population (clause to variable messages)
#         for i in 1:N
#             selected = rand(rng, 1:N, k-1)
#             new_eta_s = 1.0 - prod(1.0 .- eta[selected])
#             replace_idx = rand(rng, 1:N)
#             eta_s[replace_idx] = new_eta_s
#         end
        
#         # Update η population (variable to clause messages)
#         for i in 1:N
#             p = rand(rng, Poisson(k * alpha / 2))
#             q = rand(rng, Poisson(k * alpha / 2))
#             total = p + q
            
#             if total == 0
#                 new_eta = 0.5
#             else
#                 selected = rand(rng, 1:N, total)
#                 pos_neg = eta_s[selected]
#                 pos = @view pos_neg[1:p]
#                 neg = @view pos_neg[p+1:end]
                
#                 # Stabilize computation using logarithms
#                 log_prod1 = sum(log, pos) + sum(x -> log(1 - x), neg)
#                 log_prod2 = sum(x -> log(1 - x), pos) + sum(log, neg)
#                 max_log = max(log_prod1, log_prod2)
#                 log_total = max_log + log(exp(log_prod1 - max_log) + exp(log_prod2 - max_log))
#                 new_eta = exp(log_prod1 - log_total)
#             end
            
#             replace_idx = rand(rng, 1:N)
#             eta[replace_idx] = new_eta
#         end
#     end
    
#     # Calculate entropy components
#     term1 = zeros(num_samples)
#     term2 = zeros(num_samples)
#     term3 = zeros(num_samples)
    
#     # Parallel computation using threads
#     Threads.@threads for i in 1:num_samples
#         rng = Random.MersenneTwister()  # Thread-local RNG
        
#         # Term 1 calculation
#         indices = rand(rng, 1:N, k)
#         product = prod(eta[indices])
#         term1[i] = log(1 - product + 1e-10)
        
#         # Term 2 calculation
#         p = rand(rng, Poisson(k * alpha / 2))
#         q = rand(rng, Poisson(k * alpha / 2))
#         total = p + q
        
#         if total == 0
#             term2[i] = log(2.0)
#         else
#             selected = rand(rng, 1:N, total)
#             pos_neg = eta_s[selected]
#             pos = @view pos_neg[1:p]
#             neg = @view pos_neg[p+1:end]
            
#             log_prod1 = sum(log, pos) + sum(x -> log(1 - x), neg)
#             log_prod2 = sum(x -> log(1 - x), pos) + sum(log, neg)
#             max_log = max(log_prod1, log_prod2)
#             term2[i] = max_log + log(exp(log_prod1 - max_log) + exp(log_prod2 - max_log))
#         end
        
#         # Term 3 calculation
#         idx_eta = rand(rng, 1:N)
#         idx_eta_s = rand(rng, 1:N)
#         term3[i] = log(eta_s[idx_eta_s] * eta[idx_eta] + 
#                       (1 - eta_s[idx_eta_s]) * (1 - eta[idx_eta]) + 1e-10)
#     end
    
#     # Final entropy calculation
#     s = alpha * mean(term1) + mean(term2) - (k * alpha / 2) * mean(term3)
#     return s
# end

# # Example usage
# let alpha = 4.0  # Clause density
#     entropy = compute_entropy(alpha)
#     println("Entropy density: ", entropy)
# end