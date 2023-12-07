const SUPPORTED_ELEMENT_TYPE = [Int16, Int32, Int64, Float32, Float64, #= Complex{Float32}, Complex{Float64}=#]

# Subtype our gko::array<T> as subtype of one-dimensional arrays (or array-like types) with elements of type T. 
abstract type AbstractGkoVector{T} <: AbstractVector{T} end
scalartype(::AbstractGkoVector{T}) where {T} = T


# gko::array<T> x(exec,2);
# auto A = gko::array<T>(exec,2);
# A = Ginkgo.Array{Float64}(undef, exec, 2)
mutable struct Array{T} <: AbstractGkoVector{T}
    ptr::Ptr{Cvoid}
    executor::Ptr{Cvoid}  # Pointer to the struct wrapping the executor shared ptr

    # Constructor
    function Array{T}(::UndefInitializer, executor::Ptr{G}, dims::Int...) where {T, G}
        # Element type check
        T in SUPPORTED_ELEMENT_TYPE || throw(ArgumentError("unsupported element type $T"))

        # Dimension check
        size = prod(dims)
        size < 0 && throw(ArgumentError("invalid Array dimensions"))

        # Calling ginkgo to initialize the array
        function_name = Symbol("ginkgo_array_", gko_type(T), "_create")
        ptr = eval(:($API.$function_name($executor, $size)))
        finalizer(delete_array, new{T}(ptr, executor))
    end

    # Destructor
    function delete_array(arr::Array{T}) where T
        @warn "Calling the destructor for Array{$T}!"
        function_name = Symbol("ginkgo_array_", gko_type(T), "_delete")        
        eval(:($API.$function_name($arr.ptr)))
    end
end

# Overloading operations
# allows us to pass XXVec objects directly into Cvoid ccall signatures
Base.cconvert(::Type{Cvoid}, obj::AbstractGkoVector) = obj.ptr

# allows us to pass XXVec objects directly into Ptr{Cvoid} ccall signatures
Base.unsafe_convert(::Type{Ptr{Cvoid}}, obj::AbstractGkoVector) =
    convert(Ptr{Cvoid}, pointer_from_objref(obj))

Base.eltype(::AbstractGkoVector{T}) where {T} = T

function Base.size(array::AbstractGkoVector{T}) where {T}
    function_name = Symbol("ginkgo_array_", gko_type(T), "_get_num_elems")
    return eval(:($API.$function_name($array.ptr)))
end

function Base.isempty(array::AbstractGkoVector{T}) where {T}
    function_name = Symbol("ginkgo_array_", gko_type(T), "_get_num_elems")
    return eval(:($API.$function_name($array.ptr))) == 0
end