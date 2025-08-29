# gko::matrix::Dense<T>
SUPPORTED_DENSE_ELTYPE = [Float32, Float64]

"""
    GkoDense{T} <: AbstractMatrix{T}

A type for representing dense matrix and vectors. Alias for `gko_matrix_dense_eltype_st` in C API.
    where `eltype` is one of the $SUPPORTED_DENSE_ELTYPE. For constructing a matrix, 
    it is necessary to provide an [`GkoExecutor`](@ref).

### Examples

```julia-repl
# Creating uninitialized vector of length 2, represented as a 2x1 dense matrix
julia> dim = (2,1); vec1 = GkoDense{Float32}(undef, dim, exec)

# Passing dimensions as a tuple of numbers
julia> vec2 = GkoDense{Float32}(undef, (2, 1), exec)

# Passing dimensions as numbers
julia> vec3 = GkoDense{Float32}(undef, 2, 1, exec)

# Creating initialized dense vector or matrix via reading from a `.mtx` file
julia> b = GkoDense{Float32}("b.mtx", exec)

```
# External links
$(_doc_external("gko::matrix::Dense<T>", "classgko_1_1matrix_1_1Dense"))
"""
mutable struct GkoDense{T} <: AbstractMatrix{T}
    ptr::Ptr{Cvoid}
    executor::GkoExecutor    

    ############################# CONSTRUCTOR ####################################
    # Constructors for matrix with uninitialized values
    function GkoDense{T}(::UndefInitializer, m::Integer, n::Integer, executor::GkoExecutor = EXECUTOR[]) where T
        function_name = Symbol("gko_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($(executor.ptr), ($m,$n))))
        finalizer(delete_dense_matrix, new{T}(ptr, executor))
    end

    function GkoDense{T}(::UndefInitializer, m::Tuple{Integer, Integer}, executor::GkoExecutor = EXECUTOR[]) where T
        function_name = Symbol("gko_matrix_dense_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($(executor.ptr), $m)))
        finalizer(delete_dense_matrix, new{T}(ptr, executor))
    end

    # Constructors for matrix with initialized values
    function GkoDense{T}(filename::String, executor::GkoExecutor = EXECUTOR[]) where T
        !isfile(filename) && error("File not found: $filename")        
        function_name = Symbol("gko_matrix_dense_", gko_type(T), "_read")
        ptr = eval(:($API.$function_name($filename, $(executor.ptr))))
        finalizer(delete_dense_matrix, new{T}(ptr, executor))
    end


    # TODO: any ways to avoid the copying of data?
    """
        GkoDense(values::Vector{T}, executor::GkoExecutor = EXECUTOR[]) where T

    Create a dense vector object, which is internally a nx1 matrix. We assume `stride == 1`.

    # Arguments
    - `n::Integer`: The length of the vector to be created.
    - `values::Vector{T}`: A one-dimensional array containing the elements of the vector. The type `T` specifies `eltype(values)`.
    - `executor::GkoExecutor`: The executor where the dense vector will be created. Defaults to `EXECUTOR[]`, which enables the implicit executor usage.

    # Returns
    A `GkoDense` object representing the dense vector of length n, which is also a nx1 matrix.

    # Example
    ```julia
    exec = create(:omp)
    values = rand(Float64, 20) # Generate random values
    vector = GkoDense(values, exec) # Create the GkoDense vector (nx1 matrix)
    ```
    """
    function GkoDense(values::Vector{T}, executor::GkoExecutor = EXECUTOR[]) where T
        function_name = Symbol("gko_matrix_dense_", gko_type(T), "_create_view")
        ptr = eval(:($API.$function_name($(executor.ptr), ($length($values), 1), $values, 1)))
        finalizer(delete_dense_matrix, new{T}(ptr, executor))
    end

    # TODO: add the support for dense matrix

    ############################# DESTRUCTOR ####################################
    function delete_dense_matrix(mat::GkoDense{T}) where T
        function_name = Symbol("gko_matrix_dense_", gko_type(T), "_delete")
        eval(:($API.$function_name($mat.ptr)))
    end
end

# Conversion
# Base.cconvert(::Type{API.gko_matrix_dense_f32_st}, obj::GkoDense) = API.gko_matrix_dense_f32_st()

# TODO: Overload element-wise access
# function Base.setindex!(M::GkoDense{T}, value, i::Int, j::Int) where T

# end

"""
    Base.getindex(mat::GkoDense{T}, m::Int, n::Int) where T

Obtain an element of the matrix, using Julia indexing
"""
function Base.getindex(mat::GkoDense{T}, m::Integer, n::Integer) where T
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_at")
    return (eval(:($API.$function_name($mat.ptr, $(m-1), $(n-1)))))
end

"""
    number(val::Number, exec::GkoExecutor = EXECUTOR[])

Initialize a 1x1 matrix representing a number with the provided value `val`
"""
number(val::Number, exec::GkoExecutor = EXECUTOR[]) = GkoDense([val], exec)

# function Base.ones(size::Int)
# end

# Array operations


# TODO: get the underlying value stored in GkoDense
# FIXME: how about using it directly in the type conversion?
# 1. we obtain the pointer to the array so no copy happens
# 2. do I get the value arrays on the device?? or it is just value array copy on host?

# function gko_matrix_dense_f64_get_values(mat_st_ptr)
#     ccall((:gko_matrix_dense_f64_get_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
# end

# function gko_matrix_dense_f64_get_const_values(mat_st_ptr)
#     ccall((:gko_matrix_dense_f64_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
# end



"""
    Base.fill!(mat::GkoDense{T}, val::G) where {T, G}

Fill the given matrix for all matrix elements with the provided value `val`
"""
function Base.fill!(mat::GkoDense{T}, val::G) where {T, G}
    T != G && @warn("Type mismatch of the eltype(mat) and the typeof(val) passed to the function")
    @info "Filling the matrix with constant values $val"
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_fill")
    eval(:($API.$function_name($mat.ptr, $val)))
end

"""
    Base.size(mat::GkoDense{T}) where T

Returns the size of the dense matrix/vector as a tuple
"""
function Base.size(mat::GkoDense{T}) where T
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_get_size")
    dim =  (eval(:($API.$function_name($mat.ptr))))
    return (Cint(dim.rows), Cint(dim.cols))
end

"""
    elements(mat::GkoDense{T}) where T

Get number of stored elements of the matrix
"""
function elements(mat::GkoDense{T}) where T
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_get_num_stored_elements")
    number = eval(:($API.$function_name($mat.ptr)))
    return Cint(number)
end

# Linear Algebra
"""
    norm1!(from::GkoDense{T}, to::GkoDense{T})

Computes the column-wise Euclidian (L¹) norm of this matrix.

# External links
$(_doc_external("void gko::matrix::Dense< ValueType >::compute_norm1", "classgko_1_1matrix_1_1Dense.html#a11c59175fcc040d99afe3acb39cbcb3e"))
"""
function norm1!(from::GkoDense{T}, to::GkoDense{G}) where {T, G}
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_compute_norm1")
    eval(:($API.$function_name($from.ptr, $to.ptr)))
end

"""
    norm2!(from::GkoDense{T}, to::GkoDense{T})

Computes the column-wise Euclidian (L²) norm of this matrix.

# External links
$(_doc_external("void gko::matrix::Dense< ValueType >::compute_norm2", "classgko_1_1matrix_1_1Dense.html#a19b9e51fd9922bab9637e42ab7209b8c"))
"""
function norm2!(from::GkoDense{T}, to::GkoDense{G}) where {T, G}
    function_name = Symbol("gko_matrix_dense_", gko_type(T), "_compute_norm2")
    eval(:($API.$function_name($from.ptr, $to.ptr)))
end


# """
#     mtx_buffer_str(mat::GkoDense{T}) where T

# Intermediate step that calls `gko::write` within C level wrapper. Allocates memory temporarily
# and returns a string pointer in C, then we utilize an IOBuffer to obtain a copy of the allocated cstring
# in Julia. In the end we deallocate the C string and return the buffered copy.
# """
# function mtx_buffer_str(mat::GkoDense{T}) where T
#     buf = IOBuffer()
#     cstr_ptr = API.gko_matrix_dense_f32_write_mtx(mat.ptr)
#     write(buf, unsafe_string(cstr_ptr))
#     API.c_char_ptr_free(cstr_ptr)
#     return String(take!(buf))
# end

# Display
# FIXME: way faster than the usual one?
# Base.show(io::IO, ::MIME"text/plain", mat::GkoDense{T}) where T = print(io, mtx_buffer_str(mat))