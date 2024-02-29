using Ginkgo
using SparseArrays
using SparseMatricesCSR
using Test

include("test-configurations.jl")

# include("base/test-array.jl")
include("base/test-executor.jl")
# include("base/test-linop.jl")

include("matrix/test-csr.jl")
include("matrix/test-dense.jl")

# include("preconditioner/test-preconditioner.jl")

# include("solver/test-cg.jl")