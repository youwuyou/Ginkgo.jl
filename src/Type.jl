const DATATYPE_MAP = Dict(
    Int => API.GKO_INT,
    Int64 => API.GKO_INT64,
    Float64 => API.GKO_DOUBLE,
    String => API.GKO_STRING
)


export determine_datatype
determine_datatype(T::Type) = DATATYPE_MAP[T]