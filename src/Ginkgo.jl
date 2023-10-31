module Ginkgo

# Import low-level C interface, generated using Clang.jl
include("api.jl")

# Import high-level Julia API
include("Configurations.jl")
include("Type.jl")
include("IO.jl")


export 
    get_version

include("base/Array.jl")
include("base/Dim.jl")
include("base/Executor.jl")

include("matrix/Dense.jl")
# include("matrix/Csr.jl")


# Export types
export 
    Array
    Dim

export 
    create!

end # module Ginkgo
