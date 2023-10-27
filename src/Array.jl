abstract type AbstractGkoVector{T} <: AbstractVector{T} end
scalartype(::AbstractGkoVector{T}) where {T} = T

# # allows us to pass XXVec objects directly into Cvoid ccall signatures
# Base.cconvert(::Type{Cvoid}, obj::AbstractGkoVector) = obj.ptr
# # allows us to pass XXVec objects directly into Ptr{Cvoid} ccall signatures
# Base.unsafe_convert(::Type{Ptr{Cvoid}}, obj::AbstractGkoVector) =
#     convert(Ptr{Cvoid}, pointer_from_objref(obj))


mutable struct Array{T} <: AbstractGkoVector{T}
    ptr::Ptr{Cvoid}
    executor::Ptr{Cvoid}  # Adding the executor field

    # Inner constructor
    function Array{T}(::UndefInitializer, executor::Ptr{G}, dims::Int...) where {T, G}
        # Call the ginkgo_create_array function to get the ptr
        @GC.preserve executor begin
            ptr = API.ginkgo_create_array(determine_datatype(T), executor, prod(dims))
            # Call the default constructor
            return new{T}(ptr, executor)  # Passing the executor to the constructor
        end
    end
end



# FIXME: check when to use this, should be combined with the finalizer
# API.ginkgo_delete_array(datatype, array)
