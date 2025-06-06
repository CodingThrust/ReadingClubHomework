# Only used for Conjunctive Normal Form (CNF)
# Do not consider Empty clauses input, but empty clause is valid, which we will add in later version. And if we focus on K-SAT problem, which has the same length clauses.
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

function is_unit_clause(clause::Vector{Int}, assignment::Vector{Symbol})
    unassigned_count = 0
    satisfied = false
    
    for literal in clause
        var = abs(literal)
        if var > length(assignment)
            throw(ArgumentError("Clause contains literal $var beyond assignment length $(length(assignment))"))
        end
        value = assignment[var]
        
        # 检查子句是否已经被满足
        if (literal > 0 && value === :t) || (literal < 0 && value === :f)
            satisfied = true
            break
        elseif value == :u
            unassigned_count += 1
        end
    end
    
    return !satisfied && unassigned_count == 1
end

function is_satisfied(clause::Vector{Int64}, assignment::Vector{Symbol})
    # once one literal is true, thus clause is satisfied
    @assert length(clause) <= length(assignment) "Clause length exceeds assignment length, thus undefinite."
    if isempty(clause)
        return true
    end
    for literal in clause
        if literal > 0 && assignment[literal] == :t
            return true
        elseif literal < 0 && assignment[-literal] == :f
            return true
        end
    end
    return false
end

function is_satisfied_all(clauses::SATformula, assignment::SATsolution)
    clauses_set= clauses.clauses
    solution = assignment.solutions
    for clause in clauses_set
        if !is_satisfied(clause, solution)
            return false
        end
    end
    return true
end

function conflict(clauses::SATformula, assignment::SATsolution)
# check if there is any conflict in the clauses with the current all assigned assignment
    clauses_set = clauses.clauses
    solution = assignment.solutions
    
    for clause in clauses_set
        if is_clause_conflicted(clause, solution)
            return true 
        end
    end
    return false
end

function is_clause_conflicted(clause::Vector{Int}, assignment::Vector{Symbol})
 # check if a single clause is conflicted with the current assignment
    # A clause is conflicted if all its literals are assigned and none of them satisfy the clause.
    if isempty(clause)
        return true  # An empty clause is considered conflicted.
    end
    
    all_assigned = true
    clause_satisfied = false
    
    for literal in clause
        var = abs(literal)
        value = assignment[var]
        
        if value == :u
            all_assigned = false  # unassigned literal found
        elseif (literal > 0 && value == :t) || (literal < 0 && value == :f)
            clause_satisfied = true  # clause is satisfied by this literal
            break
        end
    end
    
    # Only when all literals are assigned and none satisfy the clause, it is conflicted.
    return all_assigned && !clause_satisfied
end

function unit_propagate(clauses::SATformula, assignment::SATsolution)
    # return unsolved clauses and updated assignment after unit propagation
    clauses_set = clauses.clauses
    solution = assignment.solutions
    while true
        unit_clauses = filter(x -> is_unit_clause(x, solution), clauses_set)
        if isempty(unit_clauses)
            break
        end
        for unit_clause in unit_clauses
            for literal in unit_clause
                if solution[abs(literal)] == :u
                    # If the variable is unassigned, assign it based on the unit clause.
                    if literal > 0
                        solution[literal] = :t
                    else
                        solution[-literal] = :f
                    end
                end
            end
            clauses_set = filter(c -> !is_satisfied(c, solution), clauses_set)
            
        end
    end
    return SATformula(clauses_set), SATsolution(solution, clauses)
end

function choose_literal(clauses::SATformula, assignment::SATsolution)
    # Choose the next unassigned variable.
    clauses_set = clauses.clauses
    solution = assignment.solutions
    idx = findfirst(x -> x == :u, solution)
    return idx
end

function dpll(clauses::SATformula, assignment::SATsolution) # initial default assignment is :u
    # solution = fill(:u, clauses.num_vars)
    # assignment = SATsolution(solution, clauses)
    unsolved_clauses, assignment = unit_propagate(clauses, assignment)

    if any(isempty, clauses.clauses) && !isempty(clauses.clauses)
        return false, assignment
    end

    if is_satisfied_all(clauses, assignment)
        return true, assignment
    elseif conflict(clauses, assignment)
        return false, assignment
    else
        literal = choose_literal(clauses, assignment)

        assignment_true = deepcopy(assignment)
        assignment_true.solutions[literal] = :t
        result, solution = dpll(clauses, assignment_true)
        if result
            return true, solution
        end

        assignment_false = deepcopy(assignment)
        assignment_false.solutions[literal] = :f
    
        return dpll(clauses, assignment_false)
    end
end

# function solve_sat(formula::SATformula)
#     assignment = fill(:u, formula.num_vars)
#     result = dpll(formula.clauses, assignment)
#     if result == true
#         return SATsolution(formula.clauses, formula.num_vars)
#     else
#         return :u
#     end
# end

# function print_solution(solution::SATsolution)
#     if solution == :u
#         println("No solution found.")
#     else
#         println("Solution found:")
#         for i in 1:solution.num_vars
#             if solution.clauses[i] == true
#                 println("Variable $i: true")
#             elseif solution.clauses[i] == false
#                 println("Variable $i: false")
#             else
#                 println("Variable $i: undefined")
#             end
#         end
#     end
# end
# function main()
#     clauses = [[1, -2], [-1, 2], [2, 3], [-3]]
#     formula = SATformula(clauses)
#     solution = solve_sat(formula)
#     print_solution(solution)
# end
# main()