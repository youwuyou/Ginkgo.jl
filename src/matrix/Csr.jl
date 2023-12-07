# gko::matrix::Csr<double, int>
const implemented = false

SUPPORTED_CSR_ELTYPE    = [Float32, Float64]
SUPPORTED_CSR_INDEXTYPE = [Int16, Int32, Int64]

"""
    SparseMatrixCsr{Tv, Ti} <: AbstractMatrix{Tv, Ti}

A type for representing sparse matrix and vectors in CSR format. Alias for `gko_matrix_csr_eltype_indextype_st` in C API.
    where `eltype` is one of the $SUPPORTED_CSR_ELTYPE and `indextype` is one of the $SUPPORTED_CSR_INDEXTYPE.
    For constructing a matrix, it is necessary to provide an executor using the [`create`](@ref) method.
 
### Examples

```julia-repl

```
# External links
$(_doc_external("gko::matrix::Csr<ValueType, IndexType>", "classgko_1_1matrix_1_1Csr"))
"""
mutable struct SparseMatrixCsr{Tv,Ti} <: AbstractSparseMatrix{Tv,Ti}
    ptr::Ptr{Cvoid}
    executor::Ptr{API.gko_executor_st}  # Pointer to the struct wrapping the executor shared ptr
    
    # Constructors for matrix with uninitialized values
    # function SparseMatrixCsr{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, m::Integer, n::Integer) where T
    #     @warn "Constructing $(m) x $(n) matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
    #     function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
    #     ptr = eval(:($API.$function_name($executor, $Dim{2}($m,$n))))
    #     return new{T}(ptr, executor)
    # end

    # function SparseMatrixCsr{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, size::Ginkgo.Dim2) where T
    #     @warn "Constructing $(size[1]) x $(size[2]) matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
    #     function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
    #     ptr = eval(:($API.$function_name($executor, $size)))
    #     return new{T}(ptr, executor)
    # end

    # Constructors for matrix with initialized values
    function SparseMatrixCsr{Tv,Ti}(filename::String, executor::Ptr{Ginkgo.API.gko_executor_st}) where {Tv,Ti}
        !isfile(filename) && error("File not found: $filename")
        function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_read")
        ptr = eval(:($API.$function_name($filename, $executor)))
        finalizer(delete_csr_matrix, new{Tv,Ti}(ptr, executor))
    end
    

    # size_t*
    # ASSERT_EQ(m->get_const_col_idxs(), nullptr);
    # ASSERT_NE(m->get_const_row_ptrs(), nullptr);
    # ASSERT_EQ(m->get_const_srow(), nullptr);

    # valuetype*
    # ASSERT_EQ(m->get_const_values(), nullptr);


    # Destructor
    function delete_csr_matrix(mat::SparseMatrixCsr{Tv,Ti}) where {Tv, Ti}
        @warn "Calling the destructor for SparseMatrixCsr{$Tv,$Ti}!"
        function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_delete")
        eval(:($API.$function_name($mat.ptr)))
    end
    
end


# Obtain numbers for important sizes
"""
    Base.size(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}

Returns the size of the sparse matrix/vector as a tuple
"""
function Base.size(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_size")
    dim =  (eval(:($API.$function_name($mat.ptr))))
    return (Cint(dim.rows), Cint(dim.cols))
end

"""
    nnz(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}

Get number of stored elements of the matrix
"""
function nnz(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_num_stored_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Ti(number)
end



# Obtain pointers to the underlying arrays
# for rowptr(A)
function get_rowptrs(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_row_ptrs")
    return eval(:($API.$function_name($mat.ptr)))
end

# for colvals(A)
function get_col_idxs(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_col_idxs")
    return eval(:($API.$function_name($mat.ptr)))
end

# for nonzeros(A)
function get_values(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_values")
    return eval(:($API.$function_name($mat.ptr)))
end


# Obtain arrays using unsafe_wrap
function rowptr(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    row_ptrs_raw_ptr = get_rowptrs(mat)
    num_entries = size(mat)[1] + 1

    # Use unsafe_wrap to create a Julia array that references the C array without copying.
    # The Julia array will be automatically garbage collected when it goes out of scope.
    unsafe_wrap(Vector{Ti}, row_ptrs_raw_ptr, num_entries)
end


function colvals(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    col_idxs_raw_ptr = get_col_idxs(mat)
    num_elem       = nnz(mat)
    unsafe_wrap(Vector{Ti}, col_idxs_raw_ptr, num_elem)
end

function nonzeros(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    values_raw_ptr = get_values(mat)
    num_elem       = nnz(mat)
    unsafe_wrap(Vector{Tv}, values_raw_ptr, num_elem)
end


# NOT BEING USED
function srow(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_srow")
    return eval(:($API.$function_name($mat.ptr)))
end

"""
    srows(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}

Returns the number of the srow stored elements (involved warps)
"""
function srows(mat::SparseMatrixCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_num_srow_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Ti(number)
end


# LinOp

"""
    spmm!(A::SparseMatrixCsr{Tv, Ti}, α::Dense{Tv}, x::Dense{Tv}, β::Dense{Tv}, y::Dense{Tv}) where {Tv, Ti}

    x = α*A*b + β*x

Applying to Dense matrices, computes an SpMM product.
"""
function spmm!(A::SparseMatrixCsr{Tv, Ti}, α::Dense{Tv}, x::Dense{Tv}, β::Dense{Tv}, y::Dense{Tv}) where {Tv, Ti}
    API.ginkgo_matrix_csr_f32_i32_apply(A.ptr, α.ptr, x.ptr, β.ptr, y.ptr)
end
