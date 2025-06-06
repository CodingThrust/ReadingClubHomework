using Test
include("DPLL.jl")

@testset "is_satisfied" begin
    # Test case 1: Clause satisfied by positive literal
    # :t is true, :f is false, :u is undetermined
    clause1 = [1, -2]
    assignment1 = [:t, :f]
    @test is_satisfied(clause1, assignment1) == true

    # Test case 2: Clause satisfied by negative literal
    clause2 = [1, -2]
    assignment2 = [:t, :t]
    @test is_satisfied(clause2, assignment2) == true

    # Test case 3: Clause not satisfied
    clause3 = [1, -2]
    assignment3 = [:f, :t]
    @test is_satisfied(clause3, assignment3) == false

    # Test case 4: Empty clause (should be satisfied)
    clause4 = []
    assignment4 = [:t, :f]
    @test_broken is_satisfied(clause4, assignment4) == true

    # Test case 5: Clause with clause has no common length with assignment
    clause5 = [-1, -2]
    assignment5 = [:f, :f, :f]
    @test is_satisfied(clause5, assignment5) == true

    # # Test case 6: Clause with clause has additional literal beyond assignment
    # clause6 = [1, -2, 3]
    # assignment6 = [:t, :f]
    # @test_throws ArgumentError is_satisfied(clause6, assignment6)

    # Test case 7: Clause with clause has additional literal beyond assignment
    clause7 = [1, -2, 3]
    assignment7 = [:t, :f, :u]
    @test is_satisfied(clause7, assignment7) == true

    # Test case 8: Clause with clause has additional literal beyond assignment
    clause8 = [1, -2, 3]
    assignment8 = [:f, :t, :u]
    @test is_satisfied(clause8, assignment8) == false
end

@testset "is_satisfied_all" begin
    # Test case 1: All clauses satisfied
    clauses1 = SATformula([[1, -2], [-1, 2]])
    assignment1 = SATsolution([:t, :f], clauses1)
    @test is_satisfied_all(clauses1, assignment1) == false

    # Test case 2: Not all clauses satisfied
    clauses2 = SATformula([[-1, -2, 3], [-3, 4]])
    assignment2 = SATsolution([:t, :t, :t, :t], clauses2)
    @test is_satisfied_all(clauses2, assignment2) == true

    # Test case 3: Empty clauses (should be satisfied)
    # clauses3 = SATformula([])
    # assignment3 = [:t, :f]
    # @test is_satisfied_all(clauses3, assignment3) == true
end

@testset "is_unit_clause" begin
    clause = [1, -2, 3]
    assignment = [:f, :u, :f]
    # Test case 1: Unit clause
    @test is_unit_clause(clause, assignment) == true
    # Test case 2: Not a unit clause
    @test is_unit_clause(clause, [:f, :t, :f]) == false
    # Test case 3: Empty clause (should not be considered a unit clause)   
    @test is_unit_clause([2], assignment) == true 
end

@testset "unit_propagate" begin
    # Test case 1: Simple unit propagation
    clauses1 = SATformula([[1, -2, 3], [-1, 2], [2]])
    assignment1 = SATsolution([:u, :u, :u], clauses1)
    new_clauses1, new_assignment1 = unit_propagate(clauses1, assignment1)
    @test new_assignment1 == SATsolution([:u, :t, :u], clauses1)
    @test new_clauses1 == SATformula([[1, -2, 3]])

    # Test case 2: No unit clauses
    clauses2 = SATformula([[1, -2], [-3]])
    assignment2 = SATsolution([:u, :u, :u], clauses2)
    new_clauses2, new_assignment2 = unit_propagate(clauses2, assignment2)
    @test new_assignment2 == SATsolution([:u, :u, :f], clauses2)
    @test new_clauses2 == SATformula([[1, -2]])

    # # Test case 3: Empty clauses
    # clauses3 = SATformula([])
    # assignment3 = SATsolution([:u], clauses3)
    # new_clauses3, new_assignment3 = unit_propagate(clauses3, assignment3)
    # @test new_assignment3 == [:u]
    # @test new_clauses3 == []
    # Test case 4: All clauses satisfied
    clauses = SATformula([[-2, -3, -4, 5], [-1, -5, 6], [-5, 7], [-1, -6, -7], [-1, -2, 5], [-1, -3, 5], [-1, -4, 5], [-1, 2, 3, 4, 5, -6]])
    assignment = SATsolution([:t, :t, :u, :u, :u, :u, :u],clauses)
    unsolved_clauses, assignment = unit_propagate(clauses, assignment)
    @test assignment.solutions == [:t, :t, :u, :u, :t, :t, :t]
    @test unsolved_clauses.clauses == [[-1, -6, -7]]
end 

@testset "conflict" begin
    @test is_clause_conflicted([1, -2], [:t, :f]) == false
    @test is_clause_conflicted([1, -2], [:f, :t]) == true
    @test is_clause_conflicted([1, -2], [:f, :f]) == false  

    clauses = SATformula([[1, -2], [-1, 2]])
    assignment = SATsolution([:t, :f], clauses)
    @test conflict(clauses, assignment) == true
end

@testset "choose_literal" begin
    # Test case 1: Choose a literal from a simple clause
    clauses1 = SATformula([[1, -2, 3]])
    assignment1 = SATsolution([:u, :u, :u], clauses1)
    literal1 = choose_literal(clauses1, assignment1)
    @test literal1 == 1
end


# Test cases for DPLL algorithm
@testset "DPLL Tests" begin
    # Test case 1: Simple satisfiable formula
    clauses1 = SATformula([[-2, -3, -4, 5], [-1, -5, 6], [-5, 7], [-1, -6, -7], [-1, -2, 5], [-1, -3, 5], [-1, -4, 5], [-1, 2, 3, 4, 5, -6]])
    assignment1 = SATsolution(fill(:u, 7), clauses1)
    result1 = dpll(clauses1, assignment1)
    @test result1[2].solutions == [:t, :f, :f, :f, :f, :f, :u]

    # Test case 2: Simple unsatisfiable formula
    clauses2 = SATformula([[1, -2], [-1, 2], [2, -3]])
    assignment2 = SATsolution(fill(:u, 3), clauses2)
    result2 = dpll(clauses2, assignment2)
    @test result2[2].solutions == [:t,:t,:u]

    # Test case 3: More complex satisfiable formula
    clauses3 = SATformula([[1, 2], [-1, -3], [3]])
    assignment3 = SATsolution(fill(:u, 3), clauses3)
    result3 = dpll(clauses3, assignment3)
    @test result3[2].solutions == [:f,:t,:t]

    # Test case 4: Empty clause (unsatisfiable)
    formula4 = SATformula([[1, -2], [-1, 2], []])
    assignment4 = SATsolution(fill(:u, 2), formula4)
    result4 = dpll(formula4, assignment4)
    @test result4[1] == false

    # Test case 5: All variables are true
    formula5 = SATformula([[1], [2], [3]])
    assignment5 = SATsolution(fill(:u, 3), formula5)
    result5 = dpll(formula5, assignment5)
    @test result5[2].solutions == [:t,:t,:t]

end