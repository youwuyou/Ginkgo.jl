# gko::matrix::Csr<T>
for (Tv, Ti) in Iterators.product(SUPPORTED_CSR_ELTYPE, SUPPORTED_CSR_INDEXTYPE)
    @testset "Integration test: gko::matrix::Csr<$Tv, $Ti> read from file and retrieve information [implicit executor] " begin
        
        exec = create(:omp)
        with(EXECUTOR => exec) do
            A = Ginkgo.GkoCsr{Tv, Ti}("matrix/data/A.mtx")
            
            # Retrive dimensions
            @test Ginkgo.size(A)  == (19, 19)
            
            # Retrive nnz in the sparse matrix, number of elements stored
            @test Ginkgo.nnz(A)   == 147
            
            # Detail
            @test Ginkgo.srows(A) == 0
        end
    end
end


for (Tv, Ti) in Iterators.product(SUPPORTED_CSR_ELTYPE, SUPPORTED_CSR_INDEXTYPE)
    @testset "Integration test: gko::matrix::Csr<$Tv, $Ti> read from file and retrieve information [explicit executor]" begin
        exec = create(:omp)
        A = Ginkgo.GkoCsr{Tv, Ti}("matrix/data/A.mtx", exec)
        # Retrive dimensions
        @test Ginkgo.size(A)  == (19, 19)
    
        # Retrive nnz in the sparse matrix, number of elements stored
        @test Ginkgo.nnz(A)   == 147
    
        # Detail
        @test Ginkgo.srows(A) == 0
    end
end



# @testset "Integration test: gko::matrix::Csr<$Tv, $Ti> read from file and retrieve information                   " begin

#     exec = create(:omp)
#     A = Ginkgo.GkoCsr{Tv, Ti}("matrix/data/A.mtx", exec)

#     # Retrive dimensions
#     @test Ginkgo.size(A)  == (19, 19)

#     # Retrive nnz in the sparse matrix, number of elements stored
#     @test Ginkgo.nnz(A)   == 147

#     # Detail
#     @test Ginkgo.srows(A) == 0
    
#     # Retrive arrays
#     # @test Ginkgo.rowptr(A) ==
#     # @test Ginkgo.colvals(A) ==
#     # @test Ginkgo.nonzeros(A) ==
# end




# Check out
# struct SparseVector{Tv,Ti<:Integer} <: AbstractSparseVector{Tv,Ti}
#     n::Int              # Length of the sparse vector
#     nzind::Vector{Ti}   # Indices of stored values
#     nzval::Vector{Tv}   # Stored values, typically nonzeros
# end


# struct SparseMatrixCSR{Tv, Ti <: Integer} <: AbstractSparseVector{Tv, Ti}
#       ...
# end

# zeros(Ginkgo.Csr, m, n)


