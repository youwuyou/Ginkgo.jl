# gko::matrix::Csr<T>
for (Tv, Ti) in Iterators.product(SUPPORTED_CSR_ELTYPE, SUPPORTED_CSR_INDEXTYPE)
    @testset "Integration test: gko::matrix::Csr<$Tv, $Ti> read from file and retrieve information [implicit executor] " begin
        exec = Ginkgo.create(:omp)
        with(EXECUTOR => exec) do
            A = Ginkgo.GkoCsr{Tv, Ti}("matrix/data/A.mtx")
            
            # Retrive dimensions
            @test Ginkgo.size(A)  == (19, 19)
            
            # Retrive nnz in the sparse matrix, number of elements stored
            @test Ginkgo.get_nnz(A)   == 147
            
            # Detail
            @test Ginkgo.srows(A) == 0
        end
    end

    @testset "Integration test: gko::matrix::Csr<$Tv, $Ti> read from file and retrieve information [explicit executor]" begin
        exec = Ginkgo.create(:omp)
        A = Ginkgo.GkoCsr{Tv, Ti}("matrix/data/A.mtx", exec)
        # Retrive dimensions
        @test Ginkgo.size(A)  == (19, 19)
    
        # Retrive nnz in the sparse matrix, number of elements stored
        @test Ginkgo.get_nnz(A)   == 147
    
        # Detail
        @test Ginkgo.srows(A) == 0
    end

    @testset "Unit test: gko::matrix::Csr<$Tv, $Ti> convert from SparseMatrixCSC{Tv, Ti} [implicit executor] " begin
        exec = Ginkgo.create(:omp)
        with(EXECUTOR => exec) do
            # Initialize CSC and CSR representation of a randomly generated matrix
            maxnz, maxrows, maxcols = (10, 5, 6)

            I = rand(Ti(1):Ti(maxrows), maxnz)
            J = rand(Ti(1):Ti(maxcols), maxnz)
            V = rand(Tv,maxnz)

            CSC     = sparse(I,J,V)
            CSR     = sparsecsr(I,J,V)

            # Create data using internal ginkgo representation
            gko_CSR = GkoCsr(CSC)

            # Testing component-wise
            @test CSC == CSR
            @test nnz(CSR)   ==  Ginkgo.get_nnz(gko_CSR)
            @test issetequal(CSR.rowptr, Ginkgo.rowptr(gko_CSR))
            @test issetequal(CSR.colval, Ginkgo.colvals(gko_CSR))
        end
    end
end