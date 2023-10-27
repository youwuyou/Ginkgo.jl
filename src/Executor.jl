const EXECUTOR_MAP = Dict(
    :omp => API.OMP,
    :cuda => API.CUDA,
    :hip => API.HIP,
    :dpcpp => API.DPCPP,
    :reference => API.REFERENCE
)

"""
    create!(executor_type::Symbol)

Creation of the executor of a specified executor type.

# Arguments
- `executor_type::Symbol`: One of the executor types to create out of `EXECUTOR_SYMBOLS`
"""
function create!(executor_type::Symbol)
    # Dynamically construct the function name and call it
    function_name = Symbol("ginkgo_create_executor_", executor_type)
    @info "Creating $executor_type executor"
    return eval(:($API.$function_name()))
end