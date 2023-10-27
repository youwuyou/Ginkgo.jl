# Dummy types and functions for illustration purposes. 
abstract type AbstractExecutor end
struct ReferenceExecutor <: AbstractExecutor end

# Test setup helper function for different types
function setup_test(T)
    exec = ReferenceExecutor()
    data = Vector{T}(undef, 2)

    if T <: Integer
        data[1] = 5
        data[2] = 2
    elseif T <: Real
        data[1] = 5.0
        data[2] = 2.0
    elseif T <: Complex
        data[1] = 5.0 + 3.0im
        data[2] = 2.0 + 1.0im
    else
        error("Type $T is not implemented or supported")
    end

    return exec, data
end

# Assertion helper function
# function assert_equal_to_original_data(data::Vector{T}, T) 
#     @test length(data) == 2
#     @test data[1] == T(5)
#     @test data[2] == T(2)
# end

# Testing with supported types
supported_types = [Int32, Float64, Complex]

for T in supported_types
    
    @testset "Reference test: initializing GkoArray<$T>" begin
    exec, data = setup_test(T)

    @debug "Initialized data" data

    # println(data);
    
    # @testset "CanBeCreatedWithoutAnExecutor" begin
    #     @test exec == nothing
    #     @test length(data) == 0
    # end

    # @testset "CanBeEmpty" begin
    #     a = Array{T}(exec, 0)
    #     @test length(data(a)) == 0
    # end

    # @testset "ReturnsNullWhenEmpty" begin
    #     a = Array{T}(exec, 0)
    #     @test data(a) != nothing
    # end

    # @testset "CanBeCreatedFromExistingData" begin
    #     a = Array{T}(exec, 3)  # Assuming you have a way to allocate like in C++
    #     @test length(data(a)) == 3
    # end

    @testset "KnowsItsSize" begin
        @test length(data) == 2
    end


    # @testset "ReturnsValidDataPtr" begin
    #     @test x.data[1] == T(5)
    #     @test x.data[2] == T(2)
    # end

    # @testset "KnowsItsExecutor" begin
    #     @test executor(x) === exec
    # end


    # @testset "ExecutorIsReferenceExecutor" begin
    #     @test isa(exec, ReferenceExecutor)
    # end


    # ... Add other tests similarly
    end

end
