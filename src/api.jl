module API

using CEnum

# Prologue can be added under /res/prologue.jl
import ginkgo_jll: libginkgo

"""
Struct containing the shared pointer to a ginkgo executor
"""
mutable struct gko_executor_st end

"""
Type of the pointer to the wrapped [`gko_executor_st`](@ref) struct
"""
const gko_executor = Ptr{gko_executor_st}

"""
    gko_dim2_st

Struct implements the gko::dim<2> type
"""
struct gko_dim2_st
    rows::Csize_t
    cols::Csize_t
end

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

function c_char_ptr_free(ptr)
    ccall((:c_char_ptr_free, libginkgo), Cvoid, (Ptr{Cchar},), ptr)
end

# no prototype is found for this function at c_api.h:444:6, please use with caution
"""
    ginkgo_version_get()

This function is a wrapper for obtaining the version of the ginkgo library
"""
function ginkgo_version_get()
    ccall((:ginkgo_version_get, libginkgo), Cvoid, ())
end

"""
    ginkgo_dim2_create(rows, cols)

Allocates memory for a C-based reimplementation of the gko::dim<2> type

# Arguments
* `rows`: First dimension
* `cols`: Second dimension
# Returns
[`gko_dim2_st`](@ref) C struct that contains members of the gko::dim<2> type
"""
function ginkgo_dim2_create(rows, cols)
    ccall((:ginkgo_dim2_create, libginkgo), gko_dim2_st, (Csize_t, Csize_t), rows, cols)
end

"""
    ginkgo_dim2_rows_get(dim)

Obtains the value of the first element of a gko::dim<2> type

# Arguments
* `dim`: An object of [`gko_dim2_st`](@ref) type
# Returns
size\\_t First dimension
"""
function ginkgo_dim2_rows_get(dim)
    ccall((:ginkgo_dim2_rows_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    ginkgo_dim2_cols_get(dim)

Obtains the value of the second element of a gko::dim<2> type

# Arguments
* `dim`: An object of [`gko_dim2_st`](@ref) type
# Returns
size\\_t Second dimension
"""
function ginkgo_dim2_cols_get(dim)
    ccall((:ginkgo_dim2_cols_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    ginkgo_executor_delete(exec_st_ptr)

Deallocates memory for an executor on targeted device.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor to be deleted
"""
function ginkgo_executor_delete(exec_st_ptr)
    ccall((:ginkgo_executor_delete, libginkgo), Cvoid, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_get_master(exec_st_ptr)

Returns the master OmpExecutor of this Executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the master executor
"""
function ginkgo_executor_get_master(exec_st_ptr)
    ccall((:ginkgo_executor_get_master, libginkgo), gko_executor, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_memory_accessible(exec_st_ptr, other_exec_st_ptr)

Verifies whether the executors share the same memory.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
* `other_exec_st_ptr`: Raw pointer to the shared pointer of the other executor
"""
function ginkgo_executor_memory_accessible(exec_st_ptr, other_exec_st_ptr)
    ccall((:ginkgo_executor_memory_accessible, libginkgo), Bool, (gko_executor, gko_executor), exec_st_ptr, other_exec_st_ptr)
end

"""
    ginkgo_executor_synchronize(exec_st_ptr)

Synchronize the operations launched on the executor with its master.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
"""
function ginkgo_executor_synchronize(exec_st_ptr)
    ccall((:ginkgo_executor_synchronize, libginkgo), Cvoid, (gko_executor,), exec_st_ptr)
end

# no prototype is found for this function at c_api.h:539:14, please use with caution
"""
    ginkgo_executor_omp_create()

Create an OMP executor

# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the OMP executor created
"""
function ginkgo_executor_omp_create()
    ccall((:ginkgo_executor_omp_create, libginkgo), gko_executor, ())
end

# no prototype is found for this function at c_api.h:547:14, please use with caution
"""
    ginkgo_executor_reference_create()

Create a reference executor

# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the reference executor created
"""
function ginkgo_executor_reference_create()
    ccall((:ginkgo_executor_reference_create, libginkgo), gko_executor, ())
end

"""
    ginkgo_executor_cpu_get_num_cores(exec_st_ptr)

Get the number of cores of the CPU associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t No. of cores
"""
function ginkgo_executor_cpu_get_num_cores(exec_st_ptr)
    ccall((:ginkgo_executor_cpu_get_num_cores, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_cpu_get_num_threads_per_core(exec_st_ptr)

Get the number of threads per core of the CPU associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t No. of threads per core
"""
function ginkgo_executor_cpu_get_num_threads_per_core(exec_st_ptr)
    ccall((:ginkgo_executor_cpu_get_num_threads_per_core, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_get_device_id(exec_st_ptr)

Get the device id of the device associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t Device id
"""
function ginkgo_executor_gpu_get_device_id(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_get_device_id, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_cuda_create(device_id, exec_st_ptr)

Create a CUDA executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the CUDA executor created
"""
function ginkgo_executor_cuda_create(device_id, exec_st_ptr)
    ccall((:ginkgo_executor_cuda_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:592:8, please use with caution
"""
    ginkgo_executor_cuda_get_num_devices()

Get the number of devices of this CUDA executor.

# Returns
size\\_t No. of devices
"""
function ginkgo_executor_cuda_get_num_devices()
    ccall((:ginkgo_executor_cuda_get_num_devices, libginkgo), Csize_t, ())
end

"""
    ginkgo_executor_hip_create(device_id, exec_st_ptr)

Create a HIP executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the HIP executor created
"""
function ginkgo_executor_hip_create(device_id, exec_st_ptr)
    ccall((:ginkgo_executor_hip_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:610:8, please use with caution
"""
    ginkgo_executor_hip_get_num_devices()

Get the number of devices of this HIP executor.

# Returns
size\\_t No. of devices
"""
function ginkgo_executor_hip_get_num_devices()
    ccall((:ginkgo_executor_hip_get_num_devices, libginkgo), Csize_t, ())
end

"""
    ginkgo_executor_gpu_thread_get_num_multiprocessor(exec_st_ptr)

Get the number of multiprocessors of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. multiprocessors
"""
function ginkgo_executor_gpu_thread_get_num_multiprocessor(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_num_multiprocessor, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_num_warps_per_sm(exec_st_ptr)

Get the number of warps per SM of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of warps per SM
"""
function ginkgo_executor_gpu_thread_get_num_warps_per_sm(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_num_warps_per_sm, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_num_warps(exec_st_ptr)

Get the number of warps of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of warps
"""
function ginkgo_executor_gpu_thread_get_num_warps(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_num_warps, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_warp_size(exec_st_ptr)

Get the warp size of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The warp size of this executor
"""
function ginkgo_executor_gpu_thread_get_warp_size(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_warp_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_major_version(exec_st_ptr)

Get the major version of compute capability.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The major version of compute capability
"""
function ginkgo_executor_gpu_thread_get_major_version(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_major_version, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_minor_version(exec_st_ptr)

Get the minor version of compute capability.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The minor version of compute capability
"""
function ginkgo_executor_gpu_thread_get_minor_version(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_minor_version, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_thread_get_closest_numa(exec_st_ptr)

Get the closest NUMA node.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of the closest NUMA node
"""
function ginkgo_executor_gpu_thread_get_closest_numa(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_thread_get_closest_numa, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_dpcpp_create(device_id, exec_st_ptr)

Create a DPCPP executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the DPCPP executor created
"""
function ginkgo_executor_dpcpp_create(device_id, exec_st_ptr)
    ccall((:ginkgo_executor_dpcpp_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:695:8, please use with caution
"""
    ginkgo_executor_dpcpp_get_num_devices()

Get the number of devices of this DPCPP executor.

# Returns
size\\_t No. of devices
"""
function ginkgo_executor_dpcpp_get_num_devices()
    ccall((:ginkgo_executor_dpcpp_get_num_devices, libginkgo), Csize_t, ())
end

"""
    ginkgo_executor_gpu_item_get_max_subgroup_size(exec_st_ptr)

Get the number of subgroups of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of subgroups
"""
function ginkgo_executor_gpu_item_get_max_subgroup_size(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_item_get_max_subgroup_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_item_get_max_workgroup_size(exec_st_ptr)

Get the number of workgroups of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of workgroups
"""
function ginkgo_executor_gpu_item_get_max_workgroup_size(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_item_get_max_workgroup_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    ginkgo_executor_gpu_item_get_num_computing_units(exec_st_ptr)

Get the number of computing units of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of computing units
"""
function ginkgo_executor_gpu_item_get_num_computing_units(exec_st_ptr)
    ccall((:ginkgo_executor_gpu_item_get_num_computing_units, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

mutable struct gko_array_i16_st end

const gko_array_i16 = Ptr{gko_array_i16_st}

function ginkgo_array_i16_create(exec_st_ptr, size)
    ccall((:ginkgo_array_i16_create, libginkgo), gko_array_i16, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_i16_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_i16_create_view, libginkgo), gko_array_i16, (gko_executor, Csize_t, Ptr{Int16}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_i16_delete(array_st_ptr)
    ccall((:ginkgo_array_i16_delete, libginkgo), Cvoid, (gko_array_i16,), array_st_ptr)
end

function ginkgo_array_i16_get_size(array_st_ptr)
    ccall((:ginkgo_array_i16_get_size, libginkgo), Csize_t, (gko_array_i16,), array_st_ptr)
end

mutable struct gko_array_i32_st end

const gko_array_i32 = Ptr{gko_array_i32_st}

function ginkgo_array_i32_create(exec_st_ptr, size)
    ccall((:ginkgo_array_i32_create, libginkgo), gko_array_i32, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_i32_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_i32_create_view, libginkgo), gko_array_i32, (gko_executor, Csize_t, Ptr{Cint}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_i32_delete(array_st_ptr)
    ccall((:ginkgo_array_i32_delete, libginkgo), Cvoid, (gko_array_i32,), array_st_ptr)
end

function ginkgo_array_i32_get_size(array_st_ptr)
    ccall((:ginkgo_array_i32_get_size, libginkgo), Csize_t, (gko_array_i32,), array_st_ptr)
end

mutable struct gko_array_i64_st end

const gko_array_i64 = Ptr{gko_array_i64_st}

function ginkgo_array_i64_create(exec_st_ptr, size)
    ccall((:ginkgo_array_i64_create, libginkgo), gko_array_i64, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_i64_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_i64_create_view, libginkgo), gko_array_i64, (gko_executor, Csize_t, Ptr{Int64}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_i64_delete(array_st_ptr)
    ccall((:ginkgo_array_i64_delete, libginkgo), Cvoid, (gko_array_i64,), array_st_ptr)
end

function ginkgo_array_i64_get_size(array_st_ptr)
    ccall((:ginkgo_array_i64_get_size, libginkgo), Csize_t, (gko_array_i64,), array_st_ptr)
end

mutable struct gko_array_f32_st end

const gko_array_f32 = Ptr{gko_array_f32_st}

function ginkgo_array_f32_create(exec_st_ptr, size)
    ccall((:ginkgo_array_f32_create, libginkgo), gko_array_f32, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_f32_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_f32_create_view, libginkgo), gko_array_f32, (gko_executor, Csize_t, Ptr{Cfloat}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_f32_delete(array_st_ptr)
    ccall((:ginkgo_array_f32_delete, libginkgo), Cvoid, (gko_array_f32,), array_st_ptr)
end

function ginkgo_array_f32_get_size(array_st_ptr)
    ccall((:ginkgo_array_f32_get_size, libginkgo), Csize_t, (gko_array_f32,), array_st_ptr)
end

mutable struct gko_array_f64_st end

const gko_array_f64 = Ptr{gko_array_f64_st}

function ginkgo_array_f64_create(exec_st_ptr, size)
    ccall((:ginkgo_array_f64_create, libginkgo), gko_array_f64, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_f64_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_f64_create_view, libginkgo), gko_array_f64, (gko_executor, Csize_t, Ptr{Cdouble}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_f64_delete(array_st_ptr)
    ccall((:ginkgo_array_f64_delete, libginkgo), Cvoid, (gko_array_f64,), array_st_ptr)
end

function ginkgo_array_f64_get_size(array_st_ptr)
    ccall((:ginkgo_array_f64_get_size, libginkgo), Csize_t, (gko_array_f64,), array_st_ptr)
end

mutable struct gko_matrix_dense_f32_st end

const gko_matrix_dense_f32 = Ptr{gko_matrix_dense_f32_st}

function ginkgo_matrix_dense_f32_create(exec, size)
    ccall((:ginkgo_matrix_dense_f32_create, libginkgo), gko_matrix_dense_f32, (gko_executor, gko_dim2_st), exec, size)
end

function ginkgo_matrix_dense_f32_create_view(exec, size, values, stride)
    ccall((:ginkgo_matrix_dense_f32_create_view, libginkgo), gko_matrix_dense_f32, (gko_executor, gko_dim2_st, Ptr{Cfloat}, Csize_t), exec, size, values, stride)
end

function ginkgo_matrix_dense_f32_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_delete, libginkgo), Cvoid, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_fill(mat_st_ptr, value)
    ccall((:ginkgo_matrix_dense_f32_fill, libginkgo), Cvoid, (gko_matrix_dense_f32, Cfloat), mat_st_ptr, value)
end

function ginkgo_matrix_dense_f32_at(mat_st_ptr, row, col)
    ccall((:ginkgo_matrix_dense_f32_at, libginkgo), Cfloat, (gko_matrix_dense_f32, Csize_t, Csize_t), mat_st_ptr, row, col)
end

function ginkgo_matrix_dense_f32_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_get_size, libginkgo), gko_dim2_st, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_get_values(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_get_values, libginkgo), Ptr{Cfloat}, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_get_stride(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_get_stride, libginkgo), Csize_t, (gko_matrix_dense_f32,), mat_st_ptr)
end

function ginkgo_matrix_dense_f32_compute_dot(mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
    ccall((:ginkgo_matrix_dense_f32_compute_dot, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
end

function ginkgo_matrix_dense_f32_compute_norm1(mat_st_ptr1, mat_st_ptr2)
    ccall((:ginkgo_matrix_dense_f32_compute_norm1, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2)
end

function ginkgo_matrix_dense_f32_compute_norm2(mat_st_ptr1, mat_st_ptr2)
    ccall((:ginkgo_matrix_dense_f32_compute_norm2, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2)
end

function ginkgo_matrix_dense_f32_read(str_ptr, exec)
    ccall((:ginkgo_matrix_dense_f32_read, libginkgo), gko_matrix_dense_f32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_matrix_dense_f32_write_mtx(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f32_write_mtx, libginkgo), Ptr{Cchar}, (gko_matrix_dense_f32,), mat_st_ptr)
end

mutable struct gko_matrix_dense_f64_st end

const gko_matrix_dense_f64 = Ptr{gko_matrix_dense_f64_st}

function ginkgo_matrix_dense_f64_create(exec, size)
    ccall((:ginkgo_matrix_dense_f64_create, libginkgo), gko_matrix_dense_f64, (gko_executor, gko_dim2_st), exec, size)
end

function ginkgo_matrix_dense_f64_create_view(exec, size, values, stride)
    ccall((:ginkgo_matrix_dense_f64_create_view, libginkgo), gko_matrix_dense_f64, (gko_executor, gko_dim2_st, Ptr{Cdouble}, Csize_t), exec, size, values, stride)
end

function ginkgo_matrix_dense_f64_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_delete, libginkgo), Cvoid, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_fill(mat_st_ptr, value)
    ccall((:ginkgo_matrix_dense_f64_fill, libginkgo), Cvoid, (gko_matrix_dense_f64, Cdouble), mat_st_ptr, value)
end

function ginkgo_matrix_dense_f64_at(mat_st_ptr, row, col)
    ccall((:ginkgo_matrix_dense_f64_at, libginkgo), Cdouble, (gko_matrix_dense_f64, Csize_t, Csize_t), mat_st_ptr, row, col)
end

function ginkgo_matrix_dense_f64_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_get_size, libginkgo), gko_dim2_st, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_get_values(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_get_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_get_stride(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_get_stride, libginkgo), Csize_t, (gko_matrix_dense_f64,), mat_st_ptr)
end

function ginkgo_matrix_dense_f64_compute_dot(mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
    ccall((:ginkgo_matrix_dense_f64_compute_dot, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
end

function ginkgo_matrix_dense_f64_compute_norm1(mat_st_ptr1, mat_st_ptr2)
    ccall((:ginkgo_matrix_dense_f64_compute_norm1, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2)
end

function ginkgo_matrix_dense_f64_compute_norm2(mat_st_ptr1, mat_st_ptr2)
    ccall((:ginkgo_matrix_dense_f64_compute_norm2, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2)
end

function ginkgo_matrix_dense_f64_read(str_ptr, exec)
    ccall((:ginkgo_matrix_dense_f64_read, libginkgo), gko_matrix_dense_f64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_matrix_dense_f64_write_mtx(mat_st_ptr)
    ccall((:ginkgo_matrix_dense_f64_write_mtx, libginkgo), Ptr{Cchar}, (gko_matrix_dense_f64,), mat_st_ptr)
end

mutable struct gko_matrix_csr_f32_i32_st end

const gko_matrix_csr_f32_i32 = Ptr{gko_matrix_csr_f32_i32_st}

function ginkgo_matrix_csr_f32_i32_create(exec, size, nnz)
    ccall((:ginkgo_matrix_csr_f32_i32_create, libginkgo), gko_matrix_csr_f32_i32, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function ginkgo_matrix_csr_f32_i32_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:ginkgo_matrix_csr_f32_i32_create_view, libginkgo), gko_matrix_csr_f32_i32, (gko_executor, gko_dim2_st, Csize_t, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function ginkgo_matrix_csr_f32_i32_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_delete, libginkgo), Cvoid, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_read(str_ptr, exec)
    ccall((:ginkgo_matrix_csr_f32_i32_read, libginkgo), gko_matrix_csr_f32_i32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_write_csr_f32_i32_in_coo(str_ptr, mat_st_ptr)
    ccall((:ginkgo_write_csr_f32_i32_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f32_i32), str_ptr, mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_num_srow_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_const_col_idxs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_const_col_idxs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_const_row_ptrs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_const_row_ptrs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_get_const_srow(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_get_const_srow, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:ginkgo_matrix_csr_f32_i32_apply, libginkgo), Cvoid, (gko_matrix_csr_f32_i32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f32_i64_st end

const gko_matrix_csr_f32_i64 = Ptr{gko_matrix_csr_f32_i64_st}

function ginkgo_matrix_csr_f32_i64_create(exec, size, nnz)
    ccall((:ginkgo_matrix_csr_f32_i64_create, libginkgo), gko_matrix_csr_f32_i64, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function ginkgo_matrix_csr_f32_i64_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:ginkgo_matrix_csr_f32_i64_create_view, libginkgo), gko_matrix_csr_f32_i64, (gko_executor, gko_dim2_st, Csize_t, Ptr{Int64}, Ptr{Int64}, Ptr{Cfloat}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function ginkgo_matrix_csr_f32_i64_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_delete, libginkgo), Cvoid, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_read(str_ptr, exec)
    ccall((:ginkgo_matrix_csr_f32_i64_read, libginkgo), gko_matrix_csr_f32_i64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_write_csr_f32_i64_in_coo(str_ptr, mat_st_ptr)
    ccall((:ginkgo_write_csr_f32_i64_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f32_i64), str_ptr, mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_num_srow_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_const_col_idxs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_const_col_idxs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_const_row_ptrs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_const_row_ptrs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_get_const_srow(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i64_get_const_srow, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i64_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:ginkgo_matrix_csr_f32_i64_apply, libginkgo), Cvoid, (gko_matrix_csr_f32_i64, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f64_i32_st end

const gko_matrix_csr_f64_i32 = Ptr{gko_matrix_csr_f64_i32_st}

function ginkgo_matrix_csr_f64_i32_create(exec, size, nnz)
    ccall((:ginkgo_matrix_csr_f64_i32_create, libginkgo), gko_matrix_csr_f64_i32, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function ginkgo_matrix_csr_f64_i32_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:ginkgo_matrix_csr_f64_i32_create_view, libginkgo), gko_matrix_csr_f64_i32, (gko_executor, gko_dim2_st, Csize_t, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function ginkgo_matrix_csr_f64_i32_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_delete, libginkgo), Cvoid, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_read(str_ptr, exec)
    ccall((:ginkgo_matrix_csr_f64_i32_read, libginkgo), gko_matrix_csr_f64_i32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_write_csr_f64_i32_in_coo(str_ptr, mat_st_ptr)
    ccall((:ginkgo_write_csr_f64_i32_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f64_i32), str_ptr, mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_num_srow_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_const_col_idxs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_const_col_idxs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_const_row_ptrs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_const_row_ptrs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_get_const_srow(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i32_get_const_srow, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i32_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:ginkgo_matrix_csr_f64_i32_apply, libginkgo), Cvoid, (gko_matrix_csr_f64_i32, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f64_i64_st end

const gko_matrix_csr_f64_i64 = Ptr{gko_matrix_csr_f64_i64_st}

function ginkgo_matrix_csr_f64_i64_create(exec, size, nnz)
    ccall((:ginkgo_matrix_csr_f64_i64_create, libginkgo), gko_matrix_csr_f64_i64, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function ginkgo_matrix_csr_f64_i64_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:ginkgo_matrix_csr_f64_i64_create_view, libginkgo), gko_matrix_csr_f64_i64, (gko_executor, gko_dim2_st, Csize_t, Ptr{Int64}, Ptr{Int64}, Ptr{Cdouble}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function ginkgo_matrix_csr_f64_i64_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_delete, libginkgo), Cvoid, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_read(str_ptr, exec)
    ccall((:ginkgo_matrix_csr_f64_i64_read, libginkgo), gko_matrix_csr_f64_i64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function ginkgo_write_csr_f64_i64_in_coo(str_ptr, mat_st_ptr)
    ccall((:ginkgo_write_csr_f64_i64_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f64_i64), str_ptr, mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_num_stored_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_num_srow_elements(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_size(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_const_values(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_const_col_idxs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_const_col_idxs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_const_row_ptrs(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_const_row_ptrs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_get_const_srow(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f64_i64_get_const_srow, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function ginkgo_matrix_csr_f64_i64_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:ginkgo_matrix_csr_f64_i64_apply, libginkgo), Cvoid, (gko_matrix_csr_f64_i64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr, alpha, x, beta, y)
end

"""
Struct containing the shared pointer to a ginkgo deferred factory parameter
"""
mutable struct gko_deferred_factory_parameter_st end

"""
Type of the pointer to the wrapped [`gko_deferred_factory_parameter_st`](@ref) struct
"""
const gko_deferred_factory_parameter = Ptr{gko_deferred_factory_parameter_st}

"""
    ginkgo_deferred_factory_parameter_delete(dfp_st_ptr)

Deallocates memory for a ginkgo deferred factory parameter object.

# Arguments
* `dfp_st_ptr`: Raw pointer to the shared pointer of the deferred factory parameter object to be deleted
"""
function ginkgo_deferred_factory_parameter_delete(dfp_st_ptr)
    ccall((:ginkgo_deferred_factory_parameter_delete, libginkgo), Cvoid, (gko_deferred_factory_parameter,), dfp_st_ptr)
end

# no prototype is found for this function at c_api.h:780:32, please use with caution
"""
    ginkgo_preconditioner_none_create()

Create a deferred factory parameter for an empty preconditioner

# Returns
[`gko_deferred_factory_parameter`](@ref) Raw pointer to the shared pointer of the none preconditioner created
"""
function ginkgo_preconditioner_none_create()
    ccall((:ginkgo_preconditioner_none_create, libginkgo), gko_deferred_factory_parameter, ())
end

function ginkgo_preconditioner_jacobi_f64_i32_create(blocksize)
    ccall((:ginkgo_preconditioner_jacobi_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (Cint,), blocksize)
end

function ginkgo_preconditioner_ilu_f64_i32_create(dfp_st_ptr)
    ccall((:ginkgo_preconditioner_ilu_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (gko_deferred_factory_parameter,), dfp_st_ptr)
end

function ginkgo_factorization_parilu_f64_i32_create(iteration, skip_sorting)
    ccall((:ginkgo_factorization_parilu_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (Cint, Bool), iteration, skip_sorting)
end

mutable struct gko_linop_st end

const gko_linop = Ptr{gko_linop_st}

function ginkgo_linop_delete(linop_st_ptr)
    ccall((:ginkgo_linop_delete, libginkgo), Cvoid, (gko_linop,), linop_st_ptr)
end

function ginkgo_linop_apply(A_st_ptr, b_st_ptr, x_st_ptr)
    ccall((:ginkgo_linop_apply, libginkgo), Cvoid, (gko_linop, gko_linop, gko_linop), A_st_ptr, b_st_ptr, x_st_ptr)
end

function ginkgo_linop_cg_preconditioned_f64_create(exec_st_ptr, A_st_ptr, dfp_st_ptr, reduction, maxiter)
    ccall((:ginkgo_linop_cg_preconditioned_f64_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, dfp_st_ptr, reduction, maxiter)
end

function ginkgo_linop_gmres_preconditioned_f64_create(exec_st_ptr, A_st_ptr, dfp_st_ptr, reduction, maxiter)
    ccall((:ginkgo_linop_gmres_preconditioned_f64_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, dfp_st_ptr, reduction, maxiter)
end

function ginkgo_linop_spd_direct_f64_i64_create(exec_st_ptr, A_st_ptr)
    ccall((:ginkgo_linop_spd_direct_f64_i64_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function ginkgo_linop_lu_direct_f64_i64_create(exec_st_ptr, A_st_ptr)
    ccall((:ginkgo_linop_lu_direct_f64_i64_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function ginkgo_linop_lu_direct_f64_i32_create(exec_st_ptr, A_st_ptr)
    ccall((:ginkgo_linop_lu_direct_f64_i32_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function ginkgo_linop_lu_direct_f32_i32_create(exec_st_ptr, A_st_ptr)
    ccall((:ginkgo_linop_lu_direct_f32_i32_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

# exports
const PREFIXES = ["CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
