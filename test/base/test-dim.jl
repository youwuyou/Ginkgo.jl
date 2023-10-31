# Equivalent to `gko::dim<2> d1{};`
d1 = Ginkgo.Dim{2}()  # Assuming that a default constructed gko::dim<2> object has dimensions (0, 0)

# Equivalent to `gko::dim<2> d2{2, 3};`
d2 = Ginkgo.Dim{2}(2, 3)
d3 = Ginkgo.Dim{2}(3, 2)

# Equivalent to `gko::dim<2> d2{6};`
d4 = Ginkgo.Dim{2}(6)
d5 = Ginkgo.Dim{2}(2, 5)
d6 = Ginkgo.Dim{2}(2, 0)

@testset "Unit test: gko::dim<2> indexing                      " begin
    @test d2[1] == 2
    @test d2[2] == 3
    @test d4[1] == 6    

    to_be_set    = Ginkgo.Dim{2}(0, 0)
    to_be_set[1] = 3
    to_be_set[2] = 5

    @test to_be_set == (3, 5)
end

@testset "Unit test: gko::dim<2> null object                   " begin
    @test d1[1] == 0
    @test d1[2] == 0
end

@testset "Unit test: gko::dim<2> square object                 " begin
    @test d4[1] == 6
    @test d4[2] == 6
end

# Testing if gko::dim<2> and gko::dim<3> are sucessfully wrapped
@testset "Unit test: gko::dim<2> operator equality             " begin
    @test d1 != d2
    @test d2 == d2

    # EqualityReturnsFalseWhenDifferentColumns
    @test d2 != d5
end

@testset "Unit test: gko::dim<2> operator multiplication       " begin
    @test d1 * d2 == (0, 0)
    @test d2 * d3 == d4
end

@testset "Unit test: gko::dim<2> transpose                     " begin
    @test (d5[2], d5[1]) == transpose(d5)
end

@testset "Unit test: gko::dim<2> display dimension             " begin
    # Create an IOBuffer to capture the output (equivalent to std::ostringstream in C++)
    io = IOBuffer()

    # Output d2 to the IOBuffer
    print(io, d2)

    # Check the contents of the IOBuffer
    output_str = String(take!(io))
    
    @test output_str == "(2, 3)"
end

