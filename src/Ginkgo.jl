module Ginkgo

# Import helper functions for documentation purposes
include("dochelper.jl")

# Import low-level C interface, generated using Clang.jl
include("api.jl")

# Import high-level Julia API
include("Configurations.jl")
include("Type.jl")


export
    get_version

include("base/Array.jl")
include("base/Dim.jl")
include("base/Executor.jl")

include("matrix/Dense.jl")
# include("matrix/Csr.jl")

# Export types
export 
    Array  # minimal working
    Dim    # completely wrapped but bool operator
    Dense

export 
    create # executor
    number # create 1x1 matrix
    elements
    norm1!
    norm2!

end # module Ginkgo
