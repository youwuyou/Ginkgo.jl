# gko::matrix::Csr<double, int>
SUPPORTED_CSR_ELTYPE    = [Float32]
SUPPORTED_CSR_INDEXTYPE = [Int32]

"""
    GkoCsr{Tv, Ti} <: AbstractMatrix{Tv, Ti}

A type for representing sparse matrix and vectors in CSR format. Alias for `gko_matrix_csr_eltype_indextype_st` in C API.
    where `eltype` is one of the $SUPPORTED_CSR_ELTYPE and `indextype` is one of the $SUPPORTED_CSR_INDEXTYPE.
    For constructing a matrix, it is necessary to provide an [`GkoExecutor`](@ref).
    
### Examples

```julia-repl
# Read matrix and vector from a mtx file
A = GkoCsr{Tv, Ti}("data/A.mtx", exec)
```
# External links
$(_doc_external("gko::matrix::Csr<ValueType, IndexType>", "classgko_1_1matrix_1_1Csr"))
"""
mutable struct GkoCsr{Tv,Ti} <: AbstractSparseMatrix{Tv,Ti}
    ptr::Ptr{Cvoid}
    executor::GkoExecutor

    ############################# CONSTRUCTOR ####################################
    # Constructors for matrix with initialized values
    function GkoCsr{Tv,Ti}(filename::String, executor::GkoExecutor = EXECUTOR[]) where {Tv,Ti}
        !isfile(filename) && error("File not found: $filename")
        function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_read")
        # Pass the void pointer to executor_st to C API
        ptr = eval(:($API.$function_name($filename, $(executor.ptr))))
        finalizer(delete_csr_matrix, new{Tv,Ti}(ptr, executor));
    end

    ############################# DESTRUCTOR ####################################
    function delete_csr_matrix(mat::GkoCsr{Tv,Ti}) where {Tv, Ti}
        @warn "Calling the destructor for GkoCsr{$Tv,$Ti}!"
        function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_delete")
        eval(:($API.$function_name($mat.ptr)))
    end
    
end

# Obtain numbers for important sizes
"""
    Base.size(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}

Returns the size of the sparse matrix/vector as a tuple
"""
function Base.size(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_size")
    dim =  (eval(:($API.$function_name($mat.ptr))))
    return (Cint(dim.rows), Cint(dim.cols))
end

"""
    nnz(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}

Get number of stored elements of the matrix
"""
function nnz(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_num_stored_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Ti(number)
end



# Obtain pointers to the underlying arrays
# for rowptr(A)
function get_rowptrs(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_row_ptrs")
    return eval(:($API.$function_name($mat.ptr)))
end

# for colvals(A)
function get_col_idxs(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_col_idxs")
    return eval(:($API.$function_name($mat.ptr)))
end

# for nonzeros(A)
function get_values(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_values")
    return eval(:($API.$function_name($mat.ptr)))
end


# Obtain arrays using unsafe_wrap
function rowptr(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    row_ptrs_raw_ptr = get_rowptrs(mat)
    num_entries = size(mat)[1] + 1

    # Use unsafe_wrap to create a Julia array that references the C array without copying.
    # The Julia array will be automatically garbage collected when it goes out of scope.
    unsafe_wrap(Vector{Ti}, row_ptrs_raw_ptr, num_entries)
end


function colvals(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    col_idxs_raw_ptr = get_col_idxs(mat)
    num_elem       = nnz(mat)
    unsafe_wrap(Vector{Ti}, col_idxs_raw_ptr, num_elem)
end

function nonzeros(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    values_raw_ptr = get_values(mat)
    num_elem       = nnz(mat)
    unsafe_wrap(Vector{Tv}, values_raw_ptr, num_elem)
end


# NOT BEING USED
function srow(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_const_srow")
    return eval(:($API.$function_name($mat.ptr)))
end

"""
    srows(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}

Returns the number of the srow stored elements (involved warps)
"""
function srows(mat::GkoCsr{Tv,Ti}) where {Tv,Ti}
    function_name = Symbol("ginkgo_matrix_csr_", gko_type(Tv), "_", gko_type(Ti), "_get_num_srow_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Ti(number)
end


# LinOp
"""
    spmm!(A::GkoCsr{Tv, Ti}, α::Dense{Tv}, x::Dense{Tv}, β::Dense{Tv}, y::Dense{Tv}) where {Tv, Ti}

Applying to Dense matrices, computes an SpMM product. x = α*A*b + β*x.
"""
function spmm!(A::GkoCsr{Tv, Ti}, α::GkoDense{Tv}, x::GkoDense{Tv}, β::GkoDense{Tv}, y::GkoDense{Tv}) where {Tv, Ti}
    API.ginkgo_matrix_csr_f32_i32_apply(A.ptr, α.ptr, x.ptr, β.ptr, y.ptr)
end
