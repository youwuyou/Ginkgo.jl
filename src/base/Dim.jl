"""
    Dim{N}
Abstract type for creating `gko::dim<N>` like objects

Implementation of operations at the Julia side
"""
abstract type Dim{N} end

"""
    Dim2 <: Dim{2}

A type representing the dimensions of an object. Alias for `gko_dim2_st` in C API.

### Examples

```julia-repl
# Creating uninitialized dimensional object
julia> Ginkgo.Dim{2}()
(0, 0)

# Creating initialized dimensional object for identical row and column numbers
julia> Ginkgo.Dim{2}(3)
(3, 3)

# Creaing initialized dimensional object of specified row and column numbers
julia> Ginkgo.Dim{2}(6,9)
(6, 9)
```
"""
mutable struct Dim2 <: Dim{2}
    rows::Cint
    cols::Cint

    # Construcor
    Dim{2}() = new(0, 0)

    function Dim{2}(dim::Integer)
        (dim < 0) && throw(ArgumentError("invalid Array dimensions"))
        return new(dim, dim)
    end

    function Dim{2}(rows::Integer, cols::Integer)
        (rows < 0 || cols < 0) && throw(ArgumentError("invalid Array dimensions"))
        return new(rows, cols)
    end

    # Conversion
    Base.cconvert(::Type{API.gko_dim2_st}, obj::Dim2) = API.gko_dim2_st(obj.rows, obj.cols)
    # Base.unsafe_convert(::Type{Ptr{Ginkgo.API.gko_dim2_st}}, obj::Ginkgo.Dim2) =
    #     convert(Ptr{API.gko_dim2_st}, pointer_from_objref(obj))

    # Equality check
    Base.:(==)(x::Dim{2}, y::Dim{2}) = x.rows == y.rows && x.cols == y.cols

    Base.:(==)(x::Dim{2}, y::Tuple{Integer, Integer}) = x.rows == y[1] && x.cols == y[2]
    Base.:(==)(x::Tuple{Integer, Integer}, y::Dim{2}) = x[1] == y.rows && x[2] == y.cols

    # Multiplication
    Base.:*(x::Dim{2}, y::Dim{2}) = Dim{2}(x.rows * y.rows, x.cols * y.cols)

    # Display
    Base.show(io::IO, x::Dim{2}) = print(io, (x.rows, x.cols))

    # Indexing
    function Base.getindex(x::Dim{2}, number::Integer)
        number in [1, 2] || throw(ArgumentError("x::Dim{2} contains only x[1] and x[2]"))
        isequal(1, number) ? x.rows : x.cols
    end

    function Base.setindex!(x::Dim{2}, value, number::Integer)
        number in [1, 2] || throw(ArgumentError("x::Dim{2} contains only x[1] and x[2]"))
        isequal(1, number) ? x.rows = value : x.cols = value 
    end

    function Base.transpose(x::Dim{2})
        return Dim{2}(x.cols, x.rows)
    end

end

# libginkgod.so
# Create alias for the gko_dim2_st type
# const API.gko_dim2_st = Dim2

# const Dim2 = API.gko_dim2_st 
# ginkgo_get_dim2_rows(dim)
# ginkgo_get_dim2_cols(dim)




 