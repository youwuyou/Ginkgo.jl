# gko::matrix::Dense<T>

# Create executor
exec = create(:omp)

for T in SUPPORTED_DENSE_ELTYPE
    # Create unitialized matrix, will trigger warnings
    M    = Ginkgo.GkoDense{T}(exec, Ginkgo.GkoDim{2}(2, 3))
    N    = Ginkgo.GkoDense{T}(exec, 8)

    # Create initialized vector
    vec1 = Ginkgo.GkoDense{T}(exec, 3, 1)
    fill!(vec1, T(1.0))

    @testset "Unit test: gko::matrix::Dense<$T> size                " begin
        @test Ginkgo.size(M) == (2, 3)
        @test Ginkgo.size(N) == (8, 8)
    end

    @testset "Unit test: gko::matrix::Dense<$T> no. element entries " begin
        @test Ginkgo.elements(M) == 6
        @test Ginkgo.elements(N) == 64
    end

    @testset "Unit test: gko::matrix::Dense<$T> get index          " begin
        num  = Ginkgo.number(exec, T(88.9))
        @test num[1,1] ≈ 88.9
    end

    @testset "Unit test: gko::matrix::Dense<$T> compute norms      " begin
        res = Ginkgo.number(exec, T(0.0))
        Ginkgo.norm1!(vec1, res)
        @test res[1,1] == 3

        Ginkgo.norm2!(vec1, res)

        # ≈ for the numerical instability
        @test res[1,1] ≈ sqrt(3)
    end
end
