module Ginkgo

############################# EXTERNAL #################################
using SparseArrays

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
# include("base/LinOp.jl")

include("matrix/Dense.jl")
include("matrix/Csr.jl")

include("solver/CG.jl")

# Dummy value used by ScopedValues.jl for implicit executor usage
const EXECUTOR = ScopedValue(GkoExecutor())
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
    GkoArray,  # minimal working
    GkoDense,
    GkoCsr

export
    version, # binary version info
    create,  # executor
    number,  # create 1x1 matrix
    elements,
    norm1!,
    norm2!,
    nnz,
    cg!,
    spmm!
    # axpby! # BLAS-like apply


end # module Ginkgo
