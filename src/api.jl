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

"""
    ginkgo_dim2_create(rows, cols)

Allocates memory for a C-based reimplementation of the gko::dim<2> type

### Parameters
* `rows`: First dimension
* `cols`: Second dimension
### Returns
[`gko_dim2_st`](@ref) C struct that contains members of the gko::dim<2> type
"""
function ginkgo_dim2_create(rows, cols)
    ccall((:ginkgo_dim2_create, libginkgo), gko_dim2_st, (Csize_t, Csize_t), rows, cols)
end

"""
    ginkgo_dim2_rows_get(dim)

Obtains the value of the first element of a gko::dim<2> type

### Parameters
* `dim`: An object of [`gko_dim2_st`](@ref) type
### Returns
size\\_t First dimension
"""
function ginkgo_dim2_rows_get(dim)
    ccall((:ginkgo_dim2_rows_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    ginkgo_dim2_cols_get(dim)

Obtains the value of the second element of a gko::dim<2> type

### Parameters
* `dim`: An object of [`gko_dim2_st`](@ref) type
### Returns
size\\_t Second dimension
"""
function ginkgo_dim2_cols_get(dim)
    ccall((:ginkgo_dim2_cols_get, libginkgo), Csize_t, (gko_dim2_st,), dim)
end

"""
    ginkgo_executor_delete(exec_st_ptr)

Deallocates memory for an executor on targeted device.

### Parameters
* `exec_st_ptr`: Raw pointer to the shared pointer of the executor to be deleted
"""
function ginkgo_executor_delete(exec_st_ptr)
    ccall((:ginkgo_executor_delete, libginkgo), Cvoid, (gko_executor,), exec_st_ptr)
end

# no prototype is found for this function at c_api.h:307:14, please use with caution
function ginkgo_executor_omp_create()
    ccall((:ginkgo_executor_omp_create, libginkgo), gko_executor, ())
end

# no prototype is found for this function at c_api.h:311:14, please use with caution
function ginkgo_executor_reference_create()
    ccall((:ginkgo_executor_reference_create, libginkgo), gko_executor, ())
end

mutable struct gko_array_i16_st end

const gko_array_i16 = Ptr{gko_array_i16_st}

function ginkgo_array_i16_create(exec_st_ptr, size)
    ccall((:ginkgo_array_i16_create, libginkgo), gko_array_i16, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_i16_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_i16_create_view, libginkgo), gko_array_i16, (gko_executor, Csize_t, Ptr{Cshort}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_i16_delete(array_st_ptr)
    ccall((:ginkgo_array_i16_delete, libginkgo), Cvoid, (gko_array_i16,), array_st_ptr)
end

function ginkgo_array_i16_get_num_elems(array_st_ptr)
    ccall((:ginkgo_array_i16_get_num_elems, libginkgo), Csize_t, (gko_array_i16,), array_st_ptr)
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

function ginkgo_array_i32_get_num_elems(array_st_ptr)
    ccall((:ginkgo_array_i32_get_num_elems, libginkgo), Csize_t, (gko_array_i32,), array_st_ptr)
end

mutable struct gko_array_i64_st end

const gko_array_i64 = Ptr{gko_array_i64_st}

function ginkgo_array_i64_create(exec_st_ptr, size)
    ccall((:ginkgo_array_i64_create, libginkgo), gko_array_i64, (gko_executor, Csize_t), exec_st_ptr, size)
end

function ginkgo_array_i64_create_view(exec_st_ptr, size, data_ptr)
    ccall((:ginkgo_array_i64_create_view, libginkgo), gko_array_i64, (gko_executor, Csize_t, Ptr{Clonglong}), exec_st_ptr, size, data_ptr)
end

function ginkgo_array_i64_delete(array_st_ptr)
    ccall((:ginkgo_array_i64_delete, libginkgo), Cvoid, (gko_array_i64,), array_st_ptr)
end

function ginkgo_array_i64_get_num_elems(array_st_ptr)
    ccall((:ginkgo_array_i64_get_num_elems, libginkgo), Csize_t, (gko_array_i64,), array_st_ptr)
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

function ginkgo_array_f32_get_num_elems(array_st_ptr)
    ccall((:ginkgo_array_f32_get_num_elems, libginkgo), Csize_t, (gko_array_f32,), array_st_ptr)
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

function ginkgo_array_f64_get_num_elems(array_st_ptr)
    ccall((:ginkgo_array_f64_get_num_elems, libginkgo), Csize_t, (gko_array_f64,), array_st_ptr)
end

mutable struct gko_matrix_dense_f32_st end

const gko_matrix_dense_f32 = Ptr{gko_matrix_dense_f32_st}

function ginkgo_matrix_dense_f32_create(exec, size)
    ccall((:ginkgo_matrix_dense_f32_create, libginkgo), gko_matrix_dense_f32, (gko_executor, gko_dim2_st), exec, size)
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

function ginkgo_matrix_csr_f32_i32_delete(mat_st_ptr)
    ccall((:ginkgo_matrix_csr_f32_i32_delete, libginkgo), Cvoid, (gko_matrix_csr_f32_i32,), mat_st_ptr)
end

function ginkgo_matrix_csr_f32_i32_read(str_ptr, exec)
    ccall((:ginkgo_matrix_csr_f32_i32_read, libginkgo), gko_matrix_csr_f32_i32, (Ptr{Cchar}, gko_executor), str_ptr, exec)
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

"""
    ginkgo_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)

Performs an SpMM product

### Parameters
* `mat_st_ptr`:
* `alpha`:
* `x`:
* `beta`:
* `y`:
"""
function ginkgo_matrix_csr_f32_i32_apply(mat_st_ptr, alpha, x, beta, y)
    ccall((:ginkgo_matrix_csr_f32_i32_apply, libginkgo), Cvoid, (gko_matrix_csr_f32_i32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32, gko_matrix_dense_f32), mat_st_ptr, alpha, x, beta, y)
end

function ginkgo_solver_cg_solve(exec_st_ptr, A_st_ptr, b_st_ptr, x_st_ptr, maxiter, reduction)
    ccall((:ginkgo_solver_cg_solve, libginkgo), Cvoid, (gko_executor, gko_matrix_csr_f32_i32, gko_matrix_dense_f32, gko_matrix_dense_f32, Cint, Cdouble), exec_st_ptr, A_st_ptr, b_st_ptr, x_st_ptr, maxiter, reduction)
end

# no prototype is found for this function at c_api.h:391:6, please use with caution
"""
    ginkgo_version_get()

This function is a wrapper for obtaining the version of the ginkgo library
"""
function ginkgo_version_get()
    ccall((:ginkgo_version_get, libginkgo), Cvoid, ())
end

# exports
const PREFIXES = ["CX", "clang_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
