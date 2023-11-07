# gko::matrix::Dense<T>
const implemented = false

SUPPORTED_DENSE_ELTYPE = [Float32, Float64]

"""
    Dense{T} <: AbstractMatrix{T}

A type for representing dense matrix and vectors. Alias for `gko_matrix_dense_eltype_st` in C API.
    where `eltype` is one of the $SUPPORTED_DENSE_ELTYPE. For constructing a matrix, it is
    necessary to provide an executor using the [`create`](@ref) method.

### Examples

```julia-repl
# Creating uninitialized vector of length 2, represented as a 2x1 dense matrix
julia> dim = Ginkgo.Dim{2}(2,1); vec1 = Ginkgo.Dense{Float32}(exec, dim)

# Passing a tuple
julia> vec2 = Ginkgo.Dense{Float32}(exec, (2, 1));

# Passing numbers
julia> vec3 = Ginkgo.Dense{Float32}(exec, 2, 1);

# Creating uninitialized dense square matrix
julia> square_mat = Ginkgo.Dense{Float32}(exec, 2);

# Creating initialized dense vector or matrix via reading from a `.mtx` file
julia> b = Ginkgo.Dense{Float32}("b.mtx", exec);

```
# External links
$(_doc_external("gko::matrix::Dense<T>", "classgko_1_1matrix_1_1Dense"))
"""
mutable struct Dense{T} <: AbstractMatrix{T}
    ptr::Ptr{Cvoid}
    executor::Ptr{API.gko_executor_st}  # Pointer to the struct wrapping the executor shared ptr
    
    # Constructors for matrix with uninitialized values
    function Dense{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, m::Integer, n::Integer) where T
        # @warn "Constructing $(m) x $(n) matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
        function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($executor, $Dim{2}($m,$n))))
        return new{T}(ptr, executor)
    end

    function Dense{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, size::Integer) where T
        # @warn "Constructing $(size) x $(size) square matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
        function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($executor, $Dim{2}($size,$size))))
        return new{T}(ptr, executor)
    end

    function Dense{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, m::Tuple{Integer, Integer}) where T
        # @warn "Constructing $(m[1]) x $(m[2]) matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
        function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($executor, $m)))
        return new{T}(ptr, executor)
    end

    function Dense{T}(executor::Ptr{Ginkgo.API.gko_executor_st}, size::Ginkgo.Dim2) where T
        # @warn "Constructing $(size[1]) x $(size[2]) matrix with uninitialized values. Displayed values may not be meaningful. It's advisable to initialize the matrix before usage."
        function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($executor, $size)))
        return new{T}(ptr, executor)
    end

    # Constructors for matrix with initialized values
    function Dense{T}(filename::String, executor::Ptr{Ginkgo.API.gko_executor_st}) where T
        !isfile(filename) && error("File not found: $filename")        
        function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_read")
        ptr = eval(:($API.$function_name($filename, $executor)))
        return new{T}(ptr, executor)
    end

    # Destructor
    # TODO: this looks weird... maybe create a delete function for all matrices
    # and delete? Maybe necessary to put matrix types as gko_matrix_dense_f32
    # function ginkgo_matrix_delete(mat_st_ptr)
    #     ccall((:ginkgo_matrix_delete, libginkgo), Cvoid, (gko_matrix_dense_f32,), mat_st_ptr)
    # end
end


# Conversion
# Base.cconvert(::Type{API.gko_matrix_dense_f32_st}, obj::Dense) = API.gko_matrix_dense_f32_st()

# TODO: Overload element-wise access
# function Base.setindex!(M::Dense{T}, value, i::Int, j::Int) where T

# end

"""
    Base.getindex(mat::Dense{T}, m::Int, n::Int) where T

Obtain an element of the matrix, using Julia indexing
"""
function Base.getindex(mat::Dense{T}, m::Integer, n::Integer) where T
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_at")
    return (eval(:($API.$function_name($mat.ptr, $(m-1), $(n-1)))))
end

"""
    number(exec, val::Number)

Initialize a 1x1 matrix representing a number with the provided value `val`
"""
function number(exec, val::Number)
    T = typeof(val)
    mat = Dense{T}(exec, 1)
    fill!(mat, val)
    return mat
end

# function Base.ones(exec, size::Int)
# end

# Array operations
"""
    Base.fill!(mat::Dense{T}, val::G) where {T, G}

Fill the given matrix for all matrix elements with the provided value `val`
"""
function Base.fill!(mat::Dense{T}, val::G) where {T, G}
    T != G && @warn("Type mismatch of the eltype(mat) and the typeof(val) passed to the function")
    @info "Filling the matrix with constant values $val"
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_fill")
    eval(:($API.$function_name($mat.ptr, $val)))
end

"""
    Base.size(mat::Dense{T}) where T

Returns the size of the dense matrix/vector as a tuple
"""
function Base.size(mat::Dense{T}) where T
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_get_size")
    dim =  (eval(:($API.$function_name($mat.ptr))))
    return (Cint(dim.rows), Cint(dim.cols))
end

"""
    elements(mat::Dense{T}) where T

Get number of stored elements of the matrix
"""
function elements(mat::Dense{T}) where T
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_get_num_stored_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Cint(number)
end

# Linear Algebra
"""
    norm1!(from::Dense{T}, to::Dense{T})

Computes the column-wise Euclidian (L²) norm of this matrix.

# External links
$(_doc_external("void gko::matrix::Dense< ValueType >::compute_norm1", "classgko_1_1matrix_1_1Dense.html#a11c59175fcc040d99afe3acb39cbcb3e"))
"""
function norm1!(from::Dense{T}, to::Dense{G}) where {T, G}
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_compute_norm1")
    eval(:($API.$function_name($from.ptr, $to.ptr)))
end

"""
    norm2!(from::Dense{T}, to::Dense{T})

Computes the column-wise Euclidian (L²) norm of this matrix.

# External links
$(_doc_external("void gko::matrix::Dense< ValueType >::compute_norm2", "classgko_1_1matrix_1_1Dense.html#a19b9e51fd9922bab9637e42ab7209b8c"))
"""
function norm2!(from::Dense{T}, to::Dense{G}) where {T, G}
    function_name = Symbol("ginkgo_matrix_dense_", gko_type(T), "_compute_norm2")
    eval(:($API.$function_name($from.ptr, $to.ptr)))
end


"""
mtx_buffer_str(mat::Dense{T}) where T

Intermediate step that calls `gko::write` within C level wrapper. Allocates memory temporarily
and returns a string pointer in C, then we utilize an IOBuffer to obtain a copy of the allocated cstring
in Julia. In the end we deallocate the C string and return the buffered copy.
"""
function mtx_buffer_str(mat::Dense{T}) where T
    buf = IOBuffer()
    cstr_ptr = API.ginkgo_matrix_dense_f32_write_mtx(mat.ptr)
    write(buf, unsafe_string(cstr_ptr))
    API.c_char_ptr_free(cstr_ptr)
    return String(take!(buf))
end

# Display
# FIXME: way faster than the usual one
Base.show(io::IO, ::MIME"text/plain", mat::Dense{T}) where T = print(io, mtx_buffer_str(mat))

if implemented
    # overload element-wise access
        
        # LinearAlgebra.lmult!(a::Number, B::Ginkgo.Dense), rmult!(a::Number, B::Ginkgo.Dense) calls scale()
        # LinearAlgebra.BLAS.scal(a::Number, X::Dense{T}) calls scale()
        # ?write
        
        # Base.transpose(A) calls transpose() 


    # Conversion
    # function LinearAlgebra.lmult!(a::Number, B::Dense)
    #     # Call scale()
        
    # end

    # function LinearAlgebra.rmult!(a::Number, B::Dense)
    #             # Call scale()
        
    # end

    # function Dense{T}(exec::Ptr{Ginkgo.API.gko_executor_st}, ::UndefInitializer, m::Int, n::Int) where T
    
    # end


    # Base.ones(Float64, n) calls create_ones()
    # Base.fill(value, m) calls  void gko::matrix::Dense< ValueType >::fill(const ValueType value)	


    # Computation
    # => compute_mean()
    # => extract_diagonal

    # For both matrix and vector

    # Base.ndims(A::Ginkgo.DenseArray{T, N}) -> Int
    # Base.size(A::Ginkgo.DenseArray{T, N}, [dim]) -> Int
    # Base.conj!(A::Ginkgo.DenseArray{T, N))
    # Base.stride(A::Ginkgo.DenseArray{T, N), k::Int)
    # julia> A = fill(1, (3,4,5));

    # julia> stride(A,2)
    # 3

    # julia> stride(A,3)
    # 12

    # Base.strides(A::Ginkgo.DenseArray{T,N}) ??
    # julia> A = fill(1, (3,4,5));

    # julia> strides(A)
    # (1, 3, 12)


    # Base.Broadcast
    # Base.setindex!




    # SubArrays 
    # Base.view print the matrix
    # Base.reshape(A, dims)
    # Base.permutedims => column_permute()?
    # Base.invperm



    # Array functions
    # rotl/rotr 90/180
    # reverse!
    # Base.accumulate
    # cumprod,cumsum,
    # Base.diff

    # TODO: ask Valentin if rather using AbstractArray or AbstractMatrix
    # struct DenseArray{T, N} <: AbstractArray{T, N}
    #     ...
    # end

    # # todo create alias for Ginkgo.DenseVector{T} and Ginkgo.Dense{T}
    # DenseVector = DenseArray{T, 1}
    # Dense = DenseArray{T, 2}

    # todo create union type
    # Ginkgo.DenseVecOrMat = Union{Ginkgo.DenseArray{T, 1}, Ginkgo.DenseArray{T, 2}
    # Ginkgo.DenseVector{Float64}(missing, m)


    # Ginkgo.Dense{Float64}(exec, undef, m, n)
    # Ginkgo.Dense{Float64}(exec, nothing, m, n)
    # M = Ginkgo.Dense{Float64}(exec, missing, m, n)
end