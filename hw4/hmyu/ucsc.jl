using ProblemReductions
using Random, Test
"""
uc(cnf::CNF{T}) -> Bool

The Unit Clause (UC) algorithm attempts to determine the satisfiability of a given CNF formula. It uses unit clause propagation and random assignments to iteratively simplify the formula.

Parameters:
- `cnf`: A CNF formula represented as a `CNF{T}` object, where `T` is the type of variable names.

Returns:
- `true`: Indicates that the CNF formula is satisfiable.
- `false`: Indicates "don't know," meaning the algorithm could not determine satisfiability.

Notes:
- This algorithm may return `false` for satisfiable formulas in some cases.

"""
function uc(cnf::CNF{T}) where T
    assignments = Dict{T, Bool}()
    cnf1 = deepcopy(cnf)
    unsatisfied_clauses = get_unsatisfied_clauses(cnf1, assignments)

    # Process unsatisfied clauses until all are satisfied or a conflict occurs
    while !isempty(unsatisfied_clauses)
        unit_clauses = get_unit_clauses(unsatisfied_clauses)
        if !isempty(unit_clauses)
            # Handle unit clauses by assigning values to their variables
            chosen_clause = rand(unit_clauses)
            chosen_var = chosen_clause.vars[1]
            assignments[chosen_var.name] = !chosen_var.neg
        else
            # Randomly assign values to unset variables if no unit clauses exist
            unset_vars = [var for clause in unsatisfied_clauses for var in clause.vars if !(var.name in keys(assignments))]
            isempty(unset_vars) && return false
            chosen_var = rand(unset_vars)
            assignments[chosen_var.name] = rand(Bool)
        end

        # Apply the assignment and update the CNF formula
        cnf1 = apply_assignment!(cnf1, chosen_var.name, assignments[chosen_var.name])

        # Check for conflicts (empty clauses)
        if any(is_empty_clause(clause) for clause in cnf1.clauses)
            return false
        end
        unsatisfied_clauses = get_unsatisfied_clauses(cnf1, assignments)
    end
    return true
end


"""
sc(cnf::CNF{T}) -> Bool

The Short Clause (SC) algorithm attempts to determine the satisfiability of a given CNF formula. It uses unit clause propagation, two-clause handling, and random assignments to iteratively simplify the formula.

Parameters:
- `cnf`: A CNF formula represented as a `CNF{T}` object, where `T` is the type of variable names.

Returns:
- `true`: Indicates that the CNF formula is satisfiable.
- `false`: Indicates "don't know," meaning the algorithm could not determine satisfiability.

Notes:
- This algorithm may return `false` for satisfiable formulas in some cases.

"""
function sc(cnf::CNF{T}) where T
    assignments = Dict{T, Bool}()
    cnf1 = deepcopy(cnf)
    unsatisfied_clauses = get_unsatisfied_clauses(cnf1, assignments)

    # Process unsatisfied clauses until all are satisfied or a conflict occurs
    while !isempty(unsatisfied_clauses)
        unit_clauses = get_unit_clauses(unsatisfied_clauses)
        two_clauses = get_two_clauses(unsatisfied_clauses)
        if !isempty(unit_clauses)
            # Handle unit clauses by assigning values to their variables
            chosen_clause = rand(unit_clauses)
            chosen_var = chosen_clause.vars[1]
            assignments[chosen_var.name] = !chosen_var.neg
        elseif !isempty(two_clauses)
            # Handle 2-clauses by assigning values to one of their variables
            chosen_clause = rand(two_clauses)
            chosen_var = rand(chosen_clause.vars)
            assignments[chosen_var.name] = !chosen_var.neg
        else
            # Randomly assign values to unset variables if no unit or two-clauses exist
            unset_vars = [var for clause in unsatisfied_clauses for var in clause.vars if !(var.name in keys(assignments))]
            isempty(unset_vars) && return false
            chosen_var = rand(unset_vars)
            assignments[chosen_var.name] = rand(Bool)
        end

        # Apply the assignment and update the CNF formula
        cnf1 = apply_assignment!(cnf1, chosen_var.name, assignments[chosen_var.name])

        # Check for conflicts (empty clauses)
        if any(is_empty_clause(clause) for clause in cnf1.clauses)
            return false
        end
        unsatisfied_clauses = get_unsatisfied_clauses(cnf1, assignments)
    end
    return true
end

function apply_assignment!(cnf::CNF{T}, var_name::T, value::Bool) where T
    updated_clauses = Vector{CNFClause{T}}()
    for i in 1:length(cnf.clauses)
        clause = popfirst!(cnf.clauses)
        push_flag = true
        new_vars = Vector{typeof(clause.vars[1])}()
        for j in 1:length(clause.vars)
            var = popfirst!(clause.vars)
            if var.name == var_name
                if !var.neg == value
                    push_flag = false
                    break
                end
            else
                push!(new_vars, var)
            end
        end
        if push_flag
            push!(updated_clauses, CNFClause(new_vars))
        end
    end
    return CNF(updated_clauses)
end

function is_satisfied(clause::CNFClause{T}, assignments::Dict{T, Bool}) where T
    for var in clause.vars
        if var.name in keys(assignments) && assignments[var.name] == !var.neg
            return true
        end
    end
    return false
end

function is_empty_clause(clause::CNFClause{T}) where T
    isempty(clause.vars)
end

function get_unit_clauses(clauses::Vector{CNFClause{T}}) where T
    return [clause for clause in clauses if length(clause.vars) == 1]
end

function get_two_clauses(clauses::Vector{CNFClause{T}}) where T
    return [clause for clause in clauses if length(clause.vars) == 2]
end

function get_unsatisfied_clauses(cnf::CNF{T}, assignments::Dict{T, Bool}) where T
    return [clause for clause in cnf.clauses if !is_satisfied(clause, assignments)]
end


@testset "uc and sc" begin
    bv1, bv2, bv3, bv4 = BoolVar.(["x", "y", "z", "w"])
    clause1 = CNFClause([bv1, bv2, bv3])  # (x ∨ y ∨ z)
    clause2 = CNFClause([bv4, bv1, ¬bv1])  # (w ∨ x ∨ ¬x)
    cnf1 = CNF([clause1, clause2])

    @test uc(cnf1)
    @test sc(cnf1)

    clause3 = CNFClause([bv1, bv2])  # (x ∨ y)
    clause4 = CNFClause([¬bv3, ¬bv4])  # (¬z ∨ ¬w)
    cnf2 = CNF([clause3, clause4])

    @test uc(cnf2)
    @test sc(cnf2)

    clause5 = CNFClause([BoolVar("a")])  # (a)
    clause6 = CNFClause([BoolVar("a", true)])  # (¬a)
    unsat_cnf = CNF([clause5, clause6])

    @test !uc(unsat_cnf)
    @test !sc(unsat_cnf)
end
