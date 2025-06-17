using ProblemReductions
using Test

function dpll(cnf::CNF{T}) where T
    res, config = _dpll(deepcopy(cnf), Dict{T, Bool}())
    if !res
        return false, nothing
    else
        for clause in cnf.clauses
            for var in clause.vars
                if !(var.name in keys(config))
                    config[var.name] = true
                end
            end
        end
        return true, config
    end
end

function _dpll(cnf::CNF{T}, config::Dict{T, Bool}) where T
    isempty(cnf.clauses) && return true, config
    for clause in cnf.clauses
        if isempty(clause.vars)
            return false, nothing
        end
    end

    for clause in cnf.clauses
        if length(clause.vars) == 1
            var_fix = clause.vars[1]
            cnf = apply_config!(cnf, var_fix.name, !var_fix.neg)
            config[var_fix.name] = !var_fix.neg
            return _dpll(cnf, config)
        end
    end
    
    for clause in cnf.clauses
        for var in clause.vars
            if !(var.name in keys(config))
                config1 = deepcopy(config)
                config1[var.name] = !var.neg
                res1, config1 = _dpll(apply_config!(deepcopy(cnf), var.name, !var.neg), config1)
                res1 && return true, config1

                config2 = deepcopy(config)
                config2[var.name] = var.neg
                res2, config2 = _dpll(apply_config!(deepcopy(cnf), var.name, var.neg), config2)
                res2 && return true, config2
                
                return false, nothing
            end
        end
    end
end

function apply_config!(cnf::CNF{T}, var_name::T, val::Bool) where T
    for i in 1:length(cnf.clauses)
        clause = popfirst!(cnf.clauses)
        push_flag = true
        for j in 1:length(clause.vars)
            var = popfirst!(clause.vars)
            if var.name == var_name
                if !var.neg == val # the config is true
                    push_flag = false
                    break
                end
            else
                push!(clause.vars, var)
            end
        end
        if push_flag
            push!(cnf.clauses, clause)
        end
    end
    return cnf
end

@testset "dpll" begin
    bv1, bv2, bv3 = BoolVar.(["x", "y", "z"])
    clause1 = CNFClause([bv1, bv2, bv3])
    clause2 = CNFClause([BoolVar("w"), bv1, BoolVar("x", true)])
    cnf = CNF([clause1, clause2])

    res, config = dpll(cnf)
    @test res
    @test satisfiable(cnf, config)
end