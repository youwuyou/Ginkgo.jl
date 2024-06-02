# gko::Executor
const SUPPORTED_EXECUTOR_TYPE = [:omp, :reference, :cuda, :hip, :dpcpp]

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

    ############################# CONSTRUCTOR ####################################
    function GkoExecutor()
        @warn "Intializing EXECUTOR::ScopedValue{GkoExecutor} with dummy values for implicit executor usage. Users are not supposed to use this internal function!"
        array = []
        executor_type = :dummy
        new(pointer_from_objref(array), executor_type)
    end    

    function GkoExecutor(executor_type::Symbol; device_id::Integer = 0)
        executor_type in SUPPORTED_EXECUTOR_TYPE || throw(ArgumentError("unsupported executor type $executor_type"))
        # Calling ginkgo to initialize the array
        function_name = Symbol("ginkgo_executor_", executor_type, "_create")
        @info "Creating $executor_type executor"

        if executor_type == :reference || executor_type == :omp
            ptr = eval(:($API.$function_name()))            
        else
            ptr = eval(:($API.$function_name($device_id)))
        end
        finalizer(delete_executor, new(ptr, executor_type))
    end

    ############################# DESTRUCTOR ####################################
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
function create(executor_type::Symbol; device_id::Integer = 0)
    if executor_type == :reference || executor_type == :omp
        return GkoExecutor(executor_type)
    else
        # on GPU
        num_device = get_num_devices(executor_type)
        if num_device > 0
            return GkoExecutor(executor_type, device_id = device_id)
        else
            throw(ArgumentError("No device available for $executor_type, num_device = $num_device"))
        end
    end
end

function get_num_devices(executor_type::Symbol)
    if executor_type == :cuda || executor_type == :hip || executor_type == :dpcpp
        function_name = Symbol("ginkgo_executor_", executor_type, "_get_num_devices")
        eval(:($API.$function_name()))
    else
        throw(ArgumentError("unsupported executor type $executor_type"))
    end
end