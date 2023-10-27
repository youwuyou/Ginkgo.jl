module Ginkgo

# Import low-level C interface, generated using Clang.jl
include("api.jl")

# Import high-level Julia API
include("Array.jl")
include("Configurations.jl")
include("Executor.jl")
include("Type.jl")

# Export types
export Array

# Export high-level API functions that we defined
export 
    get_version,
    create!

end # module Ginkgo
