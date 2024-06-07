# gko::Executor
const SUPPORTED_EXECUTOR_TYPE = [:omp, :reference, :cuda, :hip, :dpcpp]

"""
    abstract type GkoExecutor

Abstract type representing a Ginkgo executor.
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

# Creating an CUDA executor to run on Nvidia GPUs, using device ID 0 by default
julia> exec = GkoExecutor(:cuda)
```
# External links
$(_doc_external("gko::Executor", "classgko_1_1Executor"))
"""
abstract type GkoExecutor end

# Operations on all subtypes of GkoExecutor
function delete_executor(exec::GkoExecutor)
    @warn "Calling the destructor for $(typeof(exec)) !"
    API.ginkgo_executor_delete(exec.ptr)
end


"""
    abstract type GkoGPUExecutor <: GkoExecutor
Abstract type representing a GPU executor.

See also: [`GkoCUDAExecutor`](@ref), [`GkoHIPExecutor`](@ref), [`GkoDPCPPExecutor`](@ref)
"""
abstract type GkoGPUExecutor <: GkoExecutor end

"""
    abstract type GkoCPUExecutor <: GkoExecutor
Abstract type representing a CPU executor.

See also: [`GkoOMPExecutor`](@ref), [`GkoReferenceExecutor`](@ref)
"""
abstract type GkoCPUExecutor <: GkoExecutor end


"""
    abstract type GkoGPUThreadExecutor <: GkoGPUExecutor

Abstract type representing a GPU thread-based executor in Ginkgo.jl.

See also: [`GkoCUDAExecutor`](@ref), [`GkoHIPExecutor`](@ref)
"""
abstract type GkoGPUThreadExecutor <: GkoGPUExecutor end

"""
    abstract type GkoGPUItemExecutor <: GkoGPUExecutor

Abstract type representing a GPU item executor in Ginkgo.jl.

See also: [`GkoDPCPPExecutor`](@ref)
"""
abstract type GkoGPUItemExecutor <: GkoGPUExecutor end

"""
    struct GkoOMPExecutor <: GkoCPUExecutor

Concrete executor type for executor on an OpenMP-supporting device (e.g. host CPU).
"""
mutable struct GkoOMPExecutor <: GkoCPUExecutor
    ptr::Ptr{Cvoid}
    function GkoOMPExecutor()
        @info "Creating OMP executor"
        ptr = API.ginkgo_executor_omp_create()
        finalizer(delete_executor, new(ptr))
    end
end

"""
    struct GkoReferenceExecutor <: GkoCPUExecutor

Concrete executor type for reference (CPU) execution.
"""
mutable struct GkoReferenceExecutor <: GkoCPUExecutor
    ptr::Ptr{Cvoid}
    function GkoReferenceExecutor()
        @info "Creating reference executor"
        ptr = API.ginkgo_executor_reference_create()
        finalizer(delete_executor, new(ptr))
    end
end

"""
    struct GkoCUDAExecutor <: GkoGPUThreadExecutor

Concrete executor type for CUDA execution.
"""
mutable struct GkoCUDAExecutor <: GkoGPUThreadExecutor
    ptr::Ptr{Cvoid}
    function GkoCUDAExecutor(device_id::Integer)
        @info "Creating CUDA executor"
        ptr = API.ginkgo_executor_cuda_create(device_id)
        finalizer(delete_executor, new(ptr))
    end
end

"""
    struct GkoHIPExecutor <: GkoGPUThreadExecutor

Concrete executor type for HIP execution.
"""
mutable struct GkoHIPExecutor <: GkoGPUThreadExecutor
    ptr::Ptr{Cvoid}
    function GkoHIPExecutor(device_id::Integer)
        @info "Creating HIP executor"
        ptr = API.ginkgo_executor_hip_create(device_id)
        finalizer(delete_executor, new(ptr))
    end    
end

"""
    struct GkoDPCPPExecutor <: GkoGPUItemExecutor

Concrete executor type for DPCPP execution.
"""
mutable struct GkoDPCPPExecutor <: GkoGPUItemExecutor
    ptr::Ptr{Cvoid}
    function GkoDPCPPExecutor(device_id::Integer)
        @info "Creating DPCPP executor"
        ptr = API.ginkgo_executor_dpcpp_create(device_id)
        finalizer(delete_executor, new(ptr))
    end        
end

"""
    struct GkoScopedExecutor <: GkoExecutor

Executor type used generically for ScopedValue usage.
"""
mutable struct GkoScopedExecutor <: GkoExecutor
    ptr::Ptr{Cvoid}
    function GkoScopedExecutor()
        @warn "Intializing EXECUTOR::ScopedValue{GkoScopedExecutor} with dummy values for implicit executor usage. Users are not supposed to use this internal function!"
        array = []
        new(pointer_from_objref(array))
    end
    
    function GkoScopedExecutor(ptr::Ptr{Cvoid})
        new(ptr)
    end    
end

# Converters for scoped values
Base.convert(::Type{GkoScopedExecutor}, obj::GkoExecutor) = GkoScopedExecutor(obj.ptr)

"""
    create(executor_type::Symbol)

Creation of the executor of a specified executor type.

# Parameters
- `executor_type::Symbol`: One of the executor types to create out of supported executor types $SUPPORTED_EXECUTOR_TYPE
"""
function create(executor_type::Symbol; device_id::Integer = 0)
    if executor_type == :reference
        return GkoReferenceExecutor()

    elseif executor_type == :omp
        return GkoOMPExecutor()

    elseif executor_type == :cuda
        return GkoCUDAExecutor(device_id)

    elseif executor_type == :hip
        return GkoHIPExecutor(device_id)

    elseif executor_type == :dpcpp
        return GkoDPCPPExecutor(device_id)
    end
end

get_num_devices(::GkoCUDAExecutor) = Int32(API.ginkgo_executor_cuda_get_num_devices())
get_num_devices(::GkoHIPExecutor) = Int32(API.ginkgo_executor_hip_get_num_devices())
get_num_devices(::GkoDPCPPExecutor) = Int32(API.ginkgo_executor_dpcpp_get_num_devices())

# Getters for GkoGPUThreadExecutor (CUDA, HIP)

get_num_multiprocessor(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_num_multiprocessor(exec.ptr))
get_device_id(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_device_id(exec.ptr))
get_num_warps_per_sm(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_num_warps_per_sm(exec.ptr))
get_num_warps(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_num_warps(exec.ptr))
get_warp_size(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_warp_size(exec.ptr))
get_major_version(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_major_version(exec.ptr))
get_minor_version(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_minor_version(exec.ptr))
get_closest_numa(exec::GkoGPUThreadExecutor) = Int32(API.ginkgo_executor_gpu_thread_get_closest_numa(exec.ptr))

# Getters for GkoGPUItemExecutor (DPCPP)

get_max_subgroup_size(exec::GkoGPUItemExecutor) = Int32(API.ginkgo_executor_gpu_item_get_max_subgroup_size(exec.ptr))
get_max_workgroup_size(exec::GkoGPUItemExecutor) = Int32(API.ginkgo_executor_gpu_item_get_max_workgroup_size(exec.ptr))
get_num_computing_units(exec::GkoGPUItemExecutor) = Int32(API.ginkgo_executor_gpu_item_get_num_computing_units(exec.ptr))