module API

using CEnum

# Prologue can be added under /res/prologue.jl
# import ginkgo_jll: libginkgo

# use it for local lib
libginkgo = joinpath(ENV["LIBGINKGO_DIR"], "libginkgod.so")

@cenum _GKO_DATATYPE_CONST::Int32 begin
    GKO_NONE = -1
    GKO_INT = 0
    GKO_INT64 = 1
    GKO_DOUBLE = 2
    GKO_STRING = 3
end

@cenum _GKO_EXECUTORTYPE::UInt32 begin
    OMP = 0
    CUDA = 1
    HIP = 2
    DPCPP = 3
    REFERENCE = 4
end

mutable struct gko_executor_omp_st end

const gko_executor_omp = Ptr{gko_executor_omp_st}

mutable struct gko_executor_reference_st end

const gko_executor_reference = Ptr{gko_executor_reference_st}

"""
    ginkgo_create_array(datatype, raw_exec, size)

Allocates memory for an array of the given size and type on targeted device.

### Parameters
* `datatype`: Type of the array elements
* `raw_exec`: Raw pointer to the executor for targeted device
* `size`: Size of the array
### Returns
void* Pointer to the allocated array
"""
function ginkgo_create_array(datatype, raw_exec, size)
    ccall((:ginkgo_create_array, libginkgo), Ptr{Cvoid}, (_GKO_DATATYPE_CONST, Ptr{Cvoid}, Cint), datatype, raw_exec, size)
end

"""
    ginkgo_delete_array(datatype, array)

Deallocates memory for an array of the given size and type on targeted device.

### Parameters
* `datatype`: Type of the array elements
* `array`: Pointer to the array to be deallocated
"""
function ginkgo_delete_array(datatype, array)
    ccall((:ginkgo_delete_array, libginkgo), Cvoid, (_GKO_DATATYPE_CONST, Ptr{Cvoid}), datatype, array)
end

# no prototype is found for this function at c_api.h:90:18, please use with caution
"""
    ginkgo_create_executor_omp()

Allocates memory for an omp executor on targeted device.

### Returns
[`gko_executor_omp`](@ref) Raw pointer to the shared pointer of the omp executor
"""
function ginkgo_create_executor_omp()
    ccall((:ginkgo_create_executor_omp, libginkgo), gko_executor_omp, ())
end

"""
    ginkgo_delete_executor_omp(ptr)

Deallocates memory for an omp executor on targeted device.

### Parameters
* `ptr`: Raw pointer to the shared pointer of the omp executor to be deleted
"""
function ginkgo_delete_executor_omp(ptr)
    ccall((:ginkgo_delete_executor_omp, libginkgo), Cvoid, (gko_executor_omp,), ptr)
end

# no prototype is found for this function at c_api.h:121:24, please use with caution
"""
    ginkgo_create_executor_reference()

Allocates memory for a reference executor on target device

### Returns
[`gko_executor_reference`](@ref) Raw pointer to the shared pointer of the reference executor
"""
function ginkgo_create_executor_reference()
    ccall((:ginkgo_create_executor_reference, libginkgo), gko_executor_reference, ())
end

"""
    ginkgo_delete_executor_reference(ptr)

Deallocates memory for a reference executor on targeted device.

### Parameters
* `ptr`: Raw pointer to the shared pointer of the reference executor to be deleted
"""
function ginkgo_delete_executor_reference(ptr)
    ccall((:ginkgo_delete_executor_reference, libginkgo), Cvoid, (gko_executor_reference,), ptr)
end

# no prototype is found for this function at c_api.h:147:6, please use with caution
"""
    ginkgo_get_version()

This function is a wrapper for obtaining the version of the ginkgo library
"""
function ginkgo_get_version()
    ccall((:ginkgo_get_version, libginkgo), Cvoid, ())
end

# exports
const PREFIXES = ["CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
