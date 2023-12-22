const DATATYPE_MAP = Dict(
    Nothing => API.GKO_NONE,
    Int16 => API.GKO_SHORT,
    Int32 => API.GKO_INT,
    Int64 => API.GKO_LONG_LONG,
    Float32 => API.GKO_FLOAT,
    Float64 => API.GKO_DOUBLE,
    Complex{Float32} => API.GKO_COMPLEX_FLOAT,
    Complex{Float64} => API.GKO_COMPLEX_DOUBLE
)

export determine_datatype
determine_datatype(T::Type) = DATATYPE_MAP[T]


const DATATYPE_CALL_MAP = Dict(
    Int16 => :i16,
    Int32 => :i32,
    Int64 => :i64,
    Float32 => :f32,
    Float64 => :f64,
    Complex{Float32} => :cf32,
    Complex{Float64} => :cf64
)

export gko_type
gko_type(T::Type) = DATATYPE_CALL_MAP[T]

# Type Conversion for C native representable types
Base.cconvert(::Type{API.gko_dim2_st}, obj::Tuple{T, T}) where T =  API.gko_dim2_st(obj[1], obj[2])