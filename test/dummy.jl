# Testing if information of the Ginkgo library can be retrived correctly
using Test

# Dummy types and functions for illustration purposes. 
# FIXME: You'd replace these with your actual Julia implementations.
abstract type AbstractExecutor end
struct ReferenceExecutor <: AbstractExecutor end

# Test setup helper function
function setup_test(T)
    exec = ReferenceExecutor()
    data = Vector{T}(undef, 2)
    data[1] = 5
    data[2] = 2
    return exec, data
end

@testset "Array Tests" begin

    # Testing with supported types
    for T in [Int, Float64]

        exec, data = setup_test(T)
        
        @testset "KnowsItsSize" begin
            @test length(data) == 2
        end

    end
end
