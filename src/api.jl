module API

using CEnum

# Prologue can be added under /res/prologue.jl
# import ginkgo_jll: libginkgo

# use it for local lib
libginkgo = joinpath(ENV["LIBGINKGO_DIR"], "libginkgod.so")

"""
Struct containing the shared pointer to a ginkgo executor
"""
mutable struct gko_executor_st end

"""
Type of the pointer to the wrapped [`gko_executor_st`](@ref) struct
"""
const gko_executor = Ptr{gko_executor_st}

@cenum _GKO_DATATYPE_CONST::Int32 begin
    GKO_NONE = -1
    GKO_SHORT = 0
    GKO_INT = 1
    GKO_LONG_LONG = 2
    GKO_FLOAT = 3
    GKO_DOUBLE = 4
    GKO_COMPLEX_FLOAT = 5
    GKO_COMPLEX_DOUBLE = 6
end

# no prototype is found for this function at c_api.h:135:14, please use with caution
"""
    ginkgo_create_executor_omp()

Allocates memory for an omp executor on targeted device.

### Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the omp executor
"""
function ginkgo_create_executor_omp()
    ccall((:ginkgo_create_executor_omp, libginkgo), gko_executor, ())
end

"""
    ginkgo_delete_executor_omp(ptr)

Deallocates memory for an omp executor on targeted device.

### Parameters
* `ptr`: Raw pointer to the shared pointer of the omp executor to be deleted
"""
function ginkgo_delete_executor_omp(ptr)
    ccall((:ginkgo_delete_executor_omp, libginkgo), Cvoid, (gko_executor,), ptr)
end

# no prototype is found for this function at c_api.h:207:14, please use with caution
"""
    ginkgo_create_executor_reference()

Allocates memory for a reference executor on targeted device.

### Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the reference executor
"""
function ginkgo_create_executor_reference()
    ccall((:ginkgo_create_executor_reference, libginkgo), gko_executor, ())
end

"""
    ginkgo_delete_executor_reference(ptr)

Deallocates memory for a reference executor on targeted device.

### Parameters
* `ptr`: Raw pointer to the shared pointer of the reference executor to be deleted
"""
function ginkgo_delete_executor_reference(ptr)
    ccall((:ginkgo_delete_executor_reference, libginkgo), Cvoid, (gko_executor,), ptr)
end

mutable struct gko_array_i16_st end

const gko_array_i16 = Ptr{gko_array_i16_st}

function ginkgo_create_array_i16(exec_st_ptr, size)
    ccall((:ginkgo_create_array_i16, libginkgo), gko_array_i16, (gko_executor, Cint), exec_st_ptr, size)
end

function ginkgo_create_view_array_i16(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_create_view_array_i16, libginkgo), gko_array_i16, (gko_executor, Cint, Ptr{Cshort}), exec_st_ptr, size, data_ptr)
end

function ginkgo_delete_array_i16(array_st_ptr)
    ccall((:ginkgo_delete_array_i16, libginkgo), Cvoid, (gko_array_i16,), array_st_ptr)
end

function ginkgo_get_num_elems_i16(array_st_ptr)
    ccall((:ginkgo_get_num_elems_i16, libginkgo), Cint, (gko_array_i16,), array_st_ptr)
end

mutable struct gko_array_i32_st end

const gko_array_i32 = Ptr{gko_array_i32_st}

function ginkgo_create_array_i32(exec_st_ptr, size)
    ccall((:ginkgo_create_array_i32, libginkgo), gko_array_i32, (gko_executor, Cint), exec_st_ptr, size)
end

function ginkgo_create_view_array_i32(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_create_view_array_i32, libginkgo), gko_array_i32, (gko_executor, Cint, Ptr{Cint}), exec_st_ptr, size, data_ptr)
end

function ginkgo_delete_array_i32(array_st_ptr)
    ccall((:ginkgo_delete_array_i32, libginkgo), Cvoid, (gko_array_i32,), array_st_ptr)
end

function ginkgo_get_num_elems_i32(array_st_ptr)
    ccall((:ginkgo_get_num_elems_i32, libginkgo), Cint, (gko_array_i32,), array_st_ptr)
end

mutable struct gko_array_i64_st end

const gko_array_i64 = Ptr{gko_array_i64_st}

function ginkgo_create_array_i64(exec_st_ptr, size)
    ccall((:ginkgo_create_array_i64, libginkgo), gko_array_i64, (gko_executor, Cint), exec_st_ptr, size)
end

function ginkgo_create_view_array_i64(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_create_view_array_i64, libginkgo), gko_array_i64, (gko_executor, Cint, Ptr{Clonglong}), exec_st_ptr, size, data_ptr)
end

function ginkgo_delete_array_i64(array_st_ptr)
    ccall((:ginkgo_delete_array_i64, libginkgo), Cvoid, (gko_array_i64,), array_st_ptr)
end

function ginkgo_get_num_elems_i64(array_st_ptr)
    ccall((:ginkgo_get_num_elems_i64, libginkgo), Cint, (gko_array_i64,), array_st_ptr)
end

mutable struct gko_array_f32_st end

const gko_array_f32 = Ptr{gko_array_f32_st}

function ginkgo_create_array_f32(exec_st_ptr, size)
    ccall((:ginkgo_create_array_f32, libginkgo), gko_array_f32, (gko_executor, Cint), exec_st_ptr, size)
end

function ginkgo_create_view_array_f32(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_create_view_array_f32, libginkgo), gko_array_f32, (gko_executor, Cint, Ptr{Cfloat}), exec_st_ptr, size, data_ptr)
end

function ginkgo_delete_array_f32(array_st_ptr)
    ccall((:ginkgo_delete_array_f32, libginkgo), Cvoid, (gko_array_f32,), array_st_ptr)
end

function ginkgo_get_num_elems_f32(array_st_ptr)
    ccall((:ginkgo_get_num_elems_f32, libginkgo), Cint, (gko_array_f32,), array_st_ptr)
end

mutable struct gko_array_f64_st end

const gko_array_f64 = Ptr{gko_array_f64_st}

function ginkgo_create_array_f64(exec_st_ptr, size)
    ccall((:ginkgo_create_array_f64, libginkgo), gko_array_f64, (gko_executor, Cint), exec_st_ptr, size)
end

function ginkgo_create_view_array_f64(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_create_view_array_f64, libginkgo), gko_array_f64, (gko_executor, Cint, Ptr{Cdouble}), exec_st_ptr, size, data_ptr)
end

function ginkgo_delete_array_f64(array_st_ptr)
    ccall((:ginkgo_delete_array_f64, libginkgo), Cvoid, (gko_array_f64,), array_st_ptr)
end

function ginkgo_get_num_elems_f64(array_st_ptr)
    ccall((:ginkgo_get_num_elems_f64, libginkgo), Cint, (gko_array_f64,), array_st_ptr)
end

mutable struct gko_dim2_st end

const gko_dim2 = Ptr{gko_dim2_st}

function ginkgo_delete_dim2(dim_st_ptr)
    ccall((:ginkgo_delete_dim2, libginkgo), Cvoid, (gko_dim2,), dim_st_ptr)
end

function ginkgo_ifequal_dim2(st_ptr1, st_ptr2)
    ccall((:ginkgo_ifequal_dim2, libginkgo), Cint, (gko_dim2, gko_dim2), st_ptr1, st_ptr2)
end

mutable struct gko_dim3_st end

const gko_dim3 = Ptr{gko_dim3_st}

function ginkgo_delete_dim3(dim_st_ptr)
    ccall((:ginkgo_delete_dim3, libginkgo), Cvoid, (gko_dim3,), dim_st_ptr)
end

function ginkgo_ifequal_dim3(st_ptr1, st_ptr2)
    ccall((:ginkgo_ifequal_dim3, libginkgo), Cint, (gko_dim3, gko_dim3), st_ptr1, st_ptr2)
end

function ginkgo_create_dim2(first, second)
    ccall((:ginkgo_create_dim2, libginkgo), gko_dim2, (Cint, Cint), first, second)
end

function ginkgo_create_dim3(first, second, third)
    ccall((:ginkgo_create_dim3, libginkgo), gko_dim3, (Cint, Cint, Cint), first, second, third)
end

# no prototype is found for this function at c_api.h:259:6, please use with caution
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
