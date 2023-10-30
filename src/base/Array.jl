const SUPPORTED_ELEMENT_TYPE = [Int16, Int32, Int64, Float32, Float64, #= Complex{Float32}, Complex{Float64}=#]

# Subtype our gko::array<T> as subtype of one-dimensional arrays (or array-like types) with elements of type T. 
abstract type AbstractGkoVector{T} <: AbstractVector{T} end
scalartype(::AbstractGkoVector{T}) where {T} = T

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

        # Call the ginkgo_create_array function to get the ptr
        @GC.preserve executor begin
            function_name = Symbol("ginkgo_create_array_", gko_type(T))
            ptr = eval(:($API.$function_name($executor, $size)))

            # Call the default constructor
            return new{T}(ptr, executor)
        end
    end

    # Destructor
    # TODO: choose according to types?

end

# TODO: use the finalizer to prevent memory leak on both the array and the executor!


# Overloading operations
# allows us to pass XXVec objects directly into Cvoid ccall signatures
Base.cconvert(::Type{Cvoid}, obj::AbstractGkoVector) = obj.ptr

# allows us to pass XXVec objects directly into Ptr{Cvoid} ccall signatures
Base.unsafe_convert(::Type{Ptr{Cvoid}}, obj::AbstractGkoVector) =
    convert(Ptr{Cvoid}, pointer_from_objref(obj))

Base.eltype(::AbstractGkoVector{T}) where {T} = T

function Base.size(array::AbstractGkoVector{T}) where {T}
    function_name = Symbol("ginkgo_get_num_elems_", gko_type(T))
    return eval(:($API.$function_name($array.ptr)))
end

function Base.isempty(array::AbstractGkoVector{T}) where {T}
    function_name = Symbol("ginkgo_get_num_elems_", gko_type(T))
    return eval(:($API.$function_name($array.ptr))) == 0
end