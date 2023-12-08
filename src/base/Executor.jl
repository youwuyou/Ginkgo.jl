# gko::Executor
const SUPPORTED_EXECUTOR_TYPE = [:omp, :reference, :cuda#=, :hip, :dpcpp=#]

"""
    GkoExecutor

Executors are used to specify the location for the data of linear algebra objects,
and to determine where the operations will be executed. In Ginkgo.jl you can select one
of the types out of - `$SUPPORTED_EXECUTOR_TYPE`

Alternatively, you can also create an executor using the [`create`](@ref) method.

### Examples

```julia-repl
# Creating an OpenMP executor
julia> exec = GkoExecutor(:omp)

# Creating a reference (OpenMP) executor
julia> exec = GkoExecutor(:reference)

# Creating an CUDA executor to run on Nvidia GPUs
julia> exec = GkoExecutor(:cuda)
```
# External links
$(_doc_external("gko::Executor", "classgko_1_1Executor"))
"""
mutable struct GkoExecutor
    ptr::Ptr{Cvoid}
    type::Symbol

    # Constructor
    function GkoExecutor(executor_type::Symbol)
        executor_type in SUPPORTED_EXECUTOR_TYPE || throw(ArgumentError("unsupported executor type $executor_type"))

        # Calling ginkgo to initialize the array
        function_name = Symbol("ginkgo_executor_", executor_type, "_create")
        @info "Creating $executor_type executor"

        ptr = eval(:($API.$function_name()))
        finalizer(delete_executor, new(ptr, executor_type))
    end

    # Destructor
    function delete_executor(exec::GkoExecutor)
        @warn "Calling the destructor for GkoExecutor for $(exec.type)!"
        API.ginkgo_executor_delete(exec.ptr)
    end
end

"""
    create(executor_type::Symbol)

Creation of the executor of a specified executor type.

# Parameters
- `executor_type::Symbol`: One of the executor types to create out of supported executor types $SUPPORTED_EXECUTOR_TYPE
"""
function create(executor_type::Symbol)
    return GkoExecutor(executor_type)
end