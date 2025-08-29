module API

using CEnum: CEnum, @cenum

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

function gko_c_char_ptr_free(ptr)
    ccall((:gko_c_char_ptr_free, libginkgo), Cvoid, (Ptr{Cchar},), ptr)
end

# no prototype is found for this function at c_api.h:127:6, please use with caution
"""
    gko_version_print()

This function is a wrapper for printing the version of the ginkgo library
"""
function gko_version_print()
    ccall((:gko_version_print, libginkgo), Cvoid, ())
end

"""
    gko_dim2_create(rows, cols)

Allocates memory for a C-based reimplementation of the gko::dim<2> type

# Arguments
* `rows`: First dimension
* `cols`: Second dimension
# Returns
[`gko_dim2_st`](@ref) C struct that contains members of the gko::dim<2> type
"""
function gko_dim2_create(rows, cols)
    ccall((:gko_dim2_create, libginkgo), gko_dim2_st, (Csize_t, Csize_t), rows, cols)
end

"""
    gko_dim2_rows_get(dim)

Obtains the value of the first element of a gko::dim<2> type

# Arguments
* `dim`: An object of [`gko_dim2_st`](@ref) type
# Returns
size\\_t First dimension
"""
function gko_dim2_rows_get(dim)
    ccall((:gko_dim2_rows_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    gko_dim2_cols_get(dim)

Obtains the value of the second element of a gko::dim<2> type

# Arguments
* `dim`: An object of [`gko_dim2_st`](@ref) type
# Returns
size\\_t Second dimension
"""
function gko_dim2_cols_get(dim)
    ccall((:gko_dim2_cols_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    gko_executor_delete(exec_st_ptr)

Deallocates memory for an executor on targeted device.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor to be deleted
"""
function gko_executor_delete(exec_st_ptr)
    ccall((:gko_executor_delete, libginkgo), Cvoid, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_get_master(exec_st_ptr)

Returns the master OmpExecutor of this Executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the master executor
"""
function gko_executor_get_master(exec_st_ptr)
    ccall((:gko_executor_get_master, libginkgo), gko_executor, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_memory_accessible(exec_st_ptr, other_exec_st_ptr)

Verifies whether the executors share the same memory.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
* `other_exec_st_ptr`: Raw pointer to the shared pointer of the other executor
"""
function gko_executor_memory_accessible(exec_st_ptr, other_exec_st_ptr)
    ccall((:gko_executor_memory_accessible, libginkgo), Bool, (gko_executor, gko_executor), exec_st_ptr, other_exec_st_ptr)
end

"""
    gko_executor_synchronize(exec_st_ptr)

Synchronize the operations launched on the executor with its master.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the current executor
"""
function gko_executor_synchronize(exec_st_ptr)
    ccall((:gko_executor_synchronize, libginkgo), Cvoid, (gko_executor,), exec_st_ptr)
end

# no prototype is found for this function at c_api.h:223:14, please use with caution
"""
    gko_executor_omp_create()

Create an OMP executor

# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the OMP executor created
"""
function gko_executor_omp_create()
    ccall((:gko_executor_omp_create, libginkgo), gko_executor, ())
end

# no prototype is found for this function at c_api.h:231:14, please use with caution
"""
    gko_executor_reference_create()

Create a reference executor

# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the reference executor created
"""
function gko_executor_reference_create()
    ccall((:gko_executor_reference_create, libginkgo), gko_executor, ())
end

"""
    gko_executor_cpu_get_num_cores(exec_st_ptr)

Get the number of cores of the CPU associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t No. of cores
"""
function gko_executor_cpu_get_num_cores(exec_st_ptr)
    ccall((:gko_executor_cpu_get_num_cores, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_cpu_get_num_threads_per_core(exec_st_ptr)

Get the number of threads per core of the CPU associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t No. of threads per core
"""
function gko_executor_cpu_get_num_threads_per_core(exec_st_ptr)
    ccall((:gko_executor_cpu_get_num_threads_per_core, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_get_device_id(exec_st_ptr)

Get the device id of the device associated to this executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor
# Returns
size\\_t Device id
"""
function gko_executor_gpu_get_device_id(exec_st_ptr)
    ccall((:gko_executor_gpu_get_device_id, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_cuda_create(device_id, exec_st_ptr)

Create a CUDA executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the CUDA executor created
"""
function gko_executor_cuda_create(device_id, exec_st_ptr)
    ccall((:gko_executor_cuda_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:280:8, please use with caution
"""
    gko_executor_cuda_get_num_devices()

Get the number of devices of this CUDA executor.

# Returns
size\\_t No. of devices
"""
function gko_executor_cuda_get_num_devices()
    ccall((:gko_executor_cuda_get_num_devices, libginkgo), Csize_t, ())
end

"""
    gko_executor_hip_create(device_id, exec_st_ptr)

Create a HIP executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the HIP executor created
"""
function gko_executor_hip_create(device_id, exec_st_ptr)
    ccall((:gko_executor_hip_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:299:8, please use with caution
"""
    gko_executor_hip_get_num_devices()

Get the number of devices of this HIP executor.

# Returns
size\\_t No. of devices
"""
function gko_executor_hip_get_num_devices()
    ccall((:gko_executor_hip_get_num_devices, libginkgo), Csize_t, ())
end

"""
    gko_executor_gpu_thread_get_num_multiprocessor(exec_st_ptr)

Get the number of multiprocessors of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. multiprocessors
"""
function gko_executor_gpu_thread_get_num_multiprocessor(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_num_multiprocessor, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_num_warps_per_sm(exec_st_ptr)

Get the number of warps per SM of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of warps per SM
"""
function gko_executor_gpu_thread_get_num_warps_per_sm(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_num_warps_per_sm, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_num_warps(exec_st_ptr)

Get the number of warps of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of warps
"""
function gko_executor_gpu_thread_get_num_warps(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_num_warps, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_warp_size(exec_st_ptr)

Get the warp size of this thread-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The warp size of this executor
"""
function gko_executor_gpu_thread_get_warp_size(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_warp_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_major_version(exec_st_ptr)

Get the major version of compute capability.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The major version of compute capability
"""
function gko_executor_gpu_thread_get_major_version(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_major_version, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_minor_version(exec_st_ptr)

Get the minor version of compute capability.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t The minor version of compute capability
"""
function gko_executor_gpu_thread_get_minor_version(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_minor_version, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_thread_get_closest_numa(exec_st_ptr)

Get the closest NUMA node.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the thread-based executor
# Returns
size\\_t No. of the closest NUMA node
"""
function gko_executor_gpu_thread_get_closest_numa(exec_st_ptr)
    ccall((:gko_executor_gpu_thread_get_closest_numa, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_dpcpp_create(device_id, exec_st_ptr)

Create a DPCPP executor

# Arguments
* `device_id`: Device id
* `exec_st_ptr`: Raw pointer to the shared pointer of the master executor
# Returns
[`gko_executor`](@ref) Raw pointer to the shared pointer of the DPCPP executor created
"""
function gko_executor_dpcpp_create(device_id, exec_st_ptr)
    ccall((:gko_executor_dpcpp_create, libginkgo), gko_executor, (Csize_t, gko_executor), device_id, exec_st_ptr)
end

# no prototype is found for this function at c_api.h:392:8, please use with caution
"""
    gko_executor_dpcpp_get_num_devices()

Get the number of devices of this DPCPP executor.

# Returns
size\\_t No. of devices
"""
function gko_executor_dpcpp_get_num_devices()
    ccall((:gko_executor_dpcpp_get_num_devices, libginkgo), Csize_t, ())
end

"""
    gko_executor_gpu_item_get_max_subgroup_size(exec_st_ptr)

Get the number of subgroups of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of subgroups
"""
function gko_executor_gpu_item_get_max_subgroup_size(exec_st_ptr)
    ccall((:gko_executor_gpu_item_get_max_subgroup_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_item_get_max_workgroup_size(exec_st_ptr)

Get the number of workgroups of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of workgroups
"""
function gko_executor_gpu_item_get_max_workgroup_size(exec_st_ptr)
    ccall((:gko_executor_gpu_item_get_max_workgroup_size, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

"""
    gko_executor_gpu_item_get_num_computing_units(exec_st_ptr)

Get the number of computing units of this item-based executor.

# Arguments
* `exec_st_ptr`: Raw pointer to the shared pointer of the item-based executor
# Returns
size\\_t No. of computing units
"""
function gko_executor_gpu_item_get_num_computing_units(exec_st_ptr)
    ccall((:gko_executor_gpu_item_get_num_computing_units, libginkgo), Csize_t, (gko_executor,), exec_st_ptr)
end

mutable struct gko_array_i16_st end

const gko_array_i16 = Ptr{gko_array_i16_st}

function gko_array_i16_create(exec_st_ptr, size)
    ccall((:gko_array_i16_create, libginkgo), gko_array_i16, (gko_executor, Csize_t), exec_st_ptr, size)
end

function gko_array_i16_create_view(exec_st_ptr, size, data_ptr)
    ccall((:gko_array_i16_create_view, libginkgo), gko_array_i16, (gko_executor, Csize_t, Ptr{Int16}), exec_st_ptr, size, data_ptr)
end

function gko_array_i16_delete(array_st_ptr)
    ccall((:gko_array_i16_delete, libginkgo), Cvoid, (gko_array_i16,), array_st_ptr)
end

function gko_array_i16_get_size(array_st_ptr)
    ccall((:gko_array_i16_get_size, libginkgo), Csize_t, (gko_array_i16,), array_st_ptr)
end

mutable struct gko_array_i32_st end

const gko_array_i32 = Ptr{gko_array_i32_st}

function gko_array_i32_create(exec_st_ptr, size)
    ccall((:gko_array_i32_create, libginkgo), gko_array_i32, (gko_executor, Csize_t), exec_st_ptr, size)
end

function gko_array_i32_create_view(exec_st_ptr, size, data_ptr)
    ccall((:gko_array_i32_create_view, libginkgo), gko_array_i32, (gko_executor, Csize_t, Ptr{Cint}), exec_st_ptr, size, data_ptr)
end

function gko_array_i32_delete(array_st_ptr)
    ccall((:gko_array_i32_delete, libginkgo), Cvoid, (gko_array_i32,), array_st_ptr)
end

function gko_array_i32_get_size(array_st_ptr)
    ccall((:gko_array_i32_get_size, libginkgo), Csize_t, (gko_array_i32,), array_st_ptr)
end

mutable struct gko_array_i64_st end

const gko_array_i64 = Ptr{gko_array_i64_st}

function gko_array_i64_create(exec_st_ptr, size)
    ccall((:gko_array_i64_create, libginkgo), gko_array_i64, (gko_executor, Csize_t), exec_st_ptr, size)
end

function gko_array_i64_create_view(exec_st_ptr, size, data_ptr)
    ccall((:gko_array_i64_create_view, libginkgo), gko_array_i64, (gko_executor, Csize_t, Ptr{Int64}), exec_st_ptr, size, data_ptr)
end

function gko_array_i64_delete(array_st_ptr)
    ccall((:gko_array_i64_delete, libginkgo), Cvoid, (gko_array_i64,), array_st_ptr)
end

function gko_array_i64_get_size(array_st_ptr)
    ccall((:gko_array_i64_get_size, libginkgo), Csize_t, (gko_array_i64,), array_st_ptr)
end

mutable struct gko_array_f32_st end

const gko_array_f32 = Ptr{gko_array_f32_st}

function gko_array_f32_create(exec_st_ptr, size)
    ccall((:gko_array_f32_create, libginkgo), gko_array_f32, (gko_executor, Csize_t), exec_st_ptr, size)
end

function gko_array_f32_create_view(exec_st_ptr, size, data_ptr)
    ccall((:gko_array_f32_create_view, libginkgo), gko_array_f32, (gko_executor, Csize_t, Ptr{Cfloat}), exec_st_ptr, size, data_ptr)
end

function gko_array_f32_delete(array_st_ptr)
    ccall((:gko_array_f32_delete, libginkgo), Cvoid, (gko_array_f32,), array_st_ptr)
end

function gko_array_f32_get_size(array_st_ptr)
    ccall((:gko_array_f32_get_size, libginkgo), Csize_t, (gko_array_f32,), array_st_ptr)
end

mutable struct gko_array_f64_st end

const gko_array_f64 = Ptr{gko_array_f64_st}

function gko_array_f64_create(exec_st_ptr, size)
    ccall((:gko_array_f64_create, libginkgo), gko_array_f64, (gko_executor, Csize_t), exec_st_ptr, size)
end

function gko_array_f64_create_view(exec_st_ptr, size, data_ptr)
    ccall((:gko_array_f64_create_view, libginkgo), gko_array_f64, (gko_executor, Csize_t, Ptr{Cdouble}), exec_st_ptr, size, data_ptr)
end

function gko_array_f64_delete(array_st_ptr)
    ccall((:gko_array_f64_delete, libginkgo), Cvoid, (gko_array_f64,), array_st_ptr)
end

function gko_array_f64_get_size(array_st_ptr)
    ccall((:gko_array_f64_get_size, libginkgo), Csize_t, (gko_array_f64,), array_st_ptr)
end

mutable struct gko_matrix_dense_f32_st end

const gko_matrix_dense_f32 = Ptr{gko_matrix_dense_f32_st}

function gko_matrix_dense_f32_create(exec, size)
    ccall((:gko_matrix_dense_f32_create, libginkgo), gko_matrix_dense_f32, (gko_executor, gko_dim2_st), exec, size)
end

function gko_matrix_dense_f32_create_view(exec, size, values, stride)
    ccall((:gko_matrix_dense_f32_create_view, libginkgo), gko_matrix_dense_f32, (gko_executor, gko_dim2_st, Ptr{Cfloat}, Csize_t), exec, size, values, stride)
end

function gko_matrix_dense_f32_delete(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_delete, libginkgo), Cvoid, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_fill(mat_st_ptr, value)
    ccall((:gko_matrix_dense_f32_fill, libginkgo), Cvoid, (gko_matrix_dense_f32, Cfloat), mat_st_ptr, value)
end

function gko_matrix_dense_f32_at(mat_st_ptr, row, col)
    ccall((:gko_matrix_dense_f32_at, libginkgo), Cfloat, (gko_matrix_dense_f32, Csize_t, Csize_t), mat_st_ptr, row, col)
end

function gko_matrix_dense_f32_get_size(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_get_size, libginkgo), gko_dim2_st, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_get_values(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_get_values, libginkgo), Ptr{Cfloat}, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_get_stride(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_get_stride, libginkgo), Csize_t, (gko_matrix_dense_f32,), mat_st_ptr)
end

function gko_matrix_dense_f32_compute_dot(mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
    ccall((:gko_matrix_dense_f32_compute_dot, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
end

function gko_matrix_dense_f32_compute_norm1(mat_st_ptr1, mat_st_ptr2)
    ccall((:gko_matrix_dense_f32_compute_norm1, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2)
end

function gko_matrix_dense_f32_compute_norm2(mat_st_ptr1, mat_st_ptr2)
    ccall((:gko_matrix_dense_f32_compute_norm2, libginkgo), Cvoid, (gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr1, mat_st_ptr2)
end

function gko_matrix_dense_f32_read(str_ptr, exec)
    ccall((:gko_matrix_dense_f32_read, libginkgo), gko_matrix_dense_f32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_matrix_dense_f32_write_mtx(mat_st_ptr)
    ccall((:gko_matrix_dense_f32_write_mtx, libginkgo), Ptr{Cchar}, (gko_matrix_dense_f32,), mat_st_ptr)
end

mutable struct gko_matrix_dense_f64_st end

const gko_matrix_dense_f64 = Ptr{gko_matrix_dense_f64_st}

function gko_matrix_dense_f64_create(exec, size)
    ccall((:gko_matrix_dense_f64_create, libginkgo), gko_matrix_dense_f64, (gko_executor, gko_dim2_st), exec, size)
end

function gko_matrix_dense_f64_create_view(exec, size, values, stride)
    ccall((:gko_matrix_dense_f64_create_view, libginkgo), gko_matrix_dense_f64, (gko_executor, gko_dim2_st, Ptr{Cdouble}, Csize_t), exec, size, values, stride)
end

function gko_matrix_dense_f64_delete(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_delete, libginkgo), Cvoid, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_fill(mat_st_ptr, value)
    ccall((:gko_matrix_dense_f64_fill, libginkgo), Cvoid, (gko_matrix_dense_f64, Cdouble), mat_st_ptr, value)
end

function gko_matrix_dense_f64_at(mat_st_ptr, row, col)
    ccall((:gko_matrix_dense_f64_at, libginkgo), Cdouble, (gko_matrix_dense_f64, Csize_t, Csize_t), mat_st_ptr, row, col)
end

function gko_matrix_dense_f64_get_size(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_get_size, libginkgo), gko_dim2_st, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_get_values(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_get_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_get_stride(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_get_stride, libginkgo), Csize_t, (gko_matrix_dense_f64,), mat_st_ptr)
end

function gko_matrix_dense_f64_compute_dot(mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
    ccall((:gko_matrix_dense_f64_compute_dot, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2, mat_st_ptr_res)
end

function gko_matrix_dense_f64_compute_norm1(mat_st_ptr1, mat_st_ptr2)
    ccall((:gko_matrix_dense_f64_compute_norm1, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2)
end

function gko_matrix_dense_f64_compute_norm2(mat_st_ptr1, mat_st_ptr2)
    ccall((:gko_matrix_dense_f64_compute_norm2, libginkgo), Cvoid, (gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr1, mat_st_ptr2)
end

function gko_matrix_dense_f64_read(str_ptr, exec)
    ccall((:gko_matrix_dense_f64_read, libginkgo), gko_matrix_dense_f64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_matrix_dense_f64_write_mtx(mat_st_ptr)
    ccall((:gko_matrix_dense_f64_write_mtx, libginkgo), Ptr{Cchar}, (gko_matrix_dense_f64,), mat_st_ptr)
end

mutable struct gko_matrix_csr_f32_i32_st end

const gko_matrix_csr_f32_i32 = Ptr{gko_matrix_csr_f32_i32_st}

function gko_matrix_csr_f32_i32_create(exec, size, nnz)
    ccall((:gko_matrix_csr_f32_i32_create, libginkgo), gko_matrix_csr_f32_i32, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function gko_matrix_csr_f32_i32_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:gko_matrix_csr_f32_i32_create_view, libginkgo), gko_matrix_csr_f32_i32, (gko_executor, gko_dim2_st, Csize_t, Ptr{Cint}, Ptr{Cint}, Ptr{Cfloat}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function gko_matrix_csr_f32_i32_delete(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_delete, libginkgo), Cvoid, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_read(str_ptr, exec)
    ccall((:gko_matrix_csr_f32_i32_read, libginkgo), gko_matrix_csr_f32_i32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_write_csr_f32_i32_in_coo(str_ptr, mat_st_ptr)
    ccall((:gko_write_csr_f32_i32_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f32_i32), str_ptr, mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_num_srow_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_size(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_const_col_idxs(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_const_col_idxs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_const_row_ptrs(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_const_row_ptrs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_get_const_srow(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i32_get_const_srow, libginkgo), Ptr{Cint}, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function gko_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:gko_matrix_csr_f32_i32_apply, libginkgo), Cvoid, (gko_matrix_csr_f32_i32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f32_i64_st end

const gko_matrix_csr_f32_i64 = Ptr{gko_matrix_csr_f32_i64_st}

function gko_matrix_csr_f32_i64_create(exec, size, nnz)
    ccall((:gko_matrix_csr_f32_i64_create, libginkgo), gko_matrix_csr_f32_i64, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function gko_matrix_csr_f32_i64_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:gko_matrix_csr_f32_i64_create_view, libginkgo), gko_matrix_csr_f32_i64, (gko_executor, gko_dim2_st, Csize_t, Ptr{Int64}, Ptr{Int64}, Ptr{Cfloat}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function gko_matrix_csr_f32_i64_delete(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_delete, libginkgo), Cvoid, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_read(str_ptr, exec)
    ccall((:gko_matrix_csr_f32_i64_read, libginkgo), gko_matrix_csr_f32_i64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_write_csr_f32_i64_in_coo(str_ptr, mat_st_ptr)
    ccall((:gko_write_csr_f32_i64_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f32_i64), str_ptr, mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_num_srow_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_size(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_const_values, libginkgo), Ptr{Cfloat}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_const_col_idxs(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_const_col_idxs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_const_row_ptrs(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_const_row_ptrs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_get_const_srow(mat_st_ptr)
    ccall((:gko_matrix_csr_f32_i64_get_const_srow, libginkgo), Ptr{Int64}, (gko_matrix_csr_f32_i64,), mat_st_ptr)
end

function gko_matrix_csr_f32_i64_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:gko_matrix_csr_f32_i64_apply, libginkgo), Cvoid, (gko_matrix_csr_f32_i64, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f64_i32_st end

const gko_matrix_csr_f64_i32 = Ptr{gko_matrix_csr_f64_i32_st}

function gko_matrix_csr_f64_i32_create(exec, size, nnz)
    ccall((:gko_matrix_csr_f64_i32_create, libginkgo), gko_matrix_csr_f64_i32, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function gko_matrix_csr_f64_i32_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:gko_matrix_csr_f64_i32_create_view, libginkgo), gko_matrix_csr_f64_i32, (gko_executor, gko_dim2_st, Csize_t, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function gko_matrix_csr_f64_i32_delete(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_delete, libginkgo), Cvoid, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_read(str_ptr, exec)
    ccall((:gko_matrix_csr_f64_i32_read, libginkgo), gko_matrix_csr_f64_i32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_write_csr_f64_i32_in_coo(str_ptr, mat_st_ptr)
    ccall((:gko_write_csr_f64_i32_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f64_i32), str_ptr, mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_num_srow_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_size(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_const_col_idxs(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_const_col_idxs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_const_row_ptrs(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_const_row_ptrs, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_get_const_srow(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i32_get_const_srow, libginkgo), Ptr{Cint}, (gko_matrix_csr_f64_i32,), mat_st_ptr)
end

function gko_matrix_csr_f64_i32_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:gko_matrix_csr_f64_i32_apply, libginkgo), Cvoid, (gko_matrix_csr_f64_i32, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr, alpha, x, beta, y)
end

mutable struct gko_matrix_csr_f64_i64_st end

const gko_matrix_csr_f64_i64 = Ptr{gko_matrix_csr_f64_i64_st}

function gko_matrix_csr_f64_i64_create(exec, size, nnz)
    ccall((:gko_matrix_csr_f64_i64_create, libginkgo), gko_matrix_csr_f64_i64, (gko_executor, gko_dim2_st, Csize_t), exec, size, nnz)
end

function gko_matrix_csr_f64_i64_create_view(exec, size, nnz, row_ptrs, col_idxs, values)
    ccall((:gko_matrix_csr_f64_i64_create_view, libginkgo), gko_matrix_csr_f64_i64, (gko_executor, gko_dim2_st, Csize_t, Ptr{Int64}, Ptr{Int64}, Ptr{Cdouble}), exec, size, nnz, row_ptrs, col_idxs, values)
end

function gko_matrix_csr_f64_i64_delete(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_delete, libginkgo), Cvoid, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_read(str_ptr, exec)
    ccall((:gko_matrix_csr_f64_i64_read, libginkgo), gko_matrix_csr_f64_i64, (Ptr{Cchar}, gko_executor), str_ptr, exec)
end

function gko_write_csr_f64_i64_in_coo(str_ptr, mat_st_ptr)
    ccall((:gko_write_csr_f64_i64_in_coo, libginkgo), Cvoid, (Ptr{Cchar}, gko_matrix_csr_f64_i64), str_ptr, mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_num_stored_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_num_stored_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_num_srow_elements(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_num_srow_elements, libginkgo), Csize_t, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_size(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_size, libginkgo), gko_dim2_st, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_const_values(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_const_values, libginkgo), Ptr{Cdouble}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_const_col_idxs(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_const_col_idxs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_const_row_ptrs(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_const_row_ptrs, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_get_const_srow(mat_st_ptr)
    ccall((:gko_matrix_csr_f64_i64_get_const_srow, libginkgo), Ptr{Int64}, (gko_matrix_csr_f64_i64,), mat_st_ptr)
end

function gko_matrix_csr_f64_i64_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:gko_matrix_csr_f64_i64_apply, libginkgo), Cvoid, (gko_matrix_csr_f64_i64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64, gko_matrix_dense_f64), mat_st_ptr, alpha, x, beta, y)
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
    gko_deferred_factory_parameter_delete(dfp_st_ptr)

Deallocates memory for a ginkgo deferred factory parameter object.

# Arguments
* `dfp_st_ptr`: Raw pointer to the shared pointer of the deferred factory parameter object to be deleted
"""
function gko_deferred_factory_parameter_delete(dfp_st_ptr)
    ccall((:gko_deferred_factory_parameter_delete, libginkgo), Cvoid, (gko_deferred_factory_parameter,), dfp_st_ptr)
end

# no prototype is found for this function at c_api.h:478:32, please use with caution
"""
    gko_preconditioner_none_create()

Create a deferred factory parameter for an empty preconditioner

# Returns
[`gko_deferred_factory_parameter`](@ref) Raw pointer to the shared pointer of the none preconditioner created
"""
function gko_preconditioner_none_create()
    ccall((:gko_preconditioner_none_create, libginkgo), gko_deferred_factory_parameter, ())
end

function gko_preconditioner_jacobi_f64_i32_create(blocksize)
    ccall((:gko_preconditioner_jacobi_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (Cint,), blocksize)
end

function gko_preconditioner_jacobi_f32_i32_create(blocksize)
    ccall((:gko_preconditioner_jacobi_f32_i32_create, libginkgo), gko_deferred_factory_parameter, (Cint,), blocksize)
end

function gko_preconditioner_ilu_f64_i32_create(dfp_st_ptr)
    ccall((:gko_preconditioner_ilu_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (gko_deferred_factory_parameter,), dfp_st_ptr)
end

function gko_factorization_parilu_f64_i32_create(iteration, skip_sorting)
    ccall((:gko_factorization_parilu_f64_i32_create, libginkgo), gko_deferred_factory_parameter, (Cint, Bool), iteration, skip_sorting)
end

"""
Struct containing the shared pointer to a ginkgo LinOp object
"""
mutable struct gko_linop_st end

"""
Type of the pointer to the wrapped [`gko_linop_st`](@ref) struct
"""
const gko_linop = Ptr{gko_linop_st}

"""
    gko_linop_delete(linop_st_ptr)

Deallocates memory for a ginkgo LinOp object.

# Arguments
* `linop_st_ptr`: Raw pointer to the shared pointer of the LinOp object to be deleted
"""
function gko_linop_delete(linop_st_ptr)
    ccall((:gko_linop_delete, libginkgo), Cvoid, (gko_linop,), linop_st_ptr)
end

"""
    gko_linop_apply(A_st_ptr, b_st_ptr, x_st_ptr)

Applies a linear operator to a vector (or a sequence of vectors).

# Arguments
* `A_st_ptr`: Raw pointer to the shared pointer of the LinOp object
* `b_st_ptr`: Raw pointer to the shared pointer of the input vector(s) on which the operator is applied
* `x_st_ptr`: Raw pointer to the shared pointer of the output vector where the result is stored
"""
function gko_linop_apply(A_st_ptr, b_st_ptr, x_st_ptr)
    ccall((:gko_linop_apply, libginkgo), Cvoid, (gko_linop, gko_linop, gko_linop), A_st_ptr, b_st_ptr, x_st_ptr)
end

function gko_solver_cg_f64_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
    ccall((:gko_solver_cg_f64_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
end

function gko_solver_bicgstab_f64_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
    ccall((:gko_solver_bicgstab_f64_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
end

function gko_solver_gmres_f64_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter, krylov_dim)
    ccall((:gko_solver_gmres_f64_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter, krylov_dim)
end

function gko_solver_cg_f32_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
    ccall((:gko_solver_cg_f32_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
end

function gko_solver_bicgstab_f32_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
    ccall((:gko_solver_bicgstab_f32_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter)
end

function gko_solver_gmres_f32_create(exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter, krylov_dim)
    ccall((:gko_solver_gmres_f32_create, libginkgo), gko_linop, (gko_executor, gko_linop, gko_deferred_factory_parameter, Cdouble, Cint, Cint), exec_st_ptr, A_st_ptr, preconditioner_dfp_st_ptr, reduction, maxiter, krylov_dim)
end

function gko_solver_spd_direct_f64_i64_create(exec_st_ptr, A_st_ptr)
    ccall((:gko_solver_spd_direct_f64_i64_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function gko_solver_lu_direct_f64_i64_create(exec_st_ptr, A_st_ptr)
    ccall((:gko_solver_lu_direct_f64_i64_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function gko_solver_lu_direct_f64_i32_create(exec_st_ptr, A_st_ptr)
    ccall((:gko_solver_lu_direct_f64_i32_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

function gko_solver_lu_direct_f32_i32_create(exec_st_ptr, A_st_ptr)
    ccall((:gko_solver_lu_direct_f32_i32_create, libginkgo), gko_linop, (gko_executor, gko_linop), exec_st_ptr, A_st_ptr)
end

"""
Struct containing the shared pointer to a ginkgo logger object
"""
mutable struct gko_log_convergence_f32_st end

mutable struct gko_log_convergence_f64_st end

"""
Type of the pointer to the wrapped `gko_log_convergence_st` struct
"""
const gko_log_convergence_f32 = Ptr{gko_log_convergence_f32_st}

const gko_log_convergence_f64 = Ptr{gko_log_convergence_f64_st}

"""
    gko_log_convergence_f32_delete(log_conv_st_ptr)

Deallocates memory for a ginkgo logger object.

# Arguments
* `log_conv_st_ptr`: Raw pointer to the shared pointer of the logger object to be deleted
"""
function gko_log_convergence_f32_delete(log_conv_st_ptr)
    ccall((:gko_log_convergence_f32_delete, libginkgo), Cvoid, (gko_log_convergence_f32,), log_conv_st_ptr)
end

function gko_log_convergence_f64_delete(log_conv_st_ptr)
    ccall((:gko_log_convergence_f64_delete, libginkgo), Cvoid, (gko_log_convergence_f64,), log_conv_st_ptr)
end

# no prototype is found for this function at c_api.h:590:25, please use with caution
function gko_logger_convergence_f32_create()
    ccall((:gko_logger_convergence_f32_create, libginkgo), gko_log_convergence_f32, ())
end

function gko_logger_convergence_f32_solver_add(solver_st_ptr, logger_st_ptr)
    ccall((:gko_logger_convergence_f32_solver_add, libginkgo), Cvoid, (gko_linop, gko_log_convergence_f32), solver_st_ptr, logger_st_ptr)
end

# no prototype is found for this function at c_api.h:595:25, please use with caution
function gko_logger_convergence_f64_create()
    ccall((:gko_logger_convergence_f64_create, libginkgo), gko_log_convergence_f64, ())
end

function gko_logger_convergence_f64_solver_add(solver_st_ptr, logger_st_ptr)
    ccall((:gko_logger_convergence_f64_solver_add, libginkgo), Cvoid, (gko_linop, gko_log_convergence_f64), solver_st_ptr, logger_st_ptr)
end

function gko_logger_convergence_f64_get_num_iterations(logger_st_ptr)
    ccall((:gko_logger_convergence_f64_get_num_iterations, libginkgo), Cint, (gko_log_convergence_f64,), logger_st_ptr)
end

function gko_logger_convergence_f32_get_num_iterations(logger_st_ptr)
    ccall((:gko_logger_convergence_f32_get_num_iterations, libginkgo), Cint, (gko_log_convergence_f32,), logger_st_ptr)
end

# exports
const PREFIXES = ["CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
