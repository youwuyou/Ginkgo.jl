module Ginkgo

############################# EXTERNAL #################################
using SparseArrays
using SparseMatricesCSR
using LinearAlgebra

# Hide executors
using ScopedValues; export with, @with

############################# SUBMODULES ###############################
include("preferences.jl") # GkoPreferences
include("api.jl")         # low-level C interface, generated using Clang.jl

export locate, preferences, diagnostics, use_jll_binary!, use_system_binary!

############################# OTHERS ###################################
# Helper functions for documentation purposes
include("utils.jl")

############################# CORE ####################################

# High-level Julia API
include("Configurations.jl")
include("Type.jl")
include("base/Array.jl")
include("base/Executor.jl")

include("matrix/Dense.jl")
include("matrix/Csr.jl")

include("factorization/Factorization.jl")
include("preconditioner/Preconditioner.jl")
include("base/LinOp.jl")

# Dummy value used by ScopedValues.jl for implicit executor usage
EXECUTOR = ScopedValue(GkoScopedExecutor())
export EXECUTOR

# Export supported types for Ginkgo.jl
export
    SUPPORTED_EXECUTOR_TYPE,
    SUPPORTED_DENSE_ELTYPE,
    SUPPORTED_CSR_ELTYPE,
    SUPPORTED_CSR_INDEXTYPE

# Export types
export
    GkoExecutor,
    GkoCPUExecutor,
    GkoGPUExecutor,
    GkoGPUThreadExecutor,
    GkoGPUItemExecutor,
    GkoCUDAHIPExecutor,
    # Concrete executor types
    GkoScopedExecutor,
    GkoOMPExecutor,
    GkoReferenceExecutor,
    GkoCUDAExecutor,
    GkoHIPExecutor,
    GkoDPCPPExecutor,
    GkoArray,  # minimal working
    GkoDense,
    GkoCsr,
    GkoPreconditioner,
    GkoNonePreconditioner,
    GkoJacobiPreconditioner,
    GkoILUPreconditioner,
    GkoLinOp,           # Abstract type for solvers
    GkoDirectSolver,    # for direct solver
    GkoIterativeSolver, # for iterative solver
    GkoFactorization,
    GkoParILUFactorization  # for factorization, also a type of linop

export
    version, # binary version info

    # Executor
    create,
    get_num_devices, # executor

    # Thread-based executors only
    get_num_multiprocessor,
    get_device_id,
    get_num_warps_per_sm,
    get_num_warps,
    get_warp_size,
    get_major_version,
    get_minor_version,
    get_closest_numa,

    # Item-based executors only
    get_max_subgroup_size,
    get_max_workgroup_size,
    get_num_computing_units,

    number,  # create 1x1 matrix
    elements,
    norm1!,
    norm2!,
    nnz,
    apply!
    # axpby! # BLAS-like apply

export
    mmwrite

end # module Ginkgo
