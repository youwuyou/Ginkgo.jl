"""
    GkoDim{N}
Abstract type for creating `gko::dim<N>` like objects

Implementation of operations at the Julia side

# External links
$(_doc_external("gko::dim<N>", "structgko_1_1dim"))
"""
abstract type GkoDim{N} end

"""
    GkoDim2 <: GkoDim{2}

A type for representing the dimensions of an object. Alias for `gko_dim2_st` in C API.

### Examples

```julia-repl
# Creating uninitialized dimensional object
julia> GkoDim{2}()
(0, 0)

# Creating initialized dimensional object for identical row and column numbers
julia> GkoDim{2}(3)
(3, 3)

# Creaing initialized dimensional object of specified row and column numbers
julia> GkoDim{2}(6,9)
(6, 9)
```
"""
mutable struct GkoDim2 <: GkoDim{2}
    m::Cint
    n::Cint

    # Construcors
    GkoDim{2}() = new(0, 0)

    function GkoDim{2}(dim::Integer)
        (dim < 0) && throw(ArgumentError("invalid Array dimensions"))
        return new(dim, dim)
    end

    function GkoDim{2}(m::Integer, n::Integer)
        (m < 0 || n < 0) && throw(ArgumentError("invalid Array dimensions"))
        return new(m, n)
    end

    function GkoDim{2}(dim::Tuple{Integer, Integer})
        (dim[1] < 0 || dim[2] < 0) && throw(ArgumentError("invalid Array dimensions"))
        return new(dim[1], dim[2])
    end

    # Conversion
    Base.cconvert(::Type{API.gko_dim2_st}, obj::GkoDim{2}) = API.gko_dim2_st(obj.m, obj.n)
    Base.cconvert(::Type{API.gko_dim2_st}, obj::Tuple{T, T}) where T =  API.gko_dim2_st(obj[1], obj[2])

    # Base.unsafe_convert(::Type{Ptr{API.gko_dim2_st}}, obj::Dim2) =
    #     convert(Ptr{API.gko_dim2_st}, pointer_from_objref(obj))

    # Equality check
    Base.:(==)(x::GkoDim{2}, y::GkoDim{2}) = x.m == y.m && x.n == y.n    
    Base.:(==)(x::GkoDim{2}, y::Tuple{Integer, Integer}) = x.m == y[1] && x.n == y[2]
    Base.:(==)(x::Tuple{Integer, Integer}, y::GkoDim{2}) = x[1] == y.m && x[2] == y.n

    # Multiplication
    Base.:*(x::GkoDim{2}, y::GkoDim{2}) = GkoDim{2}(x.m * y.m, x.n * y.n)

    # Display
    Base.show(io::IO, x::GkoDim{2}) = print(io, (x.m, x.n))

    # Indexing
    function Base.length(x::GkoDim2)
        return 2    
    end

    function Base.getindex(x::GkoDim{2}, number::Integer)
        number in [1, 2] || throw(ArgumentError("x::GkoDim{2} contains only x[1] and x[2]"))
        isequal(1, number) ? x.m : x.n
    end

    function Base.setindex!(x::GkoDim{2}, value, number::Integer)
        number in [1, 2] || throw(ArgumentError("x::GkoDim{2} contains only x[1] and x[2]"))
        isequal(1, number) ? x.m = value : x.n = value 
    end

    function Base.transpose(x::GkoDim{2})
        return GkoDim{2}(x.n, x.m)
    end

end




 